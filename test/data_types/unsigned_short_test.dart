import 'package:rdf_dart/src/data_types/unsigned_short.dart';
import 'package:test/test.dart';

void main() {
  group('UnsignedShortCodec (xsd:unsignedShort)', () {
    const minUnsignedShort = 0;
    const maxUnsignedShort = 65535;

    // --- Encoder Tests (String -> int) ---
    group('Encoder (String to int)', () {
      test('should parse valid unsignedShort strings within range', () {
        expect(unsignedShort.encoder.convert('0'), minUnsignedShort);
        expect(
          unsignedShort.encoder.convert('$maxUnsignedShort'),
          maxUnsignedShort,
        );
        expect(unsignedShort.encoder.convert('1000'), 1000);
        expect(
          unsignedShort.encoder.convert('+5000'),
          5000,
        ); // With explicit plus
      });

      test('should handle whitespace correctly (collapse)', () {
        expect(
          unsignedShort.encoder.convert(' $maxUnsignedShort '),
          maxUnsignedShort,
        );
        expect(
          unsignedShort.encoder.convert('\t$minUnsignedShort\n'),
          minUnsignedShort,
        );
        expect(unsignedShort.encoder.convert(' 1234 '), 1234);
      });

      test(
        'should throw RangeError for valid integers outside unsignedShort range',
        () {
          // Just outside range
          const maxPlusOne = maxUnsignedShort + 1; // 65536
          const minMinusOne = minUnsignedShort - 1; // -1

          expect(
            () => unsignedShort.encoder.convert('$maxPlusOne'),
            throwsRangeError,
          );
          expect(
            () => unsignedShort.encoder.convert('$minMinusOne'),
            throwsRangeError,
          );
          expect(
            () => unsignedShort.encoder.convert('-10'),
            throwsRangeError,
          ); // Other negative

          // Values definitely outside
          expect(
            () => unsignedShort.encoder.convert('100000'),
            throwsRangeError,
          );
          expect(
            () => unsignedShort.encoder.convert('-1000'),
            throwsRangeError,
          );
        },
      );

      test('should throw FormatException for invalid formats', () {
        // Note: The encoder has 'invalid format' - maybe change to 'invalid xsd:unsignedShort format'?
        const matcher = throwsFormatException; // Use FormatException matcher

        expect(() => unsignedShort.encoder.convert(''), matcher);
        expect(() => unsignedShort.encoder.convert('abc'), matcher);
        expect(() => unsignedShort.encoder.convert('12.0'), matcher); // Decimal
        expect(() => unsignedShort.encoder.convert('1e3'), matcher); // Exponent
        expect(
          () => unsignedShort.encoder.convert('--10'),
          matcher,
        ); // Double sign (fails pattern)
        expect(
          () => unsignedShort.encoder.convert('+-10'),
          matcher,
        ); // Mixed signs (fails pattern)
        expect(
          () => unsignedShort.encoder.convert('10 00'),
          matcher,
        ); // Internal space
      });
    });

    // --- Decoder Tests (int -> String) ---
    group('Decoder (int to String)', () {
      test('should format valid unsignedShort integers to string', () {
        expect(unsignedShort.decoder.convert(minUnsignedShort), '0');
        expect(unsignedShort.decoder.convert(maxUnsignedShort), '65535');
        expect(unsignedShort.decoder.convert(12345), '12345');
      });

      test(
        'should throw RangeError for integers outside unsignedShort range',
        () {
          const maxPlusOne = maxUnsignedShort + 1; // 65536
          const minMinusOne = minUnsignedShort - 1; // -1

          expect(
            () => unsignedShort.decoder.convert(maxPlusOne),
            throwsRangeError,
          );
          expect(
            () => unsignedShort.decoder.convert(minMinusOne),
            throwsRangeError,
          );
          expect(
            () => unsignedShort.decoder.convert(-10),
            throwsRangeError,
          ); // Other negative

          // Values definitely outside
          expect(() => unsignedShort.decoder.convert(100000), throwsRangeError);
          expect(() => unsignedShort.decoder.convert(-1000), throwsRangeError);
        },
      );
    });
  });
}
