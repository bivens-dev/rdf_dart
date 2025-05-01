import 'package:test/test.dart';
import 'package:xsd/src/codecs/gMonthDay/g_month_day_codec.dart.dart';
import 'package:xsd/src/implementations/g_month_day.dart';

void main() {
  group('XsdGMonthDay', () {
    group('XsdGMonthDay Constructor', () {
      test('should create a valid XsdGMonthDay', () {
        final gMonthDay = XsdGMonthDay(month: 3, day: 15);
        expect(gMonthDay.month, 3);
        expect(gMonthDay.day, 15);
        expect(gMonthDay.timeZoneOffset, null);
      });

      test('should create a valid XsdGMonthDay with timezone', () {
        final gMonthDay = XsdGMonthDay(
          month: 3,
          day: 15,
          timeZoneOffset: Duration(hours: 5, minutes: 30),
        );
        expect(gMonthDay.month, 3);
        expect(gMonthDay.day, 15);
        expect(gMonthDay.timeZoneOffset, Duration(hours: 5, minutes: 30));
      });

      test('should throw ArgumentError if month is out of range', () {
        expect(() => XsdGMonthDay(month: 0, day: 15), throwsArgumentError);
        expect(() => XsdGMonthDay(month: 13, day: 15), throwsArgumentError);
      });

      test('should throw ArgumentError if day is out of range', () {
        expect(() => XsdGMonthDay(month: 3, day: 0), throwsArgumentError);
        expect(() => XsdGMonthDay(month: 3, day: 32), throwsArgumentError);
      });

      test(
        'should throw ArgumentError if timezone offset is not a whole number of minutes',
        () {
          expect(
            () => XsdGMonthDay(
              month: 3,
              day: 15,
              timeZoneOffset: Duration(seconds: 30),
            ),
            throwsArgumentError,
          );
        },
      );

      test(
        'should not throw ArgumentError if timezone offset is outside the typical range',
        () {
          expect(
            () => XsdGMonthDay(
              month: 3,
              day: 15,
              timeZoneOffset: Duration(hours: 15),
            ),
            returnsNormally,
          );
        },
      );
    });

    group('XsdGMonthDay comparison (compareTo)', () {
      // No Timezone
      final mar15 = XsdGMonthDay(month: 3, day: 15);
      final mar16 = XsdGMonthDay(month: 3, day: 16);
      final apr15 = XsdGMonthDay(month: 4, day: 15);

      test('should compare correctly when no timezone', () {
        expect(mar15.compareTo(mar15), 0);
        expect(mar15.compareTo(mar16), lessThan(0));
        expect(mar16.compareTo(mar15), greaterThan(0));
        expect(mar15.compareTo(apr15), lessThan(0));
        expect(apr15.compareTo(mar15), greaterThan(0));
      });

      // With Timezone
      final mar15Z = XsdGMonthDay(
        month: 3,
        day: 15,
        timeZoneOffset: Duration.zero,
      );
      final mar15P1 = XsdGMonthDay(
        month: 3,
        day: 15,
        timeZoneOffset: Duration(hours: 1),
      ); // Earlier UTC start
      final mar15M1 = XsdGMonthDay(
        month: 3,
        day: 15,
        timeZoneOffset: Duration(hours: -1),
      ); // Later UTC start
      final mar14M1 = XsdGMonthDay(
        month: 3,
        day: 14,
        timeZoneOffset: Duration(hours: -1),
      ); // Definitely earlier
      final mar16P1 = XsdGMonthDay(
        month: 3,
        day: 16,
        timeZoneOffset: Duration(hours: 1),
      ); // Definitely later

      test('should compare correctly when both have timezone', () {
        expect(mar15Z.compareTo(mar15Z), 0);
        expect(
          mar15P1.compareTo(mar15Z),
          lessThan(0),
        ); // +01:00 starts earlier than Z
        expect(mar15Z.compareTo(mar15P1), greaterThan(0));
        expect(
          mar15M1.compareTo(mar15Z),
          greaterThan(0),
        ); // -01:00 starts later than Z
        expect(mar15Z.compareTo(mar15M1), lessThan(0));
        expect(
          mar15P1.compareTo(mar15M1),
          lessThan(0),
        ); // +01:00 starts earlier than -01:00
        expect(mar15M1.compareTo(mar15P1), greaterThan(0));

        // Compare across days
        expect(mar15Z.compareTo(mar14M1), greaterThan(0));
        expect(mar14M1.compareTo(mar15Z), lessThan(0));
        expect(mar15Z.compareTo(mar16P1), lessThan(0));
        expect(mar16P1.compareTo(mar15Z), greaterThan(0));

        // Test case where normalization might cross day boundary conceptually
        // March 1st 00:00 (+01:00) is Feb 28th 23:00 UTC
        // March 1st 00:00 (-01:00) is March 1st 01:00 UTC
        final mar01P1 = XsdGMonthDay(
          month: 3,
          day: 1,
          timeZoneOffset: Duration(hours: 1),
        );
        final mar01M1 = XsdGMonthDay(
          month: 3,
          day: 1,
          timeZoneOffset: Duration(hours: -1),
        );
        expect(mar01P1.compareTo(mar01M1), lessThan(0));
        expect(mar01M1.compareTo(mar01P1), greaterThan(0));
      });

      // Mixed Timezone (Indeterminate - testing the chosen behavior)
      test(
        'should handle comparison when one has timezone and other doesnt',
        () {
          // Assuming convention: no-TZ < TZ
          expect(mar15.compareTo(mar15Z), lessThan(0));
          expect(mar15Z.compareTo(mar15), greaterThan(0));
          expect(mar15.compareTo(mar15M1), lessThan(0));
          expect(mar15M1.compareTo(mar15), greaterThan(0));

          // Test equality case for mixed (should not be equal)
          expect(mar15.compareTo(mar15Z) != 0, isTrue);
        },
      );

      // Test Feb 29
      test('should compare involving Feb 29', () {
        final feb29 = XsdGMonthDay(month: 2, day: 29);
        final mar01 = XsdGMonthDay(month: 3, day: 1);
        expect(feb29.compareTo(mar01), lessThan(0));
        expect(mar01.compareTo(feb29), greaterThan(0));

        // With timezones
        final feb29Z = XsdGMonthDay(
          month: 2,
          day: 29,
          timeZoneOffset: Duration.zero,
        );
        final mar01Z = XsdGMonthDay(
          month: 3,
          day: 1,
          timeZoneOffset: Duration.zero,
        );
        expect(feb29Z.compareTo(mar01Z), lessThan(0));

        // Check normalization around Feb 29 / Mar 1
        // Feb 29 23:00+01:00 -> Feb 29 22:00 UTC
        // Mar 01 00:00-01:00 -> Mar 01 01:00 UTC
        final feb29LateP1 = XsdGMonthDay(
          month: 2,
          day: 29,
          timeZoneOffset: Duration(hours: 1),
        ); // Ends Feb 29 23:00 UTC
        final mar01EarlyM1 = XsdGMonthDay(
          month: 3,
          day: 1,
          timeZoneOffset: Duration(hours: -1),
        ); // Starts Mar 01 01:00 UTC
        expect(feb29LateP1.compareTo(mar01EarlyM1), lessThan(0));
      });
    });

    group('XsdGMonthDay toString', () {
      test('should format a gMonthDay correctly', () {
        final gMonthDay = XsdGMonthDay(month: 3, day: 15);
        expect(gMonthDay.toString(), '--03-15');
      });

      test('should format a gMonthDay with Z timezone correctly', () {
        final gMonthDay = XsdGMonthDay(
          month: 3,
          day: 15,
          timeZoneOffset: Duration.zero,
        );
        expect(gMonthDay.toString(), '--03-15Z');
      });

      test('should format a gMonthDay with positive timezone correctly', () {
        final gMonthDay = XsdGMonthDay(
          month: 3,
          day: 15,
          timeZoneOffset: Duration(hours: 5, minutes: 30),
        );
        expect(gMonthDay.toString(), '--03-15+05:30');
      });

      test('should format a gMonthDay with negative timezone correctly', () {
        final gMonthDay = XsdGMonthDay(
          month: 3,
          day: 15,
          timeZoneOffset: Duration(hours: -8),
        );
        expect(gMonthDay.toString(), '--03-15-08:00');
      });
    });

    group('XsdGMonthDay equality', () {
      test('should be equal if all components are equal', () {
        final gMonthDay1 = XsdGMonthDay(month: 3, day: 15);
        final gMonthDay2 = XsdGMonthDay(month: 3, day: 15);
        expect(gMonthDay1, gMonthDay2);
      });

      test('should not be equal if month is different', () {
        final gMonthDay1 = XsdGMonthDay(month: 3, day: 15);
        final gMonthDay2 = XsdGMonthDay(month: 4, day: 15);
        expect(gMonthDay1, isNot(gMonthDay2));
      });

      test('should not be equal if day is different', () {
        final gMonthDay1 = XsdGMonthDay(month: 3, day: 15);
        final gMonthDay2 = XsdGMonthDay(month: 3, day: 16);
        expect(gMonthDay1, isNot(gMonthDay2));
      });

      test('should not be equal if timezone is different', () {
        final gMonthDay1 = XsdGMonthDay(month: 3, day: 15);
        final gMonthDay2 = XsdGMonthDay(
          month: 3,
          day: 15,
          timeZoneOffset: Duration(hours: 1),
        );
        expect(gMonthDay1, isNot(gMonthDay2));
      });
    });

    group('XsdGMonthDayCodec', () {
      test('should encode a valid gMonthDay string', () {
        final gMonthDay = xsdGMonthDayCodec.encoder.convert('--03-15');
        expect(gMonthDay.month, 3);
        expect(gMonthDay.day, 15);
        expect(gMonthDay.timeZoneOffset, null);
      });

      test('should encode a valid gMonthDay string with Z timezone', () {
        final gMonthDay = xsdGMonthDayCodec.encoder.convert('--03-15Z');
        expect(gMonthDay.month, 3);
        expect(gMonthDay.day, 15);
        expect(gMonthDay.timeZoneOffset, Duration.zero);
      });

      test('should encode a valid gMonthDay string with positive timezone', () {
        final gMonthDay = xsdGMonthDayCodec.encoder.convert('--03-15+05:30');
        expect(gMonthDay.month, 3);
        expect(gMonthDay.day, 15);
        expect(gMonthDay.timeZoneOffset, Duration(hours: 5, minutes: 30));
      });

      test('should encode a valid gMonthDay string with negative timezone', () {
        final gMonthDay = xsdGMonthDayCodec.encoder.convert('--03-15-08:00');
        expect(gMonthDay.month, 3);
        expect(gMonthDay.day, 15);
        expect(gMonthDay.timeZoneOffset, Duration(hours: -8));
      });

      test('should throw FormatException for invalid gMonthDay string', () {
        expect(
          () => xsdGMonthDayCodec.encoder.convert('invalid'),
          throwsFormatException,
        );
      });

      test(
        'should throw FormatException for invalid gMonthDay string with invalid timezone',
        () {
          expect(
            () => xsdGMonthDayCodec.encoder.convert('--03-15+15:00'),
            throwsFormatException,
          );
          expect(
            () => xsdGMonthDayCodec.encoder.convert('--03-15+05:60'),
            throwsFormatException,
          );
        },
      );

      test('should decode a valid XsdGMonthDay', () {
        final gMonthDay = XsdGMonthDay(month: 3, day: 15);
        final encoded = xsdGMonthDayCodec.decoder.convert(gMonthDay);
        expect(encoded, '--03-15');
      });

      test('should decode a valid XsdGMonthDay with Z timezone', () {
        final gMonthDay = XsdGMonthDay(
          month: 3,
          day: 15,
          timeZoneOffset: Duration.zero,
        );
        final encoded = xsdGMonthDayCodec.decoder.convert(gMonthDay);
        expect(encoded, '--03-15Z');
      });

      test('should decode a valid XsdGMonthDay with positive timezone', () {
        final gMonthDay = XsdGMonthDay(
          month: 3,
          day: 15,
          timeZoneOffset: Duration(hours: 5, minutes: 30),
        );
        final encoded = xsdGMonthDayCodec.decoder.convert(gMonthDay);
        expect(encoded, '--03-15+05:30');
      });

      test('should decode a valid XsdGMonthDay with negative timezone', () {
        final gMonthDay = XsdGMonthDay(
          month: 3,
          day: 15,
          timeZoneOffset: Duration(hours: -8),
        );
        final encoded = xsdGMonthDayCodec.decoder.convert(gMonthDay);
        expect(encoded, '--03-15-08:00');
      });
    });
  });
}
