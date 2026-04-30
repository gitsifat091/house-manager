// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../models/listing_model.dart';
// // import '../models/rental_request_model.dart';
// // import '../models/tenant_model.dart';

// // class ListingService {
// //   final _db = FirebaseFirestore.instance;

// //   // ── Listings ────────────────────────────────────────────────

// //   /// Landlord এর সব listings
// //   Stream<List<ListingModel>> getLandlordListings(String landlordId) {
// //     return _db
// //         .collection('listings')
// //         .where('landlordId', isEqualTo: landlordId)
// //         .orderBy('createdAt', descending: true)
// //         .snapshots()
// //         .map((snap) => snap.docs
// //             .map((d) => ListingModel.fromMap(d.data(), d.id))
// //             .toList());
// //   }

// //   /// Public listings — filter by thana/district/division/maxRent
// //   Future<List<ListingModel>> searchListings({
// //     String? division,
// //     String? district,
// //     String? thana,
// //     double? maxRent,
// //     double? minRent,
// //     String? roomType,
// //   }) async {
// //     Query query = _db
// //         .collection('listings')
// //         .where('isActive', isEqualTo: true);

// //     if (division != null && division.isNotEmpty) {
// //       query = query.where('division', isEqualTo: division);
// //     }
// //     if (district != null && district.isNotEmpty) {
// //       query = query.where('district', isEqualTo: district);
// //     }
// //     if (thana != null && thana.isNotEmpty) {
// //       query = query.where('thana', isEqualTo: thana);
// //     }
// //     if (roomType != null && roomType.isNotEmpty && roomType != 'সব') {
// //       query = query.where('roomType', isEqualTo: roomType);
// //     }

// //     final snap = await query.orderBy('createdAt', descending: true).get();
// //     var results = snap.docs
// //         .map((d) => ListingModel.fromMap(d.data() as Map<String, dynamic>, d.id))
// //         .toList();

// //     // Client-side rent filter (Firestore range + inequality index এড়াতে)
// //     if (minRent != null) results = results.where((l) => l.rentAmount >= minRent).toList();
// //     if (maxRent != null) results = results.where((l) => l.rentAmount <= maxRent).toList();

// //     return results;
// //   }

// //   Future<void> addListing(ListingModel listing) async {
// //     await _db.collection('listings').add(listing.toMap());
// //   }

// //   Future<void> updateListing(ListingModel listing) async {
// //     await _db.collection('listings').doc(listing.id).update(listing.toMap());
// //   }

// //   Future<void> deleteListing(String listingId) async {
// //     await _db.collection('listings').doc(listingId).delete();
// //   }

// //   Future<void> deactivateListing(String listingId) async {
// //     await _db.collection('listings').doc(listingId).update({'isActive': false});
// //   }

// //   // ── Rental Requests ─────────────────────────────────────────

// //   /// Landlord এর কাছে আসা requests
// //   Stream<List<RentalRequestModel>> getLandlordRequests(String landlordId) {
// //     return _db
// //         .collection('rentalRequests')
// //         .where('landlordId', isEqualTo: landlordId)
// //         .orderBy('createdAt', descending: true)
// //         .snapshots()
// //         .map((snap) => snap.docs
// //             .map((d) => RentalRequestModel.fromMap(d.data(), d.id))
// //             .toList());
// //   }

// //   /// Tenant এর পাঠানো requests
// //   Stream<List<RentalRequestModel>> getTenantRequests(String tenantUserId) {
// //     return _db
// //         .collection('rentalRequests')
// //         .where('tenantUserId', isEqualTo: tenantUserId)
// //         .orderBy('createdAt', descending: true)
// //         .snapshots()
// //         .map((snap) => snap.docs
// //             .map((d) => RentalRequestModel.fromMap(d.data(), d.id))
// //             .toList());
// //   }

// //   Future<void> sendRequest(RentalRequestModel request) async {
// //     await _db.collection('rentalRequests').add(request.toMap());
// //   }

// //   /// Landlord accept করলে:
// //   /// 1. Request status → accepted
// //   /// 2. Tenant Firestore এ যোগ হবে
// //   /// 3. Room status → occupied
// //   /// 4. Listing → isActive: false
// //   Future<void> acceptRequest(RentalRequestModel request) async {
// //     final batch = _db.batch();
// //     final now = Timestamp.now();

// //     // 1. Request update
// //     final reqRef = _db.collection('rentalRequests').doc(request.id);
// //     batch.update(reqRef, {
// //       'status': 'accepted',
// //       'respondedAt': now,
// //     });

