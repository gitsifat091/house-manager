// Firestore security rules tests.
//
//   cd test/rules && npm install && npm test
//
// Runs against the Firestore emulator via `firebase emulators:exec`, so it
// needs no real project and touches no real data.

import assert from 'node:assert/strict';
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
  deleteDoc,
  addDoc,
  collection,
  query,
  where,
  getDocs,
} from 'firebase/firestore';

let testEnv;

// ── Fixture identities ───────────────────────────────────────────
const LANDLORD_A = 'landlord-a';
const LANDLORD_B = 'landlord-b';
const TENANT_A = 'tenant-a-uid';
const TENANT_B = 'tenant-b-uid';
const STRANGER = 'stranger-uid';

const TENANT_A_EMAIL = 'alice@example.com';
const TENANT_B_EMAIL = 'bob@example.com';
const UNCLAIMED_EMAIL = 'carol@example.com';

// Tenant record ids
const REC_A = 'tenant-rec-a';
const REC_B = 'tenant-rec-b';
const REC_UNCLAIMED = 'tenant-rec-unclaimed';
const REC_LEGACY = 'tenant-rec-legacy';

const PROP_A = 'prop-a';
const PROP_B = 'prop-b';

const asLandlordA = () => testEnv.authenticatedContext(LANDLORD_A).firestore();
const asLandlordB = () => testEnv.authenticatedContext(LANDLORD_B).firestore();
const asTenantA = () =>
  testEnv.authenticatedContext(TENANT_A, { email: TENANT_A_EMAIL }).firestore();
const asTenantB = () =>
  testEnv.authenticatedContext(TENANT_B, { email: TENANT_B_EMAIL }).firestore();
const asStranger = () =>
  testEnv
    .authenticatedContext(STRANGER, { email: UNCLAIMED_EMAIL })
    .firestore();
