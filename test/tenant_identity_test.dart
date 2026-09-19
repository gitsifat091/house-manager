import 'package:flutter_test/flutter_test.dart';
import 'package:house_manager/models/tenant_model.dart';

void main() {
  group('TenantModel.normaliseEmail', () {
    test('lowercases and trims', () {
      expect(TenantModel.normaliseEmail('  Ali@Gmail.COM '), 'ali@gmail.com');
    });

    test('collapses the casing variants that used to break lookups', () {
      const variants = [
        'Ali@Gmail.com',
        'ali@gmail.com',
        'ALI@GMAIL.COM',
        ' ali@Gmail.com ',
      ];
      final normalised = variants.map(TenantModel.normaliseEmail).toSet();
      expect(normalised, hasLength(1));
      expect(normalised.single, 'ali@gmail.com');
    });

    test('handles an empty email without throwing', () {
      expect(TenantModel.normaliseEmail('   '), '');
    });
  });

  group('TenantModel serialisation', () {
    TenantModel build({String userId = '', String email = 'A@B.com'}) =>
        TenantModel(
          id: 'doc1',
          userId: userId,
          name: 'Test',
          phone: '01700000000',
          email: email,
          nidNumber: '123',
          propertyId: 'p1',
          propertyName: 'Property',
          roomId: 'r1',
          roomNumber: '2B',
          rentAmount: 5000,
          moveInDate: DateTime(2026, 1, 1),
          landlordId: 'l1',
        );

    test('writes userId so the record is linked to an account', () {
      expect(build(userId: 'uid-123').toMap()['userId'], 'uid-123');
    });

    test('defaults userId to empty, marking the record unclaimed', () {
      expect(build().toMap()['userId'], '');
      expect(build().userId, '');
    });

    test('derives emailLower from email so the two cannot drift', () {
      final map = build(email: '  Ali@Gmail.COM ').toMap();
      expect(map['email'], '  Ali@Gmail.COM ');
      expect(map['emailLower'], 'ali@gmail.com');
    });

    test('round-trips userId through fromMap', () {
      final map = build(userId: 'uid-123').toMap();
      final parsed = TenantModel.fromMap(map, 'doc1');
      expect(parsed.userId, 'uid-123');
    });

    test('reads legacy records that predate userId as unclaimed', () {
      final legacy = <String, dynamic>{
        'name': 'Old Tenant',
        'email': 'Old@Example.com',
        'phone': '1',
        'nidNumber': '2',
        'propertyId': 'p',
        'propertyName': 'P',
        'roomId': 'r',
        'roomNumber': '1',
        'rentAmount': 100,
        'moveInDate': DateTime(2026, 1, 1).millisecondsSinceEpoch,
        'landlordId': 'l',
      };
      final parsed = TenantModel.fromMap(legacy, 'legacy1');
      expect(parsed.userId, '');
      expect(
        TenantModel.normaliseEmail(parsed.email),
        'old@example.com',
        reason: 'the claim pass matches legacy records on the normalised email',
      );
    });
  });
}
