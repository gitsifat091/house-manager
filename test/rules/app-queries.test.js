// Every query shape the app actually issues, run against the real rules.
//
// The tests in firestore.test.js prove the boundaries hold. These prove the
// app still works inside them — a rule that is too strict fails here rather
// than in somebody's hands.

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  addDoc,
  deleteDoc,
  collection,
  query,
  where,
  limit,
  writeBatch,
  runTransaction,
  getDocs,
} from 'firebase/firestore';

let testEnv;

const LANDLORD = 'landlord-1';
const TENANT_UID = 'tenant-uid-1';
const TENANT_EMAIL = 'tenant1@example.com';
const REC = 'tenant-rec-1';
const PROP = 'prop-1';
const PROP2 = 'prop-2';
const ROOM = 'room-1';

const asLandlord = () => testEnv.authenticatedContext(LANDLORD).firestore();
const asTenant = () =>
  testEnv.authenticatedContext(TENANT_UID, { email: TENANT_EMAIL }).firestore();

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'house-manager-queries',
    firestore: { rules: readFileSync('../../firestore.rules', 'utf8') },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users', LANDLORD), {
      uid: LANDLORD, role: 'landlord', name: 'L', email: 'l@x.com',
    });
    await setDoc(doc(db, 'users', TENANT_UID), {
      uid: TENANT_UID, role: 'tenant', name: 'T', email: TENANT_EMAIL,
      tenantDocId: REC,
    });
    await setDoc(doc(db, 'publicProfiles', LANDLORD), {
      name: 'L', photoUrl: null,
    });
    await setDoc(doc(db, 'publicProfiles', TENANT_UID), {
      name: 'T', photoUrl: null,
    });
    await setDoc(doc(db, 'properties', PROP), {
      landlordId: LANDLORD, name: 'P1',
    });
    await setDoc(doc(db, 'properties', PROP2), {
      landlordId: LANDLORD, name: 'P2',
    });
    await setDoc(doc(db, 'tenants', REC), {
      userId: TENANT_UID, landlordId: LANDLORD, propertyId: PROP,
      roomId: ROOM, roomNumber: '1', name: 'T', email: TENANT_EMAIL,
      emailLower: TENANT_EMAIL, rentAmount: 5000, isActive: true,
    });
    await setDoc(doc(db, 'rooms', ROOM), {
      propertyId: PROP, roomNumber: '1', status: 'occupied',
      tenantId: REC, tenantName: 'T', rentAmount: 5000,
    });
    await setDoc(doc(db, 'rooms', 'room-vacant'), {
      propertyId: PROP, roomNumber: '2', status: 'vacant', rentAmount: 4000,
    });
    await setDoc(doc(db, 'payments', 'pay-1'), {
      landlordId: LANDLORD, tenantId: REC, amount: 5000,
      month: 1, year: 2026, status: 'pending',
    });
    await setDoc(doc(db, 'utilities', 'util-1'), {
      landlordId: LANDLORD, tenantId: REC, amount: 100,
      month: 1, year: 2026, isPaid: false, isSubmitted: false,
    });
    await setDoc(doc(db, 'maintenance', 'mnt-1'), {
      landlordId: LANDLORD, tenantId: REC, title: 'Tap',
      description: 'Leaking', status: 'pending', createdAt: 1,
    });
    await setDoc(doc(db, 'notices', 'notice-1'), {
      landlordId: LANDLORD, title: 'N', body: 'B', createdAt: 1,
    });
    await setDoc(doc(db, 'rules', 'rule-1'), {
      landlordId: LANDLORD, title: 'R', description: 'D',
      category: 'legal', isActive: true, createdAt: 1,
    });
    await setDoc(doc(db, 'listings', 'listing-1'), {
      landlordId: LANDLORD, propertyId: PROP, roomId: 'room-vacant',
      isActive: true, rentAmount: 4000, division: 'Dhaka',
      district: 'Dhaka', thana: 'Mirpur', roomType: 'Family', createdAt: 1,
    });
    await setDoc(doc(db, 'rentalRequests', 'req-1'), {
      landlordId: LANDLORD, tenantUserId: TENANT_UID, listingId: 'listing-1',
      roomId: 'room-vacant', propertyId: PROP, status: 'pending', createdAt: 1,
    });
    await setDoc(doc(db, 'chatRooms', 'chat-1'), {
      landlordId: LANDLORD, tenantId: REC, tenantName: 'T',
      unreadLandlord: 0, unreadTenant: 0,
    });
    await setDoc(doc(db, 'notifications', 'n-1'), {
      userId: TENANT_UID, title: 'T', body: 'B', isRead: false,
      createdAt: 1, type: 'payment',
    });
  });
});