const asAnon = () => testEnv.unauthenticatedContext().firestore();

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'house-manager-test',
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

    await setDoc(doc(db, 'users', LANDLORD_A), {
      uid: LANDLORD_A, role: 'landlord', name: 'Landlord A', email: 'la@x.com',
    });
    await setDoc(doc(db, 'users', LANDLORD_B), {
      uid: LANDLORD_B, role: 'landlord', name: 'Landlord B', email: 'lb@x.com',
    });
    await setDoc(doc(db, 'users', TENANT_A), {
      uid: TENANT_A, role: 'tenant', name: 'Alice', email: TENANT_A_EMAIL,
      tenantDocId: REC_A,
    });
    await setDoc(doc(db, 'users', TENANT_B), {
      uid: TENANT_B, role: 'tenant', name: 'Bob', email: TENANT_B_EMAIL,
      tenantDocId: REC_B,
    });
    await setDoc(doc(db, 'users', STRANGER), {
      uid: STRANGER, role: 'tenant', name: 'Carol', email: UNCLAIMED_EMAIL,
    });

    await setDoc(doc(db, 'publicProfiles', LANDLORD_A), {
      name: 'Landlord A', photoUrl: null,
    });
    await setDoc(doc(db, 'publicProfiles', LANDLORD_B), {
      name: 'Landlord B', photoUrl: null,
    });
    await setDoc(doc(db, 'publicProfiles', TENANT_A), {
      name: 'Alice', photoUrl: null,
    });

    await setDoc(doc(db, 'properties', PROP_A), {
      landlordId: LANDLORD_A, name: 'House A',
    });
    await setDoc(doc(db, 'properties', PROP_B), {
      landlordId: LANDLORD_B, name: 'House B',
    });

    await setDoc(doc(db, 'tenants', REC_A), {
      userId: TENANT_A, landlordId: LANDLORD_A, propertyId: PROP_A,
      roomId: 'room-a', roomNumber: '1A', name: 'Alice',
      email: TENANT_A_EMAIL, emailLower: TENANT_A_EMAIL,
      nidNumber: '111', rentAmount: 5000, isActive: true, hasEdited: false,
    });
    await setDoc(doc(db, 'tenants', REC_B), {
      userId: TENANT_B, landlordId: LANDLORD_B, propertyId: PROP_B,
      roomId: 'room-b', roomNumber: '1B', name: 'Bob',
      email: TENANT_B_EMAIL, emailLower: TENANT_B_EMAIL,
      nidNumber: '222', rentAmount: 6000, isActive: true, hasEdited: false,
    });
    // Created by a landlord for someone who has not signed in yet.
    await setDoc(doc(db, 'tenants', REC_UNCLAIMED), {
      userId: '', landlordId: LANDLORD_A, propertyId: PROP_A,
      roomId: 'room-c', roomNumber: '1C', name: 'Carol',
      email: UNCLAIMED_EMAIL, emailLower: UNCLAIMED_EMAIL,
      nidNumber: '333', rentAmount: 4000, isActive: true,
    });
    // Predates emailLower, and was typed with different casing.
    await setDoc(doc(db, 'tenants', REC_LEGACY), {
      landlordId: LANDLORD_A, propertyId: PROP_A, roomId: 'room-d',
      roomNumber: '1D', name: 'Carol Legacy', email: 'Carol@Example.com',
      nidNumber: '444', rentAmount: 4500, isActive: true,
    });

    await setDoc(doc(db, 'rooms', 'room-a'), {
      propertyId: PROP_A, roomNumber: '1A', status: 'occupied',
      tenantId: REC_A, tenantName: 'Alice', rentAmount: 5000,
    });
    await setDoc(doc(db, 'rooms', 'room-b'), {
      propertyId: PROP_B, roomNumber: '1B', status: 'occupied',
      tenantId: REC_B, tenantName: 'Bob', rentAmount: 6000,
    });

    await setDoc(doc(db, 'payments', 'pay-a'), {
      landlordId: LANDLORD_A, tenantId: REC_A, tenantName: 'Alice',
      amount: 5000, month: 1, year: 2026, status: 'pending',
    });
    await setDoc(doc(db, 'payments', 'pay-b'), {
      landlordId: LANDLORD_B, tenantId: REC_B, tenantName: 'Bob',
      amount: 6000, month: 1, year: 2026, status: 'pending',
    });

    await setDoc(doc(db, 'utilities', 'util-a'), {
      landlordId: LANDLORD_A, tenantId: REC_A, amount: 500,
      month: 1, year: 2026, isPaid: false, isSubmitted: false,
    });

    await setDoc(doc(db, 'notices', 'notice-a'), {
      landlordId: LANDLORD_A, title: 'Notice', body: 'Body',
    });
    await setDoc(doc(db, 'rules', 'rule-a'), {
      landlordId: LANDLORD_A, title: 'Rule', description: 'D', isActive: true,
    });

    await setDoc(doc(db, 'chatRooms', 'chat-a'), {
      landlordId: LANDLORD_A, tenantId: REC_A, tenantName: 'Alice',
      unreadLandlord: 0, unreadTenant: 0,
    });
    await setDoc(doc(db, 'chatRooms', 'chat-a', 'messages', 'm1'), {
      senderId: LANDLORD_A, senderName: 'Landlord A', text: 'Hello',
      createdAt: 1, isRead: false,
    });

    await setDoc(doc(db, 'communityChats', PROP_A, 'messages', 'cm1'), {
      senderId: TENANT_A, senderName: 'Alice', senderRole: 'tenant',
      message: 'Hi all', createdAt: 1,
    });

    await setDoc(doc(db, 'notifications', 'notif-a'), {
      userId: LANDLORD_A, title: 'T', body: 'B', isRead: false,
      createdAt: 1, type: 'payment',
    });

    await setDoc(doc(db, 'listings', 'listing-a'), {
      landlordId: LANDLORD_A, propertyId: PROP_A, roomId: 'room-c',
      isActive: true, rentAmount: 4000, district: 'Dhaka',
    });
  });
});