// //     // 2. Tenant যোগ করো
// //     final tenantRef = _db.collection('tenants').doc();
// //     final tenant = TenantModel(
// //       id: tenantRef.id,
// //       name: request.tenantName,
// //       phone: request.tenantPhone,
// //       email: request.tenantEmail,
// //       nidNumber: request.tenantNid,
// //       propertyId: request.propertyId,
// //       propertyName: request.propertyName,
// //       roomId: request.roomId,
// //       roomNumber: request.roomNumber,
// //       rentAmount: request.rentAmount,
// //       moveInDate: DateTime.now(),
// //       isActive: true,
// //       landlordId: request.landlordId,
// //     );
// //     batch.set(tenantRef, tenant.toMap());

// //     // 3. Room → occupied
// //     final roomRef = _db.collection('rooms').doc(request.roomId);
// //     batch.update(roomRef, {
// //       'status': 'occupied',
// //       'tenantId': tenantRef.id,
// //       'tenantName': request.tenantName,
// //     });

// //     // 4. Listing → inactive
// //     final listingRef = _db.collection('listings').doc(request.listingId);
// //     batch.update(listingRef, {'isActive': false});

// //     // 5. অন্য pending requests এই room এর জন্য → rejected
// //     final otherRequests = await _db
// //         .collection('rentalRequests')
// //         .where('roomId', isEqualTo: request.roomId)
// //         .where('status', isEqualTo: 'pending')
// //         .get();
// //     for (final doc in otherRequests.docs) {
// //       if (doc.id != request.id) {
// //         batch.update(doc.reference, {
// //           'status': 'rejected',
// //           'respondedAt': now,
// //         });
// //       }
// //     }

// //     await batch.commit();
// //   }

// //   Future<void> rejectRequest(String requestId) async {
// //     await _db.collection('rentalRequests').doc(requestId).update({
// //       'status': 'rejected',
// //       'respondedAt': Timestamp.now(),
// //     });
// //   }

// //   /// একটি listing এর pending request count
// //   Future<int> getPendingRequestCount(String landlordId) async {
// //     final snap = await _db
// //         .collection('rentalRequests')
// //         .where('landlordId', isEqualTo: landlordId)
// //         .where('status', isEqualTo: 'pending')
// //         .get();
// //     return snap.docs.length;
// //   }
// // }







// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/listing_model.dart';
// import '../models/rental_request_model.dart';
// import '../models/tenant_model.dart';

// class ListingService {
//   final _db = FirebaseFirestore.instance;

//   // ── Listings ────────────────────────────────────────────────

//   /// Landlord এর সব listings
//   Stream<List<ListingModel>> getLandlordListings(String landlordId) {
//     return _db
//         .collection('listings')
//         .where('landlordId', isEqualTo: landlordId)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snap) => snap.docs
//             .map((d) => ListingModel.fromMap(d.data(), d.id))
//             .toList());
//   }

//   /// Public listings — filter by thana/district/division/maxRent
//   Future<List<ListingModel>> searchListings({
//     String? division,
//     String? district,
//     String? thana,
//     double? maxRent,
//     double? minRent,
//     String? roomType,
//   }) async {
//     Query query = _db
//         .collection('listings')
//         .where('isActive', isEqualTo: true);

//     if (division != null && division.isNotEmpty) {
//       query = query.where('division', isEqualTo: division);
//     }
//     if (district != null && district.isNotEmpty) {
//       query = query.where('district', isEqualTo: district);
//     }
//     if (thana != null && thana.isNotEmpty) {
//       query = query.where('thana', isEqualTo: thana);
//     }
//     if (roomType != null && roomType.isNotEmpty && roomType != 'সব') {
//       query = query.where('roomType', isEqualTo: roomType);
//     }

//     final snap = await query.get();
//     var results = snap.docs
//         .map((d) => ListingModel.fromMap(d.data() as Map<String, dynamic>, d.id))
//         .toList();
//     // Client-side sort (Firestore composite index এড়াতে)
//     results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//     // Client-side rent filter (Firestore range + inequality index এড়াতে)
//     if (minRent != null) results = results.where((l) => l.rentAmount >= minRent).toList();
//     if (maxRent != null) results = results.where((l) => l.rentAmount <= maxRent).toList();

//     return results;
//   }

//   Future<void> addListing(ListingModel listing) async {
//     await _db.collection('listings').add(listing.toMap());
//   }

//   Future<void> updateListing(ListingModel listing) async {
//     await _db.collection('listings').doc(listing.id).update(listing.toMap());
//   }

