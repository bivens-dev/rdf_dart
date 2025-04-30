import 'package:test/test.dart';
import 'package:xsd/src/codecs/date/date_codec.dart';
import 'package:xsd/src/implementations/date.dart';

void main() {
  group('DateCodec', () {
    group('Encoder (Parsing)', () {
      test('should parse valid date strings correctly', () {
        // No TZ
        var d = xsdDateCodec.encoder.convert('2024-03-26');
        expect(d.year, 2024);
        expect(d.month, 3);
        expect(d.day, 26);
        expect(d.timeZoneOffset, isNull);
        // Z TZ
        d = xsdDateCodec.encoder.convert('2024-03-26Z');
        expect(d.year, 2024);
        expect(d.month, 3);
        expect(d.day, 26);
        // + TZ
        d = xsdDateCodec.encoder.convert('2024-03-26+05:30');
        expect(d.year, 2024);
        expect(d.month, 3);
        expect(d.day, 26);
        expect(d.timeZoneOffset, Duration(hours: 5, minutes: 30));
        // - TZ
        d = xsdDateCodec.encoder.convert('2024-03-26-08:00');
        expect(d.year, 2024);
        expect(d.month, 3);
        expect(d.day, 26);
        expect(d.timeZoneOffset, Duration(hours: -8));
        // Max/Min TZ
        d = xsdDateCodec.encoder.convert('2024-03-26+14:00');
        expect(d.timeZoneOffset, Duration(hours: 14));
        d = xsdDateCodec.encoder.convert('2024-03-26-14:00');
        expect(d.timeZoneOffset, Duration(hours: -14));
        // Negative Year
        d = xsdDateCodec.encoder.convert('-0044-01-15');
        expect(d.year, -44);
        expect(d.month, 1);
        expect(d.day, 15);
        expect(d.timeZoneOffset, isNull);
        // Year > 4 digits
        d = xsdDateCodec.encoder.convert('12024-01-01');
        expect(d.year, 12024);
        expect(d.month, 1);
        expect(d.day, 1);
        expect(d.timeZoneOffset, isNull);
        d = xsdDateCodec.encoder.convert('-12024-01-01');
        expect(d.year, -12024);
        expect(d.month, 1);
        expect(d.day, 1);
        expect(d.timeZoneOffset, isNull);
        // Leap day
        d = xsdDateCodec.encoder.convert('2024-02-29');
        expect(d.year, 2024);
        expect(d.month, 2);
        expect(d.day, 29);
      });

      test('should throw FormatException for invalid formats', () {
        expect(
          () => xsdDateCodec.encoder.convert('invalid date'),
          throwsFormatException,
        );
        expect(
          () => xsdDateCodec.encoder.convert('2024/03/26'),
          throwsFormatException,
        ); // Wrong separators
        expect(
          () => xsdDateCodec.encoder.convert('2024-3-26'),
          throwsFormatException,
        ); // Month not 2 digits
        expect(
          () => xsdDateCodec.encoder.convert('2024-03-6'),
          throwsFormatException,
        ); // Day not 2 digits
        expect(
          () => xsdDateCodec.encoder.convert('24-03-26'),
          throwsFormatException,
        ); // Year < 4 digits
        expect(
          () => xsdDateCodec.encoder.convert('0000-01-01'),
          throwsFormatException,
        ); // Year 0000
        expect(
          () => xsdDateCodec.encoder.convert('2024-03-26T10:00:00'),
          throwsFormatException,
        ); // Includes time
        expect(
          () => xsdDateCodec.encoder.convert('2024-03'),
          throwsFormatException,
        ); // Incomplete
      });

      test(
        'should throw FormatException for invalid date components (via constructor)',
        () {
          // Invalid month
          expect(
            () => xsdDateCodec.encoder.convert('2024-13-01'),
            throwsFormatException,
          );
          // Invalid day for month/year
          expect(
            () => xsdDateCodec.encoder.convert('2023-02-29'),
            throwsFormatException,
          ); // Not leap year
          expect(
            () => xsdDateCodec.encoder.convert('2024-04-31'),
            throwsFormatException,
          ); // April 31
        },
      );

      test(
        'should throw FormatException for invalid timezone formats/ranges',
        () {
          expect(
            () => xsdDateCodec.encoder.convert('2024-03-26+14:01'),
            throwsFormatException,
          );
          expect(
            () => xsdDateCodec.encoder.convert('2024-03-26-15:00'),
            throwsFormatException,
          );
          expect(
            () => xsdDateCodec.encoder.convert('2024-03-26+05:60'),
            throwsFormatException,
          ); // Invalid minute
          expect(
            () => xsdDateCodec.encoder.convert('2024-03-26X'),
            throwsFormatException,
          ); // Invalid TZ char
          expect(
            () => xsdDateCodec.encoder.convert('2024-03-26+5:00'),
            throwsFormatException,
          ); // Hour not 2 digits
        },
      );

      test('should handle whitespace correctly (collapse)', () {
        final d = xsdDateCodec.encoder.convert('  2024-03-26Z ');
        expect(d.year, 2024);
        expect(d.month, 3);
        expect(d.day, 26);
      });
    });

    // --- Decoder Tests (XsdDate -> String) ---
    group('Decoder (Formatting)', () {
      test('should format XsdDate object to string correctly', () {
        // Reuses toString tests implicitly, just ensure codec calls it
        final d1 = Date(year: 2024, month: 3, day: 26);
        expect(xsdDateCodec.decoder.convert(d1), '2024-03-26');

        final d2 = Date(
          year: -44,
          month: 1,
          day: 15,
          timeZoneOffset: Duration(hours: -5),
        );
        expect(xsdDateCodec.decoder.convert(d2), '-0044-01-15-05:00');
      });
    });
  });
}
