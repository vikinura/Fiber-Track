import 'package:fibertrack/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormValidators', () {
    test('required should return error message when null or empty', () {
      expect(FormValidators.required(null), 'Field ini wajib diisi');
      expect(FormValidators.required(''), 'Field ini wajib diisi');
      expect(FormValidators.required('   '), 'Field ini wajib diisi');
      expect(FormValidators.required('valid value'), isNull);
    });

    test('email validator should validate format correctly', () {
      expect(FormValidators.email(null), 'Email wajib diisi');
      expect(FormValidators.email(''), 'Email wajib diisi');
      expect(FormValidators.email('invalid-email'), 'Format email tidak valid');
      expect(FormValidators.email('user@domain'), 'Format email tidak valid');
      expect(FormValidators.email('user@example.com'), isNull);
      expect(FormValidators.email('admin.nusa@fibertrack.id'), isNull);
    });

    test('minLength validator should validate string length', () {
      expect(FormValidators.minLength(null, 8), 'Minimal 8 karakter');
      expect(FormValidators.minLength('1234567', 8), 'Minimal 8 karakter');
      expect(FormValidators.minLength('12345678', 8), isNull);
      expect(FormValidators.minLength('123456789', 8), isNull);
    });

    test('maxLength validator should validate maximum length', () {
      expect(FormValidators.maxLength('12345', 5), isNull);
      expect(FormValidators.maxLength('123456', 5), 'Maksimal 5 karakter');
      expect(FormValidators.maxLength(null, 5), isNull);
    });

    test('range validator should validate numerical boundaries', () {
      expect(FormValidators.range(null, 1, 10), 'Nilai wajib diisi');
      expect(FormValidators.range(0, 1, 10), 'Nilai harus di antara 1 dan 10');
      expect(FormValidators.range(11, 1, 10), 'Nilai harus di antara 1 dan 10');
      expect(FormValidators.range(1, 1, 10), isNull);
      expect(FormValidators.range(10, 1, 10), isNull);
      expect(FormValidators.range(5, 1, 10), isNull);
    });
  });
}