// ─────────────────────────────────────────────────────────────────
describe('unauthenticated access', () => {
  it('cannot read tenants', async () => {
    await assertFails(getDoc(doc(asAnon(), 'tenants', REC_A)));
  });

  it('cannot read payments', async () => {
    await assertFails(getDoc(doc(asAnon(), 'payments', 'pay-a')));
  });

  it('cannot read users', async () => {
    await assertFails(getDoc(doc(asAnon(), 'users', LANDLORD_A)));
  });

  it('cannot read public profiles either', async () => {
    await assertFails(getDoc(doc(asAnon(), 'publicProfiles', LANDLORD_A)));
  });

  it('cannot write anything', async () => {
    await assertFails(
      setDoc(doc(asAnon(), 'tenants', 'injected'), { name: 'x' }),
    );
  });
});

// ─────────────────────────────────────────────────────────────────
describe('landlord isolation', () => {
  it('reads own tenants', async () => {
    await assertSucceeds(
      getDocs(query(collection(asLandlordA(), 'tenants'),
        where('landlordId', '==', LANDLORD_A))),
    );
  });

  it('cannot read another landlord tenant record', async () => {
    await assertFails(getDoc(doc(asLandlordA(), 'tenants', REC_B)));
  });

  it('cannot list all tenants without an ownership filter', async () => {
    await assertFails(getDocs(collection(asLandlordA(), 'tenants')));
  });

  it('cannot query another landlord tenants', async () => {
    await assertFails(
      getDocs(query(collection(asLandlordA(), 'tenants'),
        where('landlordId', '==', LANDLORD_B))),
    );
  });

  it('cannot read another landlord payments', async () => {
    await assertFails(getDoc(doc(asLandlordA(), 'payments', 'pay-b')));
  });

  it('cannot read another landlord property', async () => {
    await assertFails(getDoc(doc(asLandlordA(), 'properties', PROP_B)));
  });

  it('cannot write into another landlord property rooms', async () => {
    await assertFails(
      updateDoc(doc(asLandlordA(), 'rooms', 'room-b'), { rentAmount: 1 }),
    );
  });

  it('cannot create a tenant record owned by another landlord', async () => {
    await assertFails(
      addDoc(collection(asLandlordA(), 'tenants'),
        { landlordId: LANDLORD_B, name: 'x', email: 'x@y.com' }),
    );
  });

  it('can update a room in its own property', async () => {
    await assertSucceeds(
      updateDoc(doc(asLandlordA(), 'rooms', 'room-a'), { status: 'vacant' }),
    );
  });
});

// ─────────────────────────────────────────────────────────────────
describe('tenant data access', () => {
  it('reads own tenant record', async () => {
    await assertSucceeds(getDoc(doc(asTenantA(), 'tenants', REC_A)));
  });

  it('cannot read another tenant record', async () => {
    await assertFails(getDoc(doc(asTenantA(), 'tenants', REC_B)));
  });

  it('cannot enumerate tenants of its own landlord', async () => {
    await assertFails(
      getDocs(query(collection(asTenantA(), 'tenants'),
        where('landlordId', '==', LANDLORD_A))),
    );
  });

  it('reads own payments', async () => {
    await assertSucceeds(
      getDocs(query(collection(asTenantA(), 'payments'),
        where('tenantId', '==', REC_A))),
    );
  });

  it('cannot read another tenant payments', async () => {
    await assertFails(
      getDocs(query(collection(asTenantA(), 'payments'),
        where('tenantId', '==', REC_B))),
    );
  });

  it('reads its own room', async () => {
    await assertSucceeds(getDoc(doc(asTenantA(), 'rooms', 'room-a')));
  });

  it('cannot read a room it does not occupy', async () => {
    await assertFails(getDoc(doc(asTenantA(), 'rooms', 'room-b')));
  });

  it('reads notices from its own landlord', async () => {
    await assertSucceeds(
      getDocs(query(collection(asTenantA(), 'notices'),
        where('landlordId', '==', LANDLORD_A))),
    );
  });

  it('cannot read notices from another landlord', async () => {
    await assertFails(
      getDocs(query(collection(asTenantB(), 'notices'),
        where('landlordId', '==', LANDLORD_A))),
    );
  });
});

