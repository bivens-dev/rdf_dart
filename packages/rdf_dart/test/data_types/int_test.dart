import 'package:rdf_dart/src/data_types/int.dart'; // Use intCodec from here
import 'package:test/test.dart';

void main() {
  group('IntCodec (xsd:int)', () {
    const minInt = -2147483648;
    const maxInt = 2147483647;

    // --- Encoder Tests (String -> int) ---
    group('Encoder (String to int)', () {
      test('should parse valid int strings within range', () {
        expect(intCodec.encoder.convert('0'), 0);
        expect(intCodec.encoder.convert('$maxInt'), maxInt);
        expect(intCodec.encoder.convert('$minInt'), minInt);
        expect(intCodec.encoder.convert('100000'), 100000);
        expect(intCodec.encoder.convert('-100000'), -100000);
        expect(intCodec.encoder.convert('+200'), 200); // With explicit plus
      });

      test('should handle whitespace correctly (collapse)', () {
        expect(intCodec.encoder.convert(' 12345 '), 12345);
        expect(intCodec.encoder.convert('\t-54321\n'), -54321);
      });

      test('should throw RangeError for valid integers outside int range', () {
        // Use BigInt for numbers just outside the 32-bit range
        final maxPlusOne = BigInt.from(maxInt) + BigInt.one;
        final minMinusOne = BigInt.from(minInt) - BigInt.one;

        expect(() => intCodec.encoder.convert('$maxPlusOne'), throwsRangeError);
        expect(
          () => intCodec.encoder.convert('$minMinusOne'),
          throwsRangeError,
        );

        // Values definitely outside
        expect(() => intCodec.encoder.convert('3000000000'), throwsRangeError);
        expect(() => intCodec.encoder.convert('-3000000000'), throwsRangeError);
      });

      test('should throw FormatException for invalid formats', () {
        expect(() => intCodec.encoder.convert(''), throwsFormatException);
        expect(() => intCodec.encoder.convert('abc'), throwsFormatException);
        expect(
          () => intCodec.encoder.convert('12.0'),
          throwsFormatException,
        ); // Decimal
        expect(
          () => intCodec.encoder.convert('1e5'),
          throwsFormatException,
        ); // Exponent
        expect(
          () => intCodec.encoder.convert('--10'),
          throwsFormatException,
        ); // Double sign
        expect(
          () => intCodec.encoder.convert('+-10'),
          throwsFormatException,
        ); // Mixed signs
        expect(
          () => intCodec.encoder.convert('1 000'),
          throwsFormatException,
        ); // Internal space
      });
    });

    // --- Decoder Tests (int -> String) ---
    group('Decoder (int to String)', () {
      test('should format valid int integers to string', () {
        expect(intCodec.decoder.convert(0), '0');
        expect(intCodec.decoder.convert(maxInt), '$maxInt');
        expect(intCodec.decoder.convert(minInt), '$minInt');
        expect(intCodec.decoder.convert(12345), '12345');
        expect(intCodec.decoder.convert(-54321), '-54321');
      });

      test('should throw RangeError for integers outside int range', () {
        // Need to construct values outside the range carefully if platform int > 32 bits
        // Using BigInt and checking if they fit in standard int might be needed,
        // but for testing the *decoder's* check, we can try literals if they work.
        // If Dart's int is 64-bit, these literals are valid ints but should fail the decoder's range check.
        const maxPlusOne = 2147483648; // Outside 32-bit positive range
        const minMinusOne = -2147483649; // Outside 32-bit negative range

        expect(() => intCodec.decoder.convert(maxPlusOne), throwsRangeError);
        expect(() => intCodec.decoder.convert(minMinusOne), throwsRangeError);

        // Values definitely outside
        expect(() => intCodec.decoder.convert(3000000000), throwsRangeError);
        expect(() => intCodec.decoder.convert(-3000000000), throwsRangeError);
      });
    });
  });
}
