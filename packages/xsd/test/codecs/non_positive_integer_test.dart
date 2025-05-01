import 'package:test/test.dart';
import 'package:xsd/src/codecs/nonPositiveInteger/non_positive_integer_codec.dart';

void main() {
  group('NonPositiveIntegerCodec (xsd:nonPositiveInteger)', () {
    const maxNonPosInt = 0;
    // Using standard int min as a practical lower bound example
    const minInt = -2147483648;

    // --- Encoder Tests (String -> int) ---
    group('Encoder (String to int)', () {
      test('should parse valid non-positive integer strings', () {
        expect(nonPositiveInteger.encoder.convert('0'), maxNonPosInt);
        expect(
          nonPositiveInteger.encoder.convert('+0'),
          maxNonPosInt,
        ); // Explicit plus zero
        expect(
          nonPositiveInteger.encoder.convert('-0'),
          maxNonPosInt,
        ); // Explicit minus zero
        expect(nonPositiveInteger.encoder.convert('-1'), -1);
        expect(nonPositiveInteger.encoder.convert('-10'), -10);
        expect(nonPositiveInteger.encoder.convert('$minInt'), minInt);
      });

      test('should handle whitespace correctly (collapse)', () {
        expect(nonPositiveInteger.encoder.convert(' 0 '), 0);
        expect(nonPositiveInteger.encoder.convert('\n-99\t'), -99);
      });

      test('should throw RangeError for positive integers', () {
        expect(() => nonPositiveInteger.encoder.convert('1'), throwsRangeError);
        expect(
          () => nonPositiveInteger.encoder.convert('+1'),
          throwsRangeError,
        );
        expect(
          () => nonPositiveInteger.encoder.convert('100'),
          throwsRangeError,
        );
        const maxInt = 2147483647;
        expect(
          () => nonPositiveInteger.encoder.convert('$maxInt'),
          throwsRangeError,
        );
      });

      test('should throw FormatException for invalid formats', () {
        expect(
          () => nonPositiveInteger.encoder.convert(''),
          throwsFormatException,
        );
        expect(
          () => nonPositiveInteger.encoder.convert('abc'),
          throwsFormatException,
        );
        expect(
          () => nonPositiveInteger.encoder.convert('-1.0'),
          throwsFormatException,
        ); // Decimal
        expect(
          () => nonPositiveInteger.encoder.convert('-1e5'),
          throwsFormatException,
        ); // Exponent
        expect(
          () => nonPositiveInteger.encoder.convert('--10'),
          throwsFormatException,
        ); // Double sign
        expect(
          () => nonPositiveInteger.encoder.convert('+-10'),
          throwsFormatException,
        ); // Mixed signs (fails pattern)
        expect(
          () => nonPositiveInteger.encoder.convert('-1 000'),
          throwsFormatException,
        ); // Internal space
      });
    });

    // --- Decoder Tests (int -> String) ---
    group('Decoder (int to String)', () {
      test('should format valid non-positive integers to string', () {
        expect(nonPositiveInteger.decoder.convert(maxNonPosInt), '0');
        expect(nonPositiveInteger.decoder.convert(-1), '-1');
        expect(nonPositiveInteger.decoder.convert(-10), '-10');
        expect(nonPositiveInteger.decoder.convert(minInt), '$minInt');
      });

      test('should throw RangeError for positive integers', () {
        expect(() => nonPositiveInteger.decoder.convert(1), throwsRangeError);
        expect(() => nonPositiveInteger.decoder.convert(10), throwsRangeError);
        const maxInt = 2147483647;
        expect(
          () => nonPositiveInteger.decoder.convert(maxInt),
          throwsRangeError,
        );
      });
    });
  });
}