// ─────────────────────────────────────────────────────────────────
describe('tenant privilege limits', () => {
  it('can submit a payment', async () => {
    await assertSucceeds(
      updateDoc(doc(asTenantA(), 'payments', 'pay-a'), {
        status: 'submitted', submittedAt: 1, paymentMethod: 'bKash',
        transactionId: 'TX1', note: null,
      }),
    );
  });

  it('cannot mark its own payment paid', async () => {
    await assertFails(
      updateDoc(doc(asTenantA(), 'payments', 'pay-a'),
        { status: 'paid', paidAt: 1 }),
    );
  });

  it('cannot change the amount owed', async () => {
    await assertFails(
      updateDoc(doc(asTenantA(), 'payments', 'pay-a'),
        { status: 'submitted', amount: 1 }),
    );
  });

  it('cannot delete a payment', async () => {
    await assertFails(deleteDoc(doc(asTenantA(), 'payments', 'pay-a')));
  });

  it('cannot create a payment', async () => {
    await assertFails(
      addDoc(collection(asTenantA(), 'payments'), {
        landlordId: LANDLORD_A, tenantId: REC_A, amount: 0,
        month: 2, year: 2026, status: 'paid',
      }),
    );
  });

  it('can submit a utility bill', async () => {
    await assertSucceeds(
      updateDoc(doc(asTenantA(), 'utilities', 'util-a'), {
        isSubmitted: true, paymentMethod: 'bKash', submissionNote: 'done',
      }),
    );
  });

  it('cannot mark a utility bill paid', async () => {
    await assertFails(
      updateDoc(doc(asTenantA(), 'utilities', 'util-a'), { isPaid: true }),
    );
  });

  it('can edit its own profile fields', async () => {
    await assertSucceeds(
      updateDoc(doc(asTenantA(), 'tenants', REC_A),
        { name: 'Alice2', phone: '01711', hasEdited: true }),
    );
  });

  it('cannot raise or lower its own rent', async () => {
    await assertFails(
      updateDoc(doc(asTenantA(), 'tenants', REC_A), { rentAmount: 1 }),
    );
  });

  it('cannot move itself to another room', async () => {
    await assertFails(
      updateDoc(doc(asTenantA(), 'tenants', REC_A), { roomId: 'room-b' }),
    );
  });

  it('cannot reassign itself to another landlord', async () => {
    await assertFails(
      updateDoc(doc(asTenantA(), 'tenants', REC_A),
        { landlordId: LANDLORD_B }),
    );
  });

  it('cannot reactivate itself after being archived', async () => {
    await assertFails(
      updateDoc(doc(asTenantA(), 'tenants', REC_A), { isActive: false }),
    );
  });

  it('cannot delete its own tenant record', async () => {
    await assertFails(deleteDoc(doc(asTenantA(), 'tenants', REC_A)));
  });

  it('can rename itself on its room but change nothing else', async () => {
    await assertSucceeds(
      updateDoc(doc(asTenantA(), 'rooms', 'room-a'), { tenantName: 'Alice2' }),
    );
    await assertFails(
      updateDoc(doc(asTenantA(), 'rooms', 'room-a'), { rentAmount: 1 }),
    );
  });

  it('cannot promote itself to landlord', async () => {
    await assertFails(
      updateDoc(doc(asTenantA(), 'users', TENANT_A), { role: 'landlord' }),
    );
  });

  it('cannot edit another user profile', async () => {
    await assertFails(
      updateDoc(doc(asTenantA(), 'users', LANDLORD_A), { name: 'hacked' }),
    );
  });
});

