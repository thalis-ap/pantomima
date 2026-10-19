import '../localization/greek_strings.dart';

/// Strict positive whole integer validator for Pantomima game setup
class PositiveIntValidationResult {
  final bool isValid;
  final int? value;
  final String? errorMessage;

  const PositiveIntValidationResult.valid(this.value)
    : isValid = true,
      errorMessage = null;

  const PositiveIntValidationResult.invalid(this.errorMessage)
    : isValid = false,
      value = null;
}

class PositiveIntValidator {
  PositiveIntValidator._();

  static final RegExp _strictlyDigits = RegExp(r'^[0-9]+$');

  /// Validates that [raw] is a positive whole integer strictly containing ASCII digits '0'-'9',
  /// with a value greater than zero and within [min] and [max].
  static PositiveIntValidationResult validate(
    String raw, {
    String emptyOrInvalidError = GreekStrings.invalidDurationError,
    String? overflowError,
    int min = 1,
    int max = 1000000,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || !_strictlyDigits.hasMatch(trimmed)) {
      return PositiveIntValidationResult.invalid(emptyOrInvalidError);
    }

    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      // Since trimmed only contains digits, null means integer overflow
      return PositiveIntValidationResult.invalid(
        overflowError ?? emptyOrInvalidError,
      );
    }

    if (parsed < min) {
      return PositiveIntValidationResult.invalid(emptyOrInvalidError);
    }

    if (parsed > max) {
      return PositiveIntValidationResult.invalid(
        overflowError ?? emptyOrInvalidError,
      );
    }

    return PositiveIntValidationResult.valid(parsed);
  }
}