describe('landlord dashboard queries', () => {
  it('PropertyService.getProperties', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'properties'),
      where('landlordId', '==', LANDLORD))));
  });

  it('PropertyService.getRooms', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'rooms'),
      where('propertyId', '==', PROP))));
  });

  it('dashboard rooms whereIn across properties', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'rooms'),
      where('propertyId', 'in', [PROP, PROP2]))));
  });

  it('TenantService.getVacantRooms', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'rooms'),
      where('propertyId', 'in', [PROP]),
      where('status', '==', 'vacant'))));
  });

  it('TenantService.getTenants', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'tenants'),
      where('landlordId', '==', LANDLORD))));
  });

  it('tenants filtered by active state', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'tenants'),
      where('landlordId', '==', LANDLORD),
      where('isActive', '==', true))));
  });

  it('PaymentService.getPayments', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'payments'),
      where('landlordId', '==', LANDLORD))));
  });

  it('PaymentService.getPaymentSummary', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'payments'),
      where('landlordId', '==', LANDLORD),
      where('month', '==', 1),
      where('year', '==', 2026))));
  });

  it('UtilityService.getLandlordBills', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'utilities'),
      where('landlordId', '==', LANDLORD))));
  });

  it('MaintenanceService.getRequests', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'maintenance'),
      where('landlordId', '==', LANDLORD))));
  });

  it('NoticeService.getNotices', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'notices'),
      where('landlordId', '==', LANDLORD))));
  });

  it('RulesService.getRules', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'rules'),
      where('landlordId', '==', LANDLORD),
      where('isActive', '==', true))));
  });

  it('ListingService.getLandlordListings', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'listings'),
      where('landlordId', '==', LANDLORD))));
  });

  it('ListingService.getLandlordRequests', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'rentalRequests'),
      where('landlordId', '==', LANDLORD))));
  });

  it('ListingService.getPendingRequestCount', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'rentalRequests'),
      where('landlordId', '==', LANDLORD),
      where('status', '==', 'pending'))));
  });

  it('acceptRequest sweeps other requests for the room', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'rentalRequests'),
      where('landlordId', '==', LANDLORD),
      where('roomId', '==', 'room-vacant'),
      where('status', '==', 'pending'))));
  });

  it('cannot sweep requests for a room without naming the owner', async () => {
    await assertFails(getDocs(query(
      collection(asLandlord(), 'rentalRequests'),
      where('roomId', '==', 'room-vacant'),
      where('status', '==', 'pending'))));
  });

  it('ChatService.getLandlordChats', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'chatRooms'),
      where('landlordId', '==', LANDLORD))));
  });

  it('landlord_edit_tenant finds the tenant rooms', async () => {
    await assertSucceeds(getDocs(query(
      collection(asLandlord(), 'rooms'),
      where('propertyId', '==', PROP),
      where('tenantId', '==', REC))));
  });

  it('payment card reads the tenant record by id', async () => {
    await assertSucceeds(getDoc(doc(asLandlord(), 'tenants', REC)));
  });
});