// ─────────────────────────────────────────────────────────────────
describe('claiming an unowned tenant record', () => {
  it('finds an unowned record matching its verified email', async () => {
    await assertSucceeds(
      getDocs(query(collection(asStranger(), 'tenants'),
        where('emailLower', '==', UNCLAIMED_EMAIL))),
    );
  });

  it('claims that record by setting userId to itself', async () => {
    await assertSucceeds(
      updateDoc(doc(asStranger(), 'tenants', REC_UNCLAIMED), {
        userId: STRANGER, emailLower: UNCLAIMED_EMAIL,
      }),
    );
  });

  it('claims a legacy record whose email differs only in casing', async () => {
    await assertSucceeds(
      updateDoc(doc(asStranger(), 'tenants', REC_LEGACY), {
        userId: STRANGER, emailLower: UNCLAIMED_EMAIL,
      }),
    );
  });

  it('cannot claim a record belonging to somebody else', async () => {
    await assertFails(
      updateDoc(doc(asStranger(), 'tenants', REC_A), { userId: STRANGER }),
    );
  });

  it('cannot claim a record whose email is not its own', async () => {
    await assertFails(
      updateDoc(doc(asTenantB(), 'tenants', REC_UNCLAIMED),
        { userId: TENANT_B }),
    );
  });

  it('cannot read an unowned record belonging to a different email', async () => {
    await assertFails(
      getDocs(query(collection(asTenantB(), 'tenants'),
        where('emailLower', '==', UNCLAIMED_EMAIL))),
    );
  });

  it('cannot enumerate every unowned record', async () => {
    await assertFails(
      getDocs(query(collection(asStranger(), 'tenants'),
        where('userId', '==', ''))),
    );
  });

  it('cannot smuggle other changes into a claim', async () => {
    await assertFails(
      updateDoc(doc(asStranger(), 'tenants', REC_UNCLAIMED), {
        userId: STRANGER, rentAmount: 1,
      }),
    );
  });

  it('cannot claim a record on behalf of another uid', async () => {
    await assertFails(
      updateDoc(doc(asStranger(), 'tenants', REC_UNCLAIMED),
        { userId: TENANT_B }),
    );
  });
});

// ─────────────────────────────────────────────────────────────────
describe('profile visibility', () => {
  it('anyone signed in reads a public profile', async () => {
    await assertSucceeds(
      getDoc(doc(asTenantB(), 'publicProfiles', LANDLORD_A)));
  });

  it('a stranger sees only a name and a picture', async () => {
    // What another user actually receives. Guards against the collection
    // quietly growing into a second copy of the user record.
    const snap = await getDoc(doc(asTenantB(), 'publicProfiles', LANDLORD_A));
    assert.deepEqual(Object.keys(snap.data()).sort(), ['name', 'photoUrl']);
  });

  it('cannot read a stranger full user record', async () => {
    await assertFails(getDoc(doc(asTenantB(), 'users', LANDLORD_A)));
  });

  it('cannot read another tenant full user record', async () => {
    await assertFails(getDoc(doc(asTenantA(), 'users', TENANT_B)));
  });

  it('a tenant reads its own landlord record, for contact details', async () => {
    await assertSucceeds(getDoc(doc(asTenantA(), 'users', LANDLORD_A)));
  });

  it('a tenant cannot read a landlord it does not rent from', async () => {
    await assertFails(getDoc(doc(asTenantA(), 'users', LANDLORD_B)));
  });

  it('a landlord cannot read its own tenant full user record', async () => {
    await assertFails(getDoc(doc(asLandlordA(), 'users', TENANT_A)));
  });

  it('the users collection cannot be queried at all', async () => {
    await assertFails(getDocs(query(
      collection(asLandlordA(), 'users'),
      where('email', '==', TENANT_A_EMAIL))));
    await assertFails(getDocs(collection(asLandlordA(), 'users')));
  });

  it('cannot write somebody else public profile', async () => {
    await assertFails(setDoc(doc(asTenantA(), 'publicProfiles', LANDLORD_A),
      { name: 'hacked', photoUrl: null }));
  });

  it('cannot smuggle extra fields into a public profile', async () => {
    await assertFails(setDoc(doc(asTenantA(), 'publicProfiles', TENANT_A),
      { name: 'Alice', photoUrl: null, phone: '01700000000' }));
  });

  it('cannot delete a public profile', async () => {
    await assertFails(deleteDoc(doc(asTenantA(), 'publicProfiles', TENANT_A)));
  });

  it('still cannot promote itself to landlord', async () => {
    await assertFails(
      updateDoc(doc(asTenantA(), 'users', TENANT_A), { role: 'landlord' }));
  });
});

