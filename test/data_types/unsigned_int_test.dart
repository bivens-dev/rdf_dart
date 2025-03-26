import 'package:rdf_dart/src/data_types/unsigned_int.dart';
import 'package:test/test.dart';

void main() {
  group('UnsignedIntCodec (xsd:unsignedInt)', () {
    const minUnsignedInt = 0;
    const maxUnsignedInt = 4294967295;

    // --- Encoder Tests (String -> int) ---
    group('Encoder (String to int)', () {
      test('should parse valid unsignedInt strings within range', () {
        expect(unsignedInt.encoder.convert('0'), minUnsignedInt);
        expect(unsignedInt.encoder.convert('$maxUnsignedInt'), maxUnsignedInt);
        expect(unsignedInt.encoder.convert('100000'), 100000);
        expect(
          unsignedInt.encoder.convert('+200000'),
          200000,
        ); // With explicit plus
      });

      test('should handle whitespace correctly (collapse)', () {
        expect(
          unsignedInt.encoder.convert(' $maxUnsignedInt '),
          maxUnsignedInt,
        );
        expect(
          unsignedInt.encoder.convert('\t$minUnsignedInt\n'),
          minUnsignedInt,
        );
      });

      test(
        'should throw RangeError for valid integers outside unsignedInt range',
        () {
          // Use BigInt for numbers just outside the 32-bit unsigned range
          final maxPlusOne =
              BigInt.from(maxUnsignedInt) + BigInt.one; // 4294967296
          const minMinusOne = minUnsignedInt - 1; // -1

          expect(
            () => unsignedInt.encoder.convert('$maxPlusOne'),
            throwsRangeError,
          );
          expect(
            () => unsignedInt.encoder.convert('$minMinusOne'),
            throwsRangeError,
          );
          expect(
            () => unsignedInt.encoder.convert('-10'),
            throwsRangeError,
          ); // Other negative

          // Values definitely outside
          final wayTooBig = maxPlusOne + BigInt.from(1000);
          expect(
            () => unsignedInt.encoder.convert('$wayTooBig'),
            throwsRangeError,
          );
          expect(() => unsignedInt.encoder.convert('-1000'), throwsRangeError);
        },
      );

      test('should throw FormatException for invalid formats', () {
        expect(() => unsignedInt.encoder.convert(''), throwsFormatException);
        expect(() => unsignedInt.encoder.convert('abc'), throwsFormatException);
        expect(
          () => unsignedInt.encoder.convert('12.0'),
          throwsFormatException,
        ); // Decimal
        expect(
          () => unsignedInt.encoder.convert('1e5'),
          throwsFormatException,
        ); // Exponent
        expect(
          () => unsignedInt.encoder.convert('--10'),
          throwsFormatException,
        ); // Double sign (fails pattern)
        expect(
          () => unsignedInt.encoder.convert('+-10'),
          throwsFormatException,
        ); // Mixed signs (fails pattern)
        expect(
          () => unsignedInt.encoder.convert('1 000'),
          throwsFormatException,
        ); // Internal space
      });
    });

    // --- Decoder Tests (int -> String) ---
    group('Decoder (int to String)', () {
      test('should format valid unsignedInt integers to string', () {
        expect(unsignedInt.decoder.convert(minUnsignedInt), '0');
        expect(unsignedInt.decoder.convert(maxUnsignedInt), '$maxUnsignedInt');
        expect(unsignedInt.decoder.convert(123456), '123456');
      });

      test(
        'should throw RangeError for integers outside unsignedInt range',
        () {
          // Dart int is 64-bit, so 4294967296 is a valid int literal,
          // but should fail the decoder's range check.
          const maxPlusOne = maxUnsignedInt + 1; // 4294967296
          const minMinusOne = minUnsignedInt - 1; // -1

          expect(
            () => unsignedInt.decoder.convert(maxPlusOne),
            throwsRangeError,
          );
          expect(
            () => unsignedInt.decoder.convert(minMinusOne),
            throwsRangeError,
          );
          expect(
            () => unsignedInt.decoder.convert(-10),
            throwsRangeError,
          ); // Other negative

          // Value possibly within 64-bit int but outside unsigned 32-bit
          expect(
            () => unsignedInt.decoder.convert(5000000000),
            throwsRangeError,
          );
        },
      );
    });
  });
}
