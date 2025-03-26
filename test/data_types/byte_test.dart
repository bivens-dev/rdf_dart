import 'package:rdf_dart/src/data_types/byte.dart';
import 'package:test/test.dart';

void main() {
  group('ByteCodec', () {
    group('Encoder (String to int)', () {
      test('should parse valid byte strings within range', () {
        expect(byte.encoder.convert('0'), 0);
        expect(byte.encoder.convert('127'), 127);
        expect(byte.encoder.convert('-128'), -128);
        expect(byte.encoder.convert('10'), 10);
        expect(byte.encoder.convert('-10'), -10);
        expect(byte.encoder.convert('+50'), 50); // With explicit plus
      });

      test('should handle whitespace correctly (collapse)', () {
        expect(byte.encoder.convert(' 10 '), 10);
        expect(byte.encoder.convert('\t+50\n'), 50);
        // Note: processWhiteSpace replaces \t,\n,\r with space, collapses, trims
        expect(
          byte.encoder.convert(' -30 '),
          -30,
        ); // Space between sign and number might fail pattern
      });

      test('should throw RangeError for valid integers outside byte range', () {
        // Just outside range
        expect(() => byte.encoder.convert('128'), throwsRangeError);
        expect(() => byte.encoder.convert('-129'), throwsRangeError);
        // Way outside range
        expect(() => byte.encoder.convert('1000'), throwsRangeError);
        expect(() => byte.encoder.convert('-1000'), throwsRangeError);
      });

      test('should throw FormatException for invalid formats', () {
        expect(
          () => byte.encoder.convert(''),
          throwsFormatException,
        ); // Empty string
        expect(
          () => byte.encoder.convert('abc'),
          throwsFormatException,
        ); // Non-numeric
        expect(
          () => byte.encoder.convert('12.0'),
          throwsFormatException,
        ); // Decimal point
        expect(
          () => byte.encoder.convert('1e2'),
          throwsFormatException,
        ); // Exponent
        expect(
          () => byte.encoder.convert('--10'),
          throwsFormatException,
        ); // Double sign
        expect(
          () => byte.encoder.convert('+-10'),
          throwsFormatException,
        ); // Mixed signs
        expect(
          () => byte.encoder.convert('1 0'),
          throwsFormatException,
        ); // Internal space after collapse
      });
    });

    // --- Decoder Tests (int -> String) ---
    group('Decoder (int to String)', () {
      test('should format valid byte integers to string', () {
        expect(byte.decoder.convert(0), '0');
        expect(byte.decoder.convert(127), '127');
        expect(byte.decoder.convert(-128), '-128');
        expect(byte.decoder.convert(10), '10');
        expect(byte.decoder.convert(-10), '-10');
      });

      test('should throw RangeError for integers outside byte range', () {
        expect(() => byte.decoder.convert(128), throwsRangeError);
        expect(() => byte.decoder.convert(-129), throwsRangeError);
        expect(() => byte.decoder.convert(1000), throwsRangeError);
        expect(() => byte.decoder.convert(-1000), throwsRangeError);
      });
    });
  });
}