describe('tenant screen queries', () => {
  it('TenantIdentityService.activeTenancy', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'tenants'),
      where('userId', '==', TENANT_UID),
      where('isActive', '==', true),
      limit(1))));
  });

  it('TenantIdentityService.watchPastTenancies', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'tenants'),
      where('userId', '==', TENANT_UID),
      where('isActive', '==', false))));
  });

  it('claim pass by emailLower', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'tenants'),
      where('emailLower', '==', TENANT_EMAIL))));
  });

  it('tenant_home reads its room by id', async () => {
    await assertSucceeds(getDoc(doc(asTenant(), 'rooms', ROOM)));
  });

  it('PaymentService.getTenantPayments', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'payments'),
      where('tenantId', '==', REC))));
  });

  it('tenant payment existence check', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'payments'),
      where('tenantId', '==', REC),
      where('month', '==', 1),
      where('year', '==', 2026))));
  });

  it('UtilityService.getTenantBills', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'utilities'),
      where('tenantId', '==', REC))));
  });

  it('MaintenanceService.getTenantRequests', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'maintenance'),
      where('tenantId', '==', REC))));
  });

  it('tenant reads landlord notices', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'notices'),
      where('landlordId', '==', LANDLORD))));
  });

  it('tenant reads landlord house rules', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'rules'),
      where('landlordId', '==', LANDLORD),
      where('isActive', '==', true))));
  });

  it('ChatService.getTenantChat', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'chatRooms'),
      where('tenantId', '==', REC))));
  });

  it('ChatService.getOrCreateChatRoom lookup', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'chatRooms'),
      where('landlordId', '==', LANDLORD),
      where('tenantId', '==', REC))));
  });

  it('ListingService.getTenantRequests', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'rentalRequests'),
      where('tenantUserId', '==', TENANT_UID))));
  });

  it('ListingService.searchListings', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'listings'),
      where('isActive', '==', true),
      where('division', '==', 'Dhaka'),
      where('district', '==', 'Dhaka'),
      where('thana', '==', 'Mirpur'),
      where('roomType', '==', 'Family'))));
  });

  it('notification badge query', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'notifications'),
      where('userId', '==', TENANT_UID),
      where('isRead', '==', false))));
  });

  it('TenantAvatar reads a public profile by uid', async () => {
    await assertSucceeds(getDoc(doc(asTenant(), 'publicProfiles', LANDLORD)));
  });

  it('tenant_chat reads the landlord display name', async () => {
    await assertSucceeds(getDoc(doc(asTenant(), 'publicProfiles', LANDLORD)));
  });

  it('tenant reads its own landlord contact details', async () => {
    await assertSucceeds(getDoc(doc(asTenant(), 'users', LANDLORD)));
  });
});