// ─────────────────────────────────────────────────────────────────
describe('chat', () => {
  it('participants read the room', async () => {
    await assertSucceeds(getDoc(doc(asLandlordA(), 'chatRooms', 'chat-a')));
    await assertSucceeds(getDoc(doc(asTenantA(), 'chatRooms', 'chat-a')));
  });

  it('outsiders cannot read the room', async () => {
    await assertFails(getDoc(doc(asTenantB(), 'chatRooms', 'chat-a')));
    await assertFails(getDoc(doc(asLandlordB(), 'chatRooms', 'chat-a')));
  });

  it('participants read messages', async () => {
    await assertSucceeds(
      getDocs(collection(asTenantA(), 'chatRooms', 'chat-a', 'messages')),
    );
  });

  it('outsiders cannot read messages', async () => {
    await assertFails(
      getDocs(collection(asTenantB(), 'chatRooms', 'chat-a', 'messages')),
    );
  });

  it('a participant sends a message as itself', async () => {
    await assertSucceeds(
      addDoc(collection(asTenantA(), 'chatRooms', 'chat-a', 'messages'), {
        senderId: TENANT_A, senderName: 'Alice', text: 'Hi',
        createdAt: 2, isRead: false,
      }),
    );
  });

  it('cannot send a message impersonating someone else', async () => {
    await assertFails(
      addDoc(collection(asTenantA(), 'chatRooms', 'chat-a', 'messages'), {
        senderId: LANDLORD_A, senderName: 'Landlord A', text: 'Fake',
        createdAt: 2, isRead: false,
      }),
    );
  });

  it('outsiders cannot post into the room', async () => {
    await assertFails(
      addDoc(collection(asTenantB(), 'chatRooms', 'chat-a', 'messages'), {
        senderId: TENANT_B, senderName: 'Bob', text: 'Intruder',
        createdAt: 2, isRead: false,
      }),
    );
  });

  it('messages cannot be edited or deleted', async () => {
    await assertFails(
      updateDoc(doc(asLandlordA(), 'chatRooms', 'chat-a', 'messages', 'm1'),
        { text: 'edited' }),
    );
    await assertFails(
      deleteDoc(doc(asLandlordA(), 'chatRooms', 'chat-a', 'messages', 'm1')),
    );
  });
});

// ─────────────────────────────────────────────────────────────────
describe('community chat', () => {
  it('an active tenant of the property reads it', async () => {
    await assertSucceeds(
      getDocs(collection(asTenantA(), 'communityChats', PROP_A, 'messages')),
    );
  });

  it('the property landlord reads it', async () => {
    await assertSucceeds(
      getDocs(collection(asLandlordA(), 'communityChats', PROP_A, 'messages')),
    );
  });

  it('a tenant of a different property cannot read it', async () => {
    await assertFails(
      getDocs(collection(asTenantB(), 'communityChats', PROP_A, 'messages')),
    );
  });

  it('a different landlord cannot read it', async () => {
    await assertFails(
      getDocs(collection(asLandlordB(), 'communityChats', PROP_A, 'messages')),
    );
  });

  it('an archived tenant loses access', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'tenants', REC_A),
        { isActive: false });
    });
    await assertFails(
      getDocs(collection(asTenantA(), 'communityChats', PROP_A, 'messages')),
    );
  });

  it('a member posts as itself', async () => {
    await assertSucceeds(
      addDoc(collection(asTenantA(), 'communityChats', PROP_A, 'messages'), {
        senderId: TENANT_A, senderName: 'Alice', senderRole: 'tenant',
        message: 'Hello', createdAt: 2,
      }),
    );
  });

  it('a non-member cannot post', async () => {
    await assertFails(
      addDoc(collection(asTenantB(), 'communityChats', PROP_A, 'messages'), {
        senderId: TENANT_B, senderName: 'Bob', senderRole: 'tenant',
        message: 'Intruder', createdAt: 2,
      }),
    );
  });
});

