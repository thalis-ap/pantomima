import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/core/localization/greek_strings.dart';
import 'package:pantomima/core/utils/positive_int_validator.dart';

void main() {
  group('PositiveIntValidator Unit Tests', () {
    test('Validates accepted positive whole numbers', () {
      final res1 = PositiveIntValidator.validate('1');
      expect(res1.isValid, isTrue);
      expect(res1.value, 1);

      final res2 = PositiveIntValidator.validate('2');
      expect(res2.isValid, isTrue);
      expect(res2.value, 2);

      final res5 = PositiveIntValidator.validate('5');
      expect(res5.isValid, isTrue);
      expect(res5.value, 5);

      final res60 = PositiveIntValidator.validate('60');
      expect(res60.isValid, isTrue);
      expect(res60.value, 60);

      final res180 = PositiveIntValidator.validate('180');
      expect(res180.isValid, isTrue);
      expect(res180.value, 180);
    });

    test('Rejects empty or whitespace-only input', () {
      final resEmpty = PositiveIntValidator.validate('');
      expect(resEmpty.isValid, isFalse);
      expect(resEmpty.errorMessage, GreekStrings.invalidDurationError);

      final resSpace = PositiveIntValidator.validate('   ');
      expect(resSpace.isValid, isFalse);
      expect(resSpace.errorMessage, GreekStrings.invalidDurationError);
    });

    test('Rejects zero', () {
      final resZero = PositiveIntValidator.validate('0');
      expect(resZero.isValid, isFalse);
      expect(resZero.errorMessage, GreekStrings.invalidDurationError);

      final resDoubleZero = PositiveIntValidator.validate('00');
      expect(resDoubleZero.isValid, isFalse);
    });

    test('Rejects negative values and explicit positive signs', () {
      final resNeg = PositiveIntValidator.validate('-1');
      expect(resNeg.isValid, isFalse);

      final resPos = PositiveIntValidator.validate('+1');
      expect(resPos.isValid, isFalse);
    });

    test('Rejects decimal numbers (dots and commas)', () {
      final resDot = PositiveIntValidator.validate('1.5');
      expect(resDot.isValid, isFalse);

      final resComma = PositiveIntValidator.validate('1,5');
      expect(resComma.isValid, isFalse);
    });

    test('Rejects scientific notation, spaces, and alphanumeric input', () {
      expect(PositiveIntValidator.validate('1e2').isValid, isFalse);
      expect(PositiveIntValidator.validate('1 2').isValid, isFalse);
      expect(PositiveIntValidator.validate('abc').isValid, isFalse);
      expect(PositiveIntValidator.validate('12abc').isValid, isFalse);
      expect(
        PositiveIntValidator.validate('١٢٣').isValid,
        isFalse,
      ); // Non-ASCII Arabic-Indic digits
      expect(PositiveIntValidator.validate('12!').isValid, isFalse);
      expect(PositiveIntValidator.validate('@3').isValid, isFalse);
    });

    test('Rejects integer overflow and enforces min/max bounds', () {
      final resOverflow = PositiveIntValidator.validate(
        '9999999999999999999999999999999999999',
        overflowError: GreekStrings.durationOverflowError,
      );
      expect(resOverflow.isValid, isFalse);
      expect(resOverflow.errorMessage, GreekStrings.durationOverflowError);

      // Above max
      final resAboveMax = PositiveIntValidator.validate(
        '601',
        max: 600,
        overflowError: GreekStrings.durationOverflowError,
      );
      expect(resAboveMax.isValid, isFalse);
      expect(resAboveMax.errorMessage, GreekStrings.durationOverflowError);

      // Within max
      final resAtMax = PositiveIntValidator.validate('600', max: 600);
      expect(resAtMax.isValid, isTrue);
      expect(resAtMax.value, 600);

      // Below min
      final resBelowMin = PositiveIntValidator.validate('2', min: 3);
      expect(resBelowMin.isValid, isFalse);
    });
  });
}