//   Future<void> deleteListing(String listingId) async {
//     await _db.collection('listings').doc(listingId).delete();
//   }

//   Future<void> deactivateListing(String listingId) async {
//     await _db.collection('listings').doc(listingId).update({'isActive': false});
//   }

//   // ── Rental Requests ─────────────────────────────────────────

//   /// Landlord এর কাছে আসা requests
//   Stream<List<RentalRequestModel>> getLandlordRequests(String landlordId) {
//     return _db
//         .collection('rentalRequests')
//         .where('landlordId', isEqualTo: landlordId)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snap) => snap.docs
//             .map((d) => RentalRequestModel.fromMap(d.data(), d.id))
//             .toList());
//   }

//   /// Tenant এর পাঠানো requests
//   Stream<List<RentalRequestModel>> getTenantRequests(String tenantUserId) {
//     return _db
//         .collection('rentalRequests')
//         .where('tenantUserId', isEqualTo: tenantUserId)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snap) => snap.docs
//             .map((d) => RentalRequestModel.fromMap(d.data(), d.id))
//             .toList());
//   }

//   Future<void> sendRequest(RentalRequestModel request) async {
//     await _db.collection('rentalRequests').add(request.toMap());
//   }

//   /// Landlord accept করলে:
//   /// 1. Request status → accepted
//   /// 2. Tenant Firestore এ যোগ হবে
//   /// 3. Room status → occupied
//   /// 4. Listing → isActive: false
//   Future<void> acceptRequest(RentalRequestModel request) async {
//     final batch = _db.batch();
//     final now = Timestamp.now();

//     // 1. Request update
//     final reqRef = _db.collection('rentalRequests').doc(request.id);
//     batch.update(reqRef, {
//       'status': 'accepted',
//       'respondedAt': now,
//     });

//     // 2. Tenant যোগ করো
//     final tenantRef = _db.collection('tenants').doc();
//     final tenant = TenantModel(
//       id: tenantRef.id,
//       name: request.tenantName,
//       phone: request.tenantPhone,
//       email: request.tenantEmail,
//       nidNumber: request.tenantNid,
//       propertyId: request.propertyId,
//       propertyName: request.propertyName,
//       roomId: request.roomId,
//       roomNumber: request.roomNumber,
//       rentAmount: request.rentAmount,
//       moveInDate: DateTime.now(),
//       isActive: true,
//       landlordId: request.landlordId,
//     );
//     batch.set(tenantRef, tenant.toMap());

//     // 3. Room → occupied
//     final roomRef = _db.collection('rooms').doc(request.roomId);
//     batch.update(roomRef, {
//       'status': 'occupied',
//       'tenantId': tenantRef.id,
//       'tenantName': request.tenantName,
//     });

//     // 4. Listing → inactive
//     final listingRef = _db.collection('listings').doc(request.listingId);
//     batch.update(listingRef, {'isActive': false});

//     // 5. অন্য pending requests এই room এর জন্য → rejected
//     final otherRequests = await _db
//         .collection('rentalRequests')
//         .where('roomId', isEqualTo: request.roomId)
//         .where('status', isEqualTo: 'pending')
//         .get();
//     for (final doc in otherRequests.docs) {
//       if (doc.id != request.id) {
//         batch.update(doc.reference, {
//           'status': 'rejected',
//           'respondedAt': now,
//         });
//       }
//     }

//     await batch.commit();
//   }

//   Future<void> rejectRequest(String requestId) async {
//     await _db.collection('rentalRequests').doc(requestId).update({
//       'status': 'rejected',
//       'respondedAt': Timestamp.now(),
//     });
//   }

//   /// একটি listing এর pending request count
//   Future<int> getPendingRequestCount(String landlordId) async {
//     final snap = await _db
//         .collection('rentalRequests')
//         .where('landlordId', isEqualTo: landlordId)
//         .where('status', isEqualTo: 'pending')
//         .get();
//     return snap.docs.length;
//   }
// }







import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../models/rental_request_model.dart';
import '../models/tenant_model.dart';

class ListingService {
  final _db = FirebaseFirestore.instance;

  // ── Listings ────────────────────────────────────────────────

