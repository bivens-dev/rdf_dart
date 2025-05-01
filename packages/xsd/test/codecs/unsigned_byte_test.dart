import 'package:test/test.dart';
import 'package:xsd/src/codecs/unsignedByte/unsigned_byte_codec.dart';

void main() {
  group('UnsignedByteCodec (xsd:unsignedByte)', () {
    const minUnsignedByte = 0;
    const maxUnsignedByte = 255;

    // --- Encoder Tests (String -> int) ---
    group('Encoder (String to int)', () {
      test('should parse valid unsignedByte strings within range', () {
        expect(unsignedByte.encoder.convert('0'), minUnsignedByte);
        expect(
          unsignedByte.encoder.convert('$maxUnsignedByte'),
          maxUnsignedByte,
        );
        expect(unsignedByte.encoder.convert('128'), 128);
        expect(unsignedByte.encoder.convert('+100'), 100); // With explicit plus
      });

      test('should handle whitespace correctly (collapse)', () {
        expect(
          unsignedByte.encoder.convert(' $maxUnsignedByte '),
          maxUnsignedByte,
        );
        expect(
          unsignedByte.encoder.convert('\t$minUnsignedByte\n'),
          minUnsignedByte,
        );
      });

      test(
        'should throw RangeError for valid integers outside unsignedByte range',
        () {
          // Just outside range
          const maxPlusOne = maxUnsignedByte + 1; // 256
          const minMinusOne = minUnsignedByte - 1; // -1

          expect(
            () => unsignedByte.encoder.convert('$maxPlusOne'),
            throwsRangeError,
          );
          expect(
            () => unsignedByte.encoder.convert('$minMinusOne'),
            throwsRangeError,
          );
          expect(
            () => unsignedByte.encoder.convert('-10'),
            throwsRangeError,
          ); // Other negative

          // Values definitely outside
          expect(() => unsignedByte.encoder.convert('1000'), throwsRangeError);
          expect(() => unsignedByte.encoder.convert('-1000'), throwsRangeError);
        },
      );

      test('should throw FormatException for invalid formats', () {
        expect(() => unsignedByte.encoder.convert(''), throwsFormatException);
        expect(
          () => unsignedByte.encoder.convert('abc'),
          throwsFormatException,
        );
        expect(
          () => unsignedByte.encoder.convert('12.0'),
          throwsFormatException,
        ); // Decimal
        expect(
          () => unsignedByte.encoder.convert('1e2'),
          throwsFormatException,
        ); // Exponent
        expect(
          () => unsignedByte.encoder.convert('--10'),
          throwsFormatException,
        ); // Double sign (fails pattern)
        expect(
          () => unsignedByte.encoder.convert('+-10'),
          throwsFormatException,
        ); // Mixed signs (fails pattern)
        expect(
          () => unsignedByte.encoder.convert('1 00'),
          throwsFormatException,
        ); // Internal space
      });
    });

    // --- Decoder Tests (int -> String) ---
    group('Decoder (int to String)', () {
      test('should format valid unsignedByte integers to string', () {
        expect(unsignedByte.decoder.convert(minUnsignedByte), '0');
        expect(unsignedByte.decoder.convert(maxUnsignedByte), '255');
        expect(unsignedByte.decoder.convert(128), '128');
      });

      test(
        'should throw RangeError for integers outside unsignedByte range',
        () {
          const maxPlusOne = maxUnsignedByte + 1; // 256
          const minMinusOne = minUnsignedByte - 1; // -1

          expect(
            () => unsignedByte.decoder.convert(maxPlusOne),
            throwsRangeError,
          );
          expect(
            () => unsignedByte.decoder.convert(minMinusOne),
            throwsRangeError,
          );
          expect(
            () => unsignedByte.decoder.convert(-10),
            throwsRangeError,
          ); // Other negative

          // Values definitely outside
          expect(() => unsignedByte.decoder.convert(1000), throwsRangeError);
          expect(() => unsignedByte.decoder.convert(-1000), throwsRangeError);
        },
      );
    });
  });
}
