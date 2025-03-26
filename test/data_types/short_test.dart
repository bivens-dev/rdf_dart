import 'package:rdf_dart/src/data_types/short.dart';
import 'package:test/test.dart';

void main() {
  group('ShortCodec (xsd:short)', () {
    const minShort = -32768;
    const maxShort = 32767;

    // --- Encoder Tests (String -> int) ---
    group('Encoder (String to int)', () {
      test('should parse valid short strings within range', () {
        expect(shortCodec.encoder.convert('0'), 0);
        expect(shortCodec.encoder.convert('$maxShort'), maxShort);
        expect(shortCodec.encoder.convert('$minShort'), minShort);
        expect(shortCodec.encoder.convert('1000'), 1000);
        expect(shortCodec.encoder.convert('-1000'), -1000);
        expect(shortCodec.encoder.convert('+200'), 200); // With explicit plus
      });

      test('should handle whitespace correctly (collapse)', () {
        expect(shortCodec.encoder.convert(' $maxShort '), maxShort);
        expect(shortCodec.encoder.convert('\t$minShort\n'), minShort);
      });

      test(
        'should throw RangeError for valid integers outside short range',
        () {
          // Just outside range
          const maxPlusOne = maxShort + 1;
          const minMinusOne = minShort - 1;

          expect(
            () => shortCodec.encoder.convert('$maxPlusOne'),
            throwsRangeError,
          ); // 32768
          expect(
            () => shortCodec.encoder.convert('$minMinusOne'),
            throwsRangeError,
          ); // -32769

          // Values definitely outside
          expect(() => shortCodec.encoder.convert('100000'), throwsRangeError);
          expect(() => shortCodec.encoder.convert('-100000'), throwsRangeError);
        },
      );

      test('should throw FormatException for invalid formats', () {
        expect(() => shortCodec.encoder.convert(''), throwsFormatException);
        expect(() => shortCodec.encoder.convert('abc'), throwsFormatException);
        expect(
          () => shortCodec.encoder.convert('12.0'),
          throwsFormatException,
        ); // Decimal
        expect(
          () => shortCodec.encoder.convert('1e3'),
          throwsFormatException,
        ); // Exponent
        expect(
          () => shortCodec.encoder.convert('--10'),
          throwsFormatException,
        ); // Double sign
        expect(
          () => shortCodec.encoder.convert('+-10'),
          throwsFormatException,
        ); // Mixed signs
        expect(
          () => shortCodec.encoder.convert('1 000'),
          throwsFormatException,
        ); // Internal space
      });
    });

    // --- Decoder Tests (int -> String) ---
    group('Decoder (int to String)', () {
      test('should format valid short integers to string', () {
        expect(shortCodec.decoder.convert(0), '0');
        expect(shortCodec.decoder.convert(maxShort), '$maxShort');
        expect(shortCodec.decoder.convert(minShort), '$minShort');
        expect(shortCodec.decoder.convert(1234), '1234');
        expect(shortCodec.decoder.convert(-5432), '-5432');
      });

      test('should throw RangeError for integers outside short range', () {
        const maxPlusOne = maxShort + 1;
        const minMinusOne = minShort - 1;

        expect(
          () => shortCodec.decoder.convert(maxPlusOne),
          throwsRangeError,
        ); // 32768
        expect(
          () => shortCodec.decoder.convert(minMinusOne),
          throwsRangeError,
        ); // -32769

        // Values definitely outside
        expect(() => shortCodec.decoder.convert(100000), throwsRangeError);
        expect(() => shortCodec.decoder.convert(-100000), throwsRangeError);
        // Standard int limits (should also fail if outside short range)
        const maxInt = 2147483647;
        const minInt = -2147483648;
        expect(() => shortCodec.decoder.convert(maxInt), throwsRangeError);
        expect(() => shortCodec.decoder.convert(minInt), throwsRangeError);
      });
    });
  });
}