describe('write flows', () => {
  it('tenant submits a maintenance request', async () => {
    await assertSucceeds(addDoc(collection(asTenant(), 'maintenance'), {
      landlordId: LANDLORD, tenantId: REC, tenantName: 'T', roomNumber: '1',
      propertyId: PROP, propertyName: 'P1', title: 'Light',
      description: 'Broken', status: 'pending', createdAt: 2,
    }));
  });

  it('tenant_edit_profile finds its own room by tenant id', async () => {
    await assertSucceeds(getDocs(query(
      collection(asTenant(), 'rooms'),
      where('tenantId', '==', REC))));
  });

  it('tenant updates its own profile and its room name together', async () => {
    await assertSucceeds(updateDoc(doc(asTenant(), 'tenants', REC), {
      name: 'T2', phone: '017', email: TENANT_EMAIL,
      emailLower: TENANT_EMAIL, nidNumber: '9', hasEdited: true,
    }));
    await assertSucceeds(
      updateDoc(doc(asTenant(), 'rooms', ROOM), { tenantName: 'T2' }));
  });

  it('tenant publishes its own public profile', async () => {
    await assertSucceeds(setDoc(doc(asTenant(), 'publicProfiles', TENANT_UID),
      { name: 'T', photoUrl: 'data:image/jpeg;base64,x' }));
  });

  it('tenant writes its own tenantDocId pointer', async () => {
    await assertSucceeds(
      setDoc(doc(asTenant(), 'users', TENANT_UID),
        { tenantDocId: REC }, { merge: true }));
  });

  it('tenant saves its fcm token and photo', async () => {
    await assertSucceeds(updateDoc(doc(asTenant(), 'users', TENANT_UID), {
      fcmToken: 'tok', tokenUpdatedAt: 1, photoUrl: 'data:image/jpeg;base64,x',
    }));
  });

  it('landlord generates monthly payments in a batch', async () => {
    const db = asLandlord();
    const batch = writeBatch(db);
    batch.set(doc(collection(db, 'payments')), {
      landlordId: LANDLORD, tenantId: REC, tenantName: 'T', roomId: ROOM,
      roomNumber: '1', propertyId: PROP, propertyName: 'P1',
      amount: 5000, month: 2, year: 2026, status: 'pending',
    });
    await assertSucceeds(batch.commit());
  });

  it('landlord approves a submitted payment', async () => {
    await assertSucceeds(updateDoc(doc(asLandlord(), 'payments', 'pay-1'),
      { status: 'paid', paidAt: 1 }));
  });

  it('landlord adds a tenant and occupies the room', async () => {
    const db = asLandlord();
    await assertSucceeds(addDoc(collection(db, 'tenants'), {
      userId: '', landlordId: LANDLORD, propertyId: PROP,
      roomId: 'room-vacant', roomNumber: '2', name: 'New',
      email: 'new@example.com', emailLower: 'new@example.com',
      rentAmount: 4000, isActive: true, moveInDate: 1,
    }));
    await assertSucceeds(updateDoc(doc(db, 'rooms', 'room-vacant'),
      { status: 'occupied', tenantId: 'x', tenantName: 'New' }));
  });

  it('landlord accepts a rental request as one batch', async () => {
    const db = asLandlord();
    const batch = writeBatch(db);
    batch.update(doc(db, 'rentalRequests', 'req-1'),
      { status: 'accepted', respondedAt: 1 });
    batch.set(doc(collection(db, 'tenants')), {
      userId: TENANT_UID, landlordId: LANDLORD, propertyId: PROP,
      roomId: 'room-vacant', roomNumber: '2', name: 'T',
      email: TENANT_EMAIL, emailLower: TENANT_EMAIL,
      rentAmount: 4000, isActive: true, moveInDate: 1,
    });
    batch.update(doc(db, 'rooms', 'room-vacant'),
      { status: 'occupied', tenantId: 'y', tenantName: 'T' });
    batch.update(doc(db, 'listings', 'listing-1'), { isActive: false });
    await assertSucceeds(batch.commit());
  });

  it('landlord restores an archived tenant inside a transaction', async () => {
    // archive first so there is something to restore
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const d = ctx.firestore();
      await updateDoc(doc(d, 'tenants', REC), { isActive: false });
      await updateDoc(doc(d, 'rooms', ROOM),
        { status: 'vacant', tenantId: null, tenantName: null });
    });

    const db = asLandlord();
    await assertSucceeds(runTransaction(db, async (tx) => {
      const roomRef = doc(db, 'rooms', ROOM);
      const snap = await tx.get(roomRef);
      const occupant = snap.data()?.tenantId ?? '';
      if (occupant && occupant !== REC) throw new Error('occupied');
      tx.update(doc(db, 'tenants', REC),
        { isActive: true, moveOutDate: null });
      tx.update(roomRef,
        { status: 'occupied', tenantId: REC, tenantName: 'T' });
    }));
  });

  it('landlord archives a tenant and frees the room', async () => {
    const db = asLandlord();
    await assertSucceeds(updateDoc(doc(db, 'tenants', REC),
      { isActive: false, moveOutDate: 1 }));
    await assertSucceeds(updateDoc(doc(db, 'rooms', ROOM),
      { status: 'vacant', tenantId: null, tenantName: null }));
  });

  it('landlord deletes a property and its rooms', async () => {
    const db = asLandlord();
    await assertSucceeds(deleteDoc(doc(db, 'rooms', 'room-vacant')));
    await assertSucceeds(deleteDoc(doc(db, 'properties', PROP2)));
  });

  it('landlord soft-deletes a house rule', async () => {
    await assertSucceeds(
      updateDoc(doc(asLandlord(), 'rules', 'rule-1'), { isActive: false }));
  });

  it('landlord deactivates a listing', async () => {
    await assertSucceeds(
      updateDoc(doc(asLandlord(), 'listings', 'listing-1'),
        { isActive: false }));
  });

  it('landlord rejects a payment', async () => {
    await assertSucceeds(updateDoc(doc(asLandlord(), 'payments', 'pay-1'), {
      status: 'rejected', rejectionReason: 'wrong amount',
      submittedAt: null, transactionId: null, paymentMethod: null,
    }));
  });

  it('a signed-in user who is not a landlord cannot create a property',
    async () => {
      await assertFails(addDoc(collection(asTenant(), 'properties'),
        { landlordId: TENANT_UID, name: 'Mine' }));
    });
});
