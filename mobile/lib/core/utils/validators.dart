class FormValidators {
  static String? required(
    String? value, {
    String message = 'Field ini wajib diisi',
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(
    String? value, {
    String message = 'Format email tidak valid',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return message;
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? message}) {
    if (value == null || value.trim().length < min) {
      return message ?? 'Minimal $min karakter';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? message}) {
    if (value != null && value.trim().length > max) {
      return message ?? 'Maksimal $max karakter';
    }
    return null;
  }

  static String? range(num? value, num min, num max, {String? message}) {
    if (value == null) {
      return 'Nilai wajib diisi';
    }
    if (value < min || value > max) {
      return message ?? 'Nilai harus di antara $min dan $max';
    }
    return null;
  }
}
