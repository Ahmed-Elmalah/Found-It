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

  group('isValidFullName', () {
    test('2+ characters is valid', () {
      expect(Validators.isValidFullName('Al'), isTrue);
      expect(Validators.isValidFullName('أحمد علي'), isTrue);
    });
    test('null, empty, 1 char or spaces is invalid', () {
      expect(Validators.isValidFullName(null), isFalse);
      expect(Validators.isValidFullName(''), isFalse);
      expect(Validators.isValidFullName(' A '), isFalse);
    });
  });

  group('Egyptian phone', () {
    test('accepted formats all normalize to +20XXXXXXXXXX', () {
      for (final input in [
        '1012345678',
        '10 1234 5678',
        '01012345678',
        '010-1234-5678',
        '+201012345678',
        '201012345678',
      ]) {
        expect(
          Validators.normalizeEgyptianPhone(input),
          '+201012345678',
          reason: input,
        );
        expect(Validators.isValidEgyptianPhone(input), isTrue, reason: input);
      }
    });
    test('all Egyptian mobile prefixes (10, 11, 12, 15)', () {
      for (final p in ['10', '11', '12', '15']) {
        expect(Validators.isValidEgyptianPhone('${p}12345678'), isTrue);
      }
    });
    test('invalid numbers', () {
      for (final input in [
        null,
        '',
        '1312345678', // 13 is not a mobile prefix
        '101234567', // 9 digits
        '10123456789', // 11 digits without leading 0
        '0201012345678',
        'abc',
      ]) {
        expect(Validators.isValidEgyptianPhone(input), isFalse, reason: input);
        expect(Validators.normalizeEgyptianPhone(input), isNull);
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