// ─────────────────────────────────────────────────────────────────
describe('notifications', () => {
  it('reads only its own', async () => {
    await assertSucceeds(
      getDocs(query(collection(asLandlordA(), 'notifications'),
        where('userId', '==', LANDLORD_A))),
    );
  });

  it('cannot read notifications addressed to others', async () => {
    await assertFails(
      getDocs(query(collection(asTenantA(), 'notifications'),
        where('userId', '==', LANDLORD_A))),
    );
  });

  it('a tenant may notify its landlord', async () => {
    await assertSucceeds(
      addDoc(collection(asTenantA(), 'notifications'), {
        userId: LANDLORD_A, title: 'Payment', body: 'Submitted',
        isRead: false, createdAt: 1, type: 'payment',
      }),
    );
  });

  it('cannot create one already marked read', async () => {
    await assertFails(
      addDoc(collection(asTenantA(), 'notifications'), {
        userId: LANDLORD_A, title: 'x', body: 'y',
        isRead: true, createdAt: 1, type: 'payment',
      }),
    );
  });

  it('cannot stuff extra fields into a notification', async () => {
    await assertFails(
      addDoc(collection(asTenantA(), 'notifications'), {
        userId: LANDLORD_A, title: 'x', body: 'y', isRead: false,
        createdAt: 1, type: 'payment', payload: 'unexpected',
      }),
    );
  });

  it('marks its own notification read', async () => {
    await assertSucceeds(
      updateDoc(doc(asLandlordA(), 'notifications', 'notif-a'),
        { isRead: true }),
    );
  });

  it('cannot rewrite a notification body', async () => {
    await assertFails(
      updateDoc(doc(asLandlordA(), 'notifications', 'notif-a'),
        { body: 'changed' }),
    );
  });
});

// ─────────────────────────────────────────────────────────────────
describe('listings and rental requests', () => {
  it('any signed-in user browses active listings', async () => {
    await assertSucceeds(
      getDocs(query(collection(asTenantB(), 'listings'),
        where('isActive', '==', true))),
    );
  });

  it('a non-owner cannot edit a listing', async () => {
    await assertFails(
      updateDoc(doc(asTenantB(), 'listings', 'listing-a'),
        { rentAmount: 1 }),
    );
  });

  it('a tenant sends a rental request as itself', async () => {
    await assertSucceeds(
      addDoc(collection(asTenantB(), 'rentalRequests'), {
        tenantUserId: TENANT_B, landlordId: LANDLORD_A, listingId: 'listing-a',
        roomId: 'room-c', propertyId: PROP_A, status: 'pending',
        tenantName: 'Bob', tenantEmail: TENANT_B_EMAIL,
      }),
    );
  });

  it('cannot send a request on behalf of someone else', async () => {
    await assertFails(
      addDoc(collection(asTenantB(), 'rentalRequests'), {
        tenantUserId: TENANT_A, landlordId: LANDLORD_A, listingId: 'listing-a',
        roomId: 'room-c', status: 'pending',
      }),
    );
  });

  it('cannot self-accept a request', async () => {
    await assertFails(
      addDoc(collection(asTenantB(), 'rentalRequests'), {
        tenantUserId: TENANT_B, landlordId: LANDLORD_A, listingId: 'listing-a',
        roomId: 'room-c', status: 'accepted',
      }),
    );
  });
});