  /// Landlord এর সব listings
  Stream<List<ListingModel>> getLandlordListings(String landlordId) {
    return _db
        .collection('listings')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => ListingModel.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Public listings — filter by thana/district/division/maxRent
  Future<List<ListingModel>> searchListings({
    String? division,
    String? district,
    String? thana,
    double? maxRent,
    double? minRent,
    String? roomType,
  }) async {
    Query query = _db
        .collection('listings')
        .where('isActive', isEqualTo: true);

    if (division != null && division.isNotEmpty) {
      query = query.where('division', isEqualTo: division);
    }
    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }
    if (thana != null && thana.isNotEmpty) {
      query = query.where('thana', isEqualTo: thana);
    }
    if (roomType != null && roomType.isNotEmpty && roomType != 'সব') {
      query = query.where('roomType', isEqualTo: roomType);
    }

    final snap = await query.get();
    var results = snap.docs
        .map((d) => ListingModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
    // Client-side sort (Firestore composite index এড়াতে)
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Client-side rent filter (Firestore range + inequality index এড়াতে)
    if (minRent != null) results = results.where((l) => l.rentAmount >= minRent).toList();
    if (maxRent != null) results = results.where((l) => l.rentAmount <= maxRent).toList();

    return results;
  }

  Future<void> addListing(ListingModel listing) async {
    await _db.collection('listings').add(listing.toMap());
  }

  Future<void> updateListing(ListingModel listing) async {
    await _db.collection('listings').doc(listing.id).update(listing.toMap());
  }

  Future<void> deleteListing(String listingId) async {
    await _db.collection('listings').doc(listingId).delete();
  }

  Future<void> deactivateListing(String listingId) async {
    await _db.collection('listings').doc(listingId).update({'isActive': false});
  }

  // ── Rental Requests ─────────────────────────────────────────

  /// Landlord এর কাছে আসা requests
  Stream<List<RentalRequestModel>> getLandlordRequests(String landlordId) {
    return _db
        .collection('rentalRequests')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => RentalRequestModel.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Tenant এর পাঠানো requests
  Stream<List<RentalRequestModel>> getTenantRequests(String tenantUserId) {
    return _db
        .collection('rentalRequests')
        .where('tenantUserId', isEqualTo: tenantUserId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => RentalRequestModel.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> sendRequest(RentalRequestModel request) async {
    await _db.collection('rentalRequests').add(request.toMap());
  }

  /// Landlord accept করলে:
  /// 1. Request status → accepted
  /// 2. Tenant Firestore এ যোগ হবে
  /// 3. Room status → occupied
  /// 4. Listing → isActive: false
  Future<void> acceptRequest(RentalRequestModel request) async {
    final batch = _db.batch();
    final now = Timestamp.now();

    // 1. Request update
    final reqRef = _db.collection('rentalRequests').doc(request.id);
    batch.update(reqRef, {
      'status': 'accepted',
      'respondedAt': now,
    });

    // 2. Tenant যোগ করো
    final tenantRef = _db.collection('tenants').doc();
    final tenant = TenantModel(
      id: tenantRef.id,
      name: request.tenantName,
      phone: request.tenantPhone,
      email: request.tenantEmail,
      nidNumber: request.tenantNid,
      propertyId: request.propertyId,
      propertyName: request.propertyName,
      roomId: request.roomId,
      roomNumber: request.roomNumber,
      rentAmount: request.rentAmount,
      moveInDate: DateTime.now(),
      isActive: true,
      landlordId: request.landlordId,
    );
    batch.set(tenantRef, tenant.toMap());

    // 3. Room → occupied
    final roomRef = _db.collection('rooms').doc(request.roomId);
    batch.update(roomRef, {
      'status': 'occupied',
      'tenantId': tenantRef.id,
      'tenantName': request.tenantName,
    });

    // 4. Listing → inactive
    final listingRef = _db.collection('listings').doc(request.listingId);
    batch.update(listingRef, {'isActive': false});

    // 5. অন্য pending requests এই room এর জন্য → rejected
    final otherRequests = await _db
        .collection('rentalRequests')
        .where('roomId', isEqualTo: request.roomId)
        .where('status', isEqualTo: 'pending')
        .get();
    for (final doc in otherRequests.docs) {
      if (doc.id != request.id) {
        batch.update(doc.reference, {
          'status': 'rejected',
          'respondedAt': now,
        });
      }
    }

    await batch.commit();
  }

  Future<void> rejectRequest(String requestId) async {
    await _db.collection('rentalRequests').doc(requestId).update({
      'status': 'rejected',
      'respondedAt': Timestamp.now(),
    });
  }

  /// একটি listing এর pending request count
  Future<int> getPendingRequestCount(String landlordId) async {
    final snap = await _db
        .collection('rentalRequests')
        .where('landlordId', isEqualTo: landlordId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.length;
  }
}