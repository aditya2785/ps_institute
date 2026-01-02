class Validators {
  // -------------------------
  // Email Validator
  // -------------------------
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid email address";
    }

    return null;
  }

  // -------------------------
  // Password Validator
  // -------------------------
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  // -------------------------
  // Phone Number Validator
  // -------------------------
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }

    final cleaned = value.replaceAll(RegExp(r'\D'), "");

    if (cleaned.length != 10) {
      return "Enter a valid 10-digit phone number";
    }

    return null;
  }

  // -------------------------
  // Name Validator
  // -------------------------
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }

    if (value.trim().length < 3) {
      return "Name must be at least 3 characters";
    }

    final regex = RegExp(r"^[a-zA-Z ]+$");
    if (!regex.hasMatch(value.trim())) {
      return "Name can only contain alphabets";
    }

    return null;
  }

  // -------------------------
  // Empty Field
  // -------------------------
  static String? required(String? value, [String field = "Field"]) {
    if (value == null || value.trim().isEmpty) {
      return "$field is required";
    }
    return null;
  }

  // -------------------------
  // Min Length Validator
  // -------------------------
  static String? minLength(String? value, int min, String field) {
    if (value == null || value.trim().isEmpty) {
      return "$field is required";
    }
    if (value.trim().length < min) {
      return "$field must be at least $min characters";
    }
    return null;
  }

  // -------------------------
  // Max Length Validator
  // -------------------------
  static String? maxLength(String? value, int max, String field) {
    if (value == null) return null;
    if (value.trim().length > max) {
      return "$field must be less than $max characters";
    }
    return null;
  }
}
