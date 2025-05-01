import 'package:test/test.dart';
import 'package:xsd/src/codecs/negativeInteger/negative_integer_codec.dart';

void main() {
  group('NegativeIntegerCodec (xsd:negativeInteger)', () {
    const maxNegInt = -1;
    // Using standard int min as a practical lower bound example
    const minInt = -2147483648;

    // --- Encoder Tests (String -> int) ---
    group('Encoder (String to int)', () {
      test('should parse valid negative integer strings', () {
        expect(negativeInteger.encoder.convert('-1'), maxNegInt);
        expect(negativeInteger.encoder.convert('-10'), -10);
        expect(
          negativeInteger.encoder.convert('$minInt'),
          minInt,
        ); // Min 32-bit int
        expect(negativeInteger.encoder.convert('-123456789'), -123456789);
      });

      test('should handle whitespace correctly (collapse)', () {
        expect(negativeInteger.encoder.convert(' -1 '), maxNegInt);
        expect(negativeInteger.encoder.convert('\n-99\t'), -99);
      });

      test('should throw RangeError for zero or positive integers', () {
        expect(() => negativeInteger.encoder.convert('0'), throwsRangeError);
        expect(
          () => negativeInteger.encoder.convert('+0'),
          throwsRangeError,
        ); // Although +0 parses to 0
        expect(() => negativeInteger.encoder.convert('1'), throwsRangeError);
        expect(() => negativeInteger.encoder.convert('+1'), throwsRangeError);
        expect(() => negativeInteger.encoder.convert('100'), throwsRangeError);
      });

      test('should throw FormatException for invalid formats', () {
        expect(
          () => negativeInteger.encoder.convert(''),
          throwsFormatException,
        );
        expect(
          () => negativeInteger.encoder.convert('abc'),
          throwsFormatException,
        );
        expect(
          () => negativeInteger.encoder.convert('-12.0'),
          throwsFormatException,
        ); // Decimal
        expect(
          () => negativeInteger.encoder.convert('-1e5'),
          throwsFormatException,
        ); // Exponent
        expect(
          () => negativeInteger.encoder.convert('--10'),
          throwsFormatException,
        ); // Double sign
        expect(
          () => negativeInteger.encoder.convert('+-10'),
          throwsFormatException,
        ); // Mixed signs (should fail pattern)
        expect(
          () => negativeInteger.encoder.convert('-1 000'),
          throwsFormatException,
        ); // Internal space
      });
    });

    // --- Decoder Tests (int -> String) ---
    group('Decoder (int to String)', () {
      test('should format valid negative integers to string', () {
        expect(negativeInteger.decoder.convert(maxNegInt), '-1');
        expect(negativeInteger.decoder.convert(-10), '-10');
        expect(negativeInteger.decoder.convert(minInt), '$minInt');
        expect(negativeInteger.decoder.convert(-12345), '-12345');
      });

      test('should throw RangeError for zero or positive integers', () {
        expect(() => negativeInteger.decoder.convert(0), throwsRangeError);
        expect(() => negativeInteger.decoder.convert(1), throwsRangeError);
        expect(() => negativeInteger.decoder.convert(100), throwsRangeError);
        // Test upper bound of standard int if relevant
        const maxInt = 2147483647;
        expect(() => negativeInteger.decoder.convert(maxInt), throwsRangeError);
      });
    });
  });
}
