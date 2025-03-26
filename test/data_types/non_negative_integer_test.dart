import 'package:rdf_dart/src/data_types/non_negative_integer.dart';
import 'package:test/test.dart';

void main() {
  group('NonNegativeIntegerCodec (xsd:nonNegativeInteger)', () {
    const minNonNegInt = 0;
    // Using standard int max as a practical upper bound example
    const maxInt = 2147483647;

    // --- Encoder Tests (String -> int) ---
    group('Encoder (String to int)', () {
      test('should parse valid non-negative integer strings', () {
        expect(nonNegativeInteger.encoder.convert('0'), minNonNegInt);
        expect(
          nonNegativeInteger.encoder.convert('+0'),
          minNonNegInt,
        ); // Explicit plus zero
        expect(nonNegativeInteger.encoder.convert('1'), 1);
        expect(nonNegativeInteger.encoder.convert('10'), 10);
        expect(nonNegativeInteger.encoder.convert('+10'), 10); // Explicit plus
        expect(nonNegativeInteger.encoder.convert('$maxInt'), maxInt);
      });

      test('should handle whitespace correctly (collapse)', () {
        expect(nonNegativeInteger.encoder.convert(' 0 '), 0);
        expect(nonNegativeInteger.encoder.convert('\n123\t'), 123);
      });

      test('should throw RangeError for negative integers', () {
        expect(
          () => nonNegativeInteger.encoder.convert('-1'),
          throwsRangeError,
        );
        expect(
          () => nonNegativeInteger.encoder.convert('-10'),
          throwsRangeError,
        );
        const minInt = -2147483648;
        expect(
          () => nonNegativeInteger.encoder.convert('$minInt'),
          throwsRangeError,
        );
      });

      test('should throw FormatException for invalid formats', () {
        expect(
          () => nonNegativeInteger.encoder.convert(''),
          throwsFormatException,
        );
        expect(
          () => nonNegativeInteger.encoder.convert('abc'),
          throwsFormatException,
        );
        expect(
          () => nonNegativeInteger.encoder.convert('1.0'),
          throwsFormatException,
        ); // Decimal
        expect(
          () => nonNegativeInteger.encoder.convert('1e2'),
          throwsFormatException,
        ); // Exponent
        expect(
          () => nonNegativeInteger.encoder.convert('--10'),
          throwsFormatException,
        ); // Double sign (fails pattern)
        expect(
          () => nonNegativeInteger.encoder.convert('+-10'),
          throwsFormatException,
        ); // Mixed signs (fails pattern)
        expect(
          () => nonNegativeInteger.encoder.convert('1 000'),
          throwsFormatException,
        ); // Internal space
      });
    });

    // --- Decoder Tests (int -> String) ---
    group('Decoder (int to String)', () {
      test('should format valid non-negative integers to string', () {
        expect(nonNegativeInteger.decoder.convert(minNonNegInt), '0');
        expect(nonNegativeInteger.decoder.convert(1), '1');
        expect(nonNegativeInteger.decoder.convert(10), '10');
        expect(nonNegativeInteger.decoder.convert(maxInt), '$maxInt');
      });

      test('should throw RangeError for negative integers', () {
        expect(() => nonNegativeInteger.decoder.convert(-1), throwsRangeError);
        expect(() => nonNegativeInteger.decoder.convert(-10), throwsRangeError);
        const minInt = -2147483648;
        expect(
          () => nonNegativeInteger.decoder.convert(minInt),
          throwsRangeError,
        );
      });
    });
  });
}
