import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/utils/validators.dart';

void main() {
  group('isNotEmpty', () {
    test('null, empty and spaces are empty', () {
      expect(Validators.isNotEmpty(null), isFalse);
      expect(Validators.isNotEmpty(''), isFalse);
      expect(Validators.isNotEmpty('   '), isFalse);
    });
    test('text is not empty', () => expect(Validators.isNotEmpty('a'), isTrue));
  });

  group('isValidEmail', () {
    test('valid emails', () {
      for (final email in [
        'user@example.com',
        'test@foundit.com',
        'a.b+c@mail.co.uk',
        '  user@example.com  ',
      ]) {
        expect(Validators.isValidEmail(email), isTrue, reason: email);
      }
    });
    test('invalid emails', () {
      for (final email in [
        null,
        '',
        'user',
        'user@',
        '@example.com',
        'user@example',
        'user@example.c',
        'us er@example.com',
        'user@@example.com',
      ]) {
        expect(Validators.isValidEmail(email), isFalse, reason: '$email');
      }
    });
  });

  group('isValidPassword', () {
    test('8+ characters is valid', () {
      expect(Validators.isValidPassword('12345678'), isTrue);
    });
    test('null or shorter than 8 is invalid', () {
      expect(Validators.isValidPassword(null), isFalse);
      expect(Validators.isValidPassword('1234567'), isFalse);
    });
  });
}
