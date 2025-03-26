import 'package:rdf_dart/src/data_types/date.dart';
// Assuming Whitespace enum/helper is accessible
import 'package:test/test.dart';

void main() {
  group('XsdDate', () {
    // --- Constructor Tests ---
    group('Constructor', () {
      test('should create valid XsdDate instances', () {
        // Positive year, no TZ
        expect(() => XsdDate(year: 2024, month: 3, day: 26), returnsNormally);
        // Negative year, no TZ
        expect(() => XsdDate(year: -44, month: 1, day: 15), returnsNormally);
        // Leap year day, no TZ
        expect(() => XsdDate(year: 2024, month: 2, day: 29), returnsNormally);
        // With Z timezone
        expect(
          () => XsdDate(
            year: 2024,
            month: 3,
            day: 26,
            timeZoneOffset: Duration.zero,
          ),
          returnsNormally,
        );
        // With positive offset
        expect(
          () => XsdDate(
            year: 2024,
            month: 3,
            day: 26,
            timeZoneOffset: Duration(hours: 5, minutes: 30),
          ),
          returnsNormally,
        );
        // With negative offset
        expect(
          () => XsdDate(
            year: 2024,
            month: 3,
            day: 26,
            timeZoneOffset: Duration(hours: -8),
          ),
          returnsNormally,
        );
        // With max positive offset
        expect(
          () => XsdDate(
            year: 2024,
            month: 3,
            day: 26,
            timeZoneOffset: Duration(hours: 14),
          ),
          returnsNormally,
        );
        // With max negative offset
        expect(
          () => XsdDate(
            year: 2024,
            month: 3,
            day: 26,
            timeZoneOffset: Duration(hours: -14),
          ),
          returnsNormally,
        );
        // Year > 4 digits
        expect(() => XsdDate(year: 12024, month: 1, day: 1), returnsNormally);
      });

      test('should throw ArgumentError for invalid year (0)', () {
        expect(() => XsdDate(year: 0, month: 1, day: 1), throwsArgumentError);
      });

      test('should throw ArgumentError for invalid month', () {
        expect(
          () => XsdDate(year: 2024, month: 0, day: 1),
          throwsArgumentError,
        );
        expect(
          () => XsdDate(year: 2024, month: 13, day: 1),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for invalid day', () {
        // Day 0
        expect(
          () => XsdDate(year: 2024, month: 1, day: 0),
          throwsArgumentError,
        );
        // Day 32
        expect(
          () => XsdDate(year: 2024, month: 1, day: 32),
          throwsArgumentError,
        );
        // Day 31 in April
        expect(
          () => XsdDate(year: 2024, month: 4, day: 31),
          throwsArgumentError,
        );
        // Feb 29 in non-leap year
        expect(
          () => XsdDate(year: 2023, month: 2, day: 29),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for invalid timezone offset', () {
        // Not whole minutes
        expect(
          () => XsdDate(
            year: 2024,
            month: 3,
            day: 26,
            timeZoneOffset: Duration(seconds: 30),
          ),
          throwsArgumentError,
        );
        // Offset > +14:00
        expect(
          () => XsdDate(
            year: 2024,
            month: 3,
            day: 26,
            timeZoneOffset: Duration(hours: 14, minutes: 1),
          ),
          throwsArgumentError,
        );
        expect(
          () => XsdDate(
            year: 2024,
            month: 3,
            day: 26,
            timeZoneOffset: Duration(hours: 15),
          ),
          throwsArgumentError,
        );
        // Offset < -14:00
        expect(
          () => XsdDate(
            year: 2024,
            month: 3,
            day: 26,
            timeZoneOffset: Duration(hours: -14, minutes: -1),
          ),
          throwsArgumentError,
        );
        expect(
          () => XsdDate(
            year: 2024,
            month: 3,
            day: 26,
            timeZoneOffset: Duration(hours: -15),
          ),
          throwsArgumentError,
        );
      });
    });

    // --- toString() Tests ---
    group('toString()', () {
      test('should format correctly without timezone', () {
        final d = XsdDate(year: 2024, month: 3, day: 26);
        expect(d.toString(), '2024-03-26');
      });
      test('should format correctly with Z timezone', () {
        final d = XsdDate(
          year: 2024,
          month: 3,
          day: 26,
          timeZoneOffset: Duration.zero,
        );
        expect(d.toString(), '2024-03-26Z');
      });
      test('should format correctly with positive timezone', () {
        final d = XsdDate(
          year: 2024,
          month: 3,
          day: 26,
          timeZoneOffset: Duration(hours: 5, minutes: 30),
        );
        expect(d.toString(), '2024-03-26+05:30');
      });
      test('should format correctly with negative timezone', () {
        final d = XsdDate(
          year: 2024,
          month: 3,
          day: 26,
          timeZoneOffset: Duration(hours: -8),
        );
        expect(d.toString(), '2024-03-26-08:00');
      });
      test('should format correctly with max timezones', () {
        final dPos = XsdDate(
          year: 2024,
          month: 3,
          day: 26,
          timeZoneOffset: Duration(hours: 14),
        );
        expect(dPos.toString(), '2024-03-26+14:00');
        final dNeg = XsdDate(
          year: 2024,
          month: 3,
          day: 26,
          timeZoneOffset: Duration(hours: -14),
        );
        expect(dNeg.toString(), '2024-03-26-14:00');
      });
      test('should format negative years correctly', () {
        final d = XsdDate(year: -44, month: 1, day: 15);
        expect(d.toString(), '-0044-01-15'); // Ensure 4 digits after sign
        final d2 = XsdDate(year: -12345, month: 1, day: 1);
        expect(d2.toString(), '-12345-01-01'); // More than 4 digits
      });
      test('should format positive years > 4 digits correctly', () {
        final d = XsdDate(year: 12024, month: 1, day: 1);
        expect(d.toString(), '12024-01-01');
      });
    });

    // --- Equality and HashCode Tests ---
    group('Equality and hashCode', () {
      test('should be equal if components are equal', () {
        final d1 = XsdDate(year: 2024, month: 3, day: 26);
        final d2 = XsdDate(year: 2024, month: 3, day: 26);
        expect(d1, equals(d2));
        expect(d1.hashCode, equals(d2.hashCode));

        final d3 = XsdDate(
          year: 2024,
          month: 3,
          day: 26,
          timeZoneOffset: Duration(hours: -5),
        );
        final d4 = XsdDate(
          year: 2024,
          month: 3,
          day: 26,
          timeZoneOffset: Duration(hours: -5),
        );
        expect(d3, equals(d4));
        expect(d3.hashCode, equals(d4.hashCode));
      });

      test('should not be equal if components differ', () {
        final d1 = XsdDate(year: 2024, month: 3, day: 26);
        // Different year
        expect(d1, isNot(equals(XsdDate(year: 2023, month: 3, day: 26))));
        // Different month
        expect(d1, isNot(equals(XsdDate(year: 2024, month: 4, day: 26))));
        // Different day
        expect(d1, isNot(equals(XsdDate(year: 2024, month: 3, day: 27))));
        // Different timezone presence
        expect(
          d1,
          isNot(
            equals(
              XsdDate(
                year: 2024,
                month: 3,
                day: 26,
                timeZoneOffset: Duration.zero,
              ),
            ),
          ),
        );
        // Different timezone value
        final dTz1 = XsdDate(
          year: 2024,
          month: 3,
          day: 26,
          timeZoneOffset: Duration(hours: 1),
        );
        final dTz2 = XsdDate(
          year: 2024,
          month: 3,
          day: 26,
          timeZoneOffset: Duration(hours: 2),
        );
        expect(dTz1, isNot(equals(dTz2)));
      });
    });

    // --- Comparison Tests ---
    group('Comparison (compareTo)', () {
      // No Timezone instances
      final d2024_03_26 = XsdDate(year: 2024, month: 3, day: 26);
      final d2024_03_27 = XsdDate(year: 2024, month: 3, day: 27);
      final d2024_04_01 = XsdDate(year: 2024, month: 4, day: 1);
      final d2025_01_01 = XsdDate(year: 2025, month: 1, day: 1);
      final dNeg = XsdDate(year: -44, month: 1, day: 1);

      test('should compare correctly when no timezone', () {
        expect(d2024_03_26.compareTo(d2024_03_26), 0);
        expect(d2024_03_26.compareTo(d2024_03_27), lessThan(0));
        expect(d2024_03_27.compareTo(d2024_03_26), greaterThan(0));
        expect(d2024_03_26.compareTo(d2024_04_01), lessThan(0));
        expect(d2024_04_01.compareTo(d2024_03_26), greaterThan(0));
        expect(d2024_03_26.compareTo(d2025_01_01), lessThan(0));
        expect(d2025_01_01.compareTo(d2024_03_26), greaterThan(0));
        expect(dNeg.compareTo(d2024_03_26), lessThan(0));
        expect(d2024_03_26.compareTo(dNeg), greaterThan(0));
      });

      // With Timezone instances
      final d2024_03_26Z = XsdDate(
        year: 2024,
        month: 3,
        day: 26,
        timeZoneOffset: Duration.zero,
      );
      final d2024_03_26P1 = XsdDate(
        year: 2024,
        month: 3,
        day: 26,
        timeZoneOffset: Duration(hours: 1),
      );
      final d2024_03_26M1 = XsdDate(
        year: 2024,
        month: 3,
        day: 26,
        timeZoneOffset: Duration(hours: -1),
      );
      final d2024_03_25M1 = XsdDate(
        year: 2024,
        month: 3,
        day: 25,
        timeZoneOffset: Duration(hours: -1),
      ); // Earlier day
      final d2024_03_27P1 = XsdDate(
        year: 2024,
        month: 3,
        day: 27,
        timeZoneOffset: Duration(hours: 1),
      ); // Later day

      // Dates around timezone boundary crossing UTC midnight
      final d20240326End = XsdDate(
        year: 2024,
        month: 3,
        day: 26,
        timeZoneOffset: Duration(hours: -1),
      ); // Starts 2024-03-26 01:00Z
      final d20240327Start = XsdDate(
        year: 2024,
        month: 3,
        day: 27,
        timeZoneOffset: Duration(hours: 1),
      ); // Starts 2024-03-26 23:00Z

      test('should compare correctly when both have timezone', () {
        expect(d2024_03_26Z.compareTo(d2024_03_26Z), 0);
        // +01:00 starts earlier than Z for the same date
        expect(d2024_03_26P1.compareTo(d2024_03_26Z), lessThan(0));
        expect(d2024_03_26Z.compareTo(d2024_03_26P1), greaterThan(0));
        // -01:00 starts later than Z for the same date
        expect(d2024_03_26M1.compareTo(d2024_03_26Z), greaterThan(0));
        expect(d2024_03_26Z.compareTo(d2024_03_26M1), lessThan(0));
        // Compare across days
        expect(d2024_03_26Z.compareTo(d2024_03_25M1), greaterThan(0));
        expect(d2024_03_25M1.compareTo(d2024_03_26Z), lessThan(0));
        expect(d2024_03_26Z.compareTo(d2024_03_27P1), lessThan(0));
        expect(d2024_03_27P1.compareTo(d2024_03_26Z), greaterThan(0));
        // Compare dates that start close in UTC
        expect(
          d20240327Start.compareTo(d20240326End),
          greaterThan(0),
        ); // 27th(+1) starts after 26th(-1) ends
        expect(d20240326End.compareTo(d20240327Start), lessThan(0));
      });

      test(
        'should handle comparison when one has timezone and other doesnt',
        () {
          // Assuming convention: no-TZ < TZ
          expect(d2024_03_26.compareTo(d2024_03_26Z), lessThan(0));
          expect(d2024_03_26Z.compareTo(d2024_03_26), greaterThan(0));
          // Check hash codes aren't equal
          expect(d2024_03_26.hashCode, isNot(equals(d2024_03_26Z.hashCode)));
        },
      );
    });
  });

  group('XsdDateCodec', () {
    // --- Encoder Tests (String -> XsdDate) ---
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
        final d1 = XsdDate(year: 2024, month: 3, day: 26);
        expect(xsdDateCodec.decoder.convert(d1), '2024-03-26');

        final d2 = XsdDate(
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
