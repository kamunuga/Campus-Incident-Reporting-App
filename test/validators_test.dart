import 'package:flutter_test/flutter_test.dart';

import 'package:campusfix/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts ALU student and staff emails', () {
      expect(Validators.email('jane.doe@alustudent.com'), isNull);
      expect(Validators.email('staff@alueducation.com'), isNull);
      expect(Validators.email('  Jane@ALUSTUDENT.com  '), isNull);
    });

    test('rejects non-ALU and malformed emails', () {
      expect(Validators.email('jane@gmail.com'), isNotNull);
      expect(Validators.email('jane@alustudent.com.fake.io'), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('requires length, a letter and a number', () {
      expect(Validators.password('short1'), isNotNull);
      expect(Validators.password('onlyletters'), isNotNull);
      expect(Validators.password('12345678'), isNotNull);
      expect(Validators.password('campus2026'), isNull);
    });

    test('confirm password must match', () {
      final validator = Validators.confirmPassword(() => 'campus2026');
      expect(validator('campus2026'), isNull);
      expect(validator('campus2025'), 'Passwords do not match');
      expect(validator(''), isNotNull);
    });
  });

  group('Validators.text', () {
    final title = Validators.text(field: 'Title', min: 5, max: 10);

    test('enforces min and max length after trimming', () {
      expect(title('   '), 'Title is required');
      expect(title('abc'), isNotNull);
      expect(title('Leaking'), isNull);
      expect(title('This title is far too long'), isNotNull);
    });
  });
}
