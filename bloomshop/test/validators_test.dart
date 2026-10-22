import 'package:flutter_test/flutter_test.dart';

import 'package:bloomshop/core/utils/validators.dart';

void main() {
  group('email', () {
    test('accepts valid emails', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('first.last+tag@mail.co.id'), isNull);
    });
    test('rejects invalid emails', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('no-at-sign'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });
  });

  group('passwords', () {
    test('login password required', () {
      expect(Validators.loginPassword(''), isNotNull);
      expect(Validators.loginPassword('x'), isNull);
    });
    test('new password min length and confirmation', () {
      expect(Validators.newPassword('12345'), isNotNull);
      expect(Validators.newPassword('123456'), isNull);
      expect(Validators.confirmPassword('abc', 'abd'), isNotNull);
      expect(Validators.confirmPassword('abc', 'abc'), isNull);
    });
  });

  group('checkout form', () {
    test('valid data has no errors', () {
      final errors = Validators.checkoutErrors(
        name: 'Ayu Lestari',
        phone: '0812-3456-7890',
        address: 'Jl. Mawar No. 12, Madiun',
      );
      expect(errors, isEmpty);
    });
    test('missing or bad data is reported per field', () {
      final errors = Validators.checkoutErrors(
        name: '',
        phone: '123',
        address: 'short',
      );
      expect(errors.keys, containsAll(['name', 'phone', 'address']));
    });
  });
}
