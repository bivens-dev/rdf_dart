import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:xsd/src/codecs/duration/duration_codec.dart';
import 'package:xsd/src/implementations/duration.dart';

void main() {
  group('DurationCodec', () {
    group('DurationEncoder', () {
      test('should parse valid duration values', () {
        expect(
          durationCodec.encoder.convert('P2Y6M5DT12H35M30S'),
          XSDDuration(
            years: 2,
            months: 6,
            days: 5,
            hours: 12,
            minutes: 35,
            seconds: Decimal.parse('30'),
          ),
        );
        expect(
          durationCodec.encoder.convert('P1DT2H'),
          XSDDuration(days: 1, hours: 2),
        );
        expect(durationCodec.encoder.convert('P20M'), XSDDuration(months: 20));
        expect(
          durationCodec.encoder.convert('PT20M'),
          XSDDuration(minutes: 20),
        );
        expect(
          durationCodec.encoder.convert('P0Y20M0D'),
          XSDDuration(years: 0, months: 20, days: 0),
        );
        expect(durationCodec.encoder.convert('P0Y'), XSDDuration(years: 0));
        expect(durationCodec.encoder.convert('-P60D'), XSDDuration(days: -60));
        expect(
          durationCodec.encoder.convert('PT1M30.5S'),
          XSDDuration(minutes: 1, seconds: Decimal.parse('30.5')),
        );
        expect(
          durationCodec.encoder.convert('-P1Y2M3DT4H5M6S'),
          XSDDuration(
            years: -1,
            months: -2,
            days: -3,
            hours: -4,
            minutes: -5,
            seconds: Decimal.parse('-6'),
          ),
        );
        expect(
          durationCodec.encoder.convert('P1Y2M3DT4H5M6S'),
          XSDDuration(
            years: 1,
            months: 2,
            days: 3,
            hours: 4,
            minutes: 5,
            seconds: Decimal.parse('6'),
          ),
        );
        expect(durationCodec.encoder.convert('P1Y'), XSDDuration(years: 1));
        expect(
          durationCodec.encoder.convert('PT1S'),
          XSDDuration(seconds: Decimal.parse('1')),
        );
        expect(
          durationCodec.encoder.convert('PT0S'),
          XSDDuration(seconds: Decimal.parse('0')),
        );
        expect(durationCodec.encoder.convert('P0D'), XSDDuration(days: 0));
        expect(durationCodec.encoder.convert('P0M'), XSDDuration(months: 0));
        expect(durationCodec.encoder.convert('P0Y'), XSDDuration(years: 0));
        expect(
          durationCodec.encoder.convert('P0Y0M0DT0H0M0S'),
          XSDDuration(
            years: 0,
            months: 0,
            days: 0,
            hours: 0,
            minutes: 0,
            seconds: Decimal.parse('0'),
          ),
        );
        expect(durationCodec.encoder.convert('  P1Y  '), XSDDuration(years: 1));
      });

      test('should throw FormatException for invalid format', () {
        expect(
          () => durationCodec.encoder.convert('abc'),
          throwsFormatException,
        );
        expect(
          () => durationCodec.encoder.convert('P1Y2M3D4H5M6S'),
          throwsFormatException,
        );
        expect(
          () => durationCodec.encoder.convert('P1Y2M3DT4H5M6'),
          throwsFormatException,
        );
        expect(
          () => durationCodec.encoder.convert('P1Y2M3DT4H5M6SS'),
          throwsFormatException,
        );
        expect(
          () => durationCodec.encoder.convert('P1Y2M3DT4H5M6.S'),
          throwsFormatException,
        );
      });
    });

    group('DurationDecoder', () {
      test('should format valid duration components', () {
        expect(
          durationCodec.decoder.convert(
            XSDDuration(
              years: 2,
              months: 6,
              days: 5,
              hours: 12,
              minutes: 35,
              seconds: Decimal.parse('30'),
            ),
          ),
          'P2Y6M5DT12H35M30S',
        );
        expect(
          durationCodec.decoder.convert(XSDDuration(days: 1, hours: 2)),
          'P1DT2H',
        );
        expect(durationCodec.decoder.convert(XSDDuration(months: 20)), 'P20M');
        expect(
          durationCodec.decoder.convert(XSDDuration(minutes: 20)),
          'PT20M',
        );
        expect(
          durationCodec.decoder.convert(
            XSDDuration(years: 0, months: 20, days: 0),
          ),
          'P20M',
        );
        expect(durationCodec.decoder.convert(XSDDuration(years: 0)), 'PT0S');
        expect(durationCodec.decoder.convert(XSDDuration(days: -60)), '-P60D');
        expect(
          durationCodec.decoder.convert(
            XSDDuration(minutes: 1, seconds: Decimal.parse('30.5')),
          ),
          'PT1M30.5S',
        );
        expect(
          durationCodec.decoder.convert(
            XSDDuration(
              years: -1,
              months: -2,
              days: -3,
              hours: -4,
              minutes: -5,
              seconds: Decimal.parse('-6'),
            ),
          ),
          '-P1Y2M3DT4H5M6S',
        );
        expect(
          durationCodec.decoder.convert(
            XSDDuration(
              years: 1,
              months: 2,
              days: 3,
              hours: 4,
              minutes: 5,
              seconds: Decimal.parse('6'),
            ),
          ),
          'P1Y2M3DT4H5M6S',
        );
        expect(durationCodec.decoder.convert(XSDDuration(years: 1)), 'P1Y');
        expect(
          durationCodec.decoder.convert(
            XSDDuration(seconds: Decimal.parse('1')),
          ),
          'PT1S',
        );
        expect(
          durationCodec.decoder.convert(
            XSDDuration(seconds: Decimal.parse('0')),
          ),
          'PT0S',
        );
        expect(durationCodec.decoder.convert(XSDDuration(days: 0)), 'PT0S');
        expect(durationCodec.decoder.convert(XSDDuration(months: 0)), 'PT0S');
        expect(durationCodec.decoder.convert(XSDDuration(years: 0)), 'PT0S');
        expect(
          durationCodec.decoder.convert(
            XSDDuration(
              years: 0,
              months: 0,
              days: 0,
              hours: 0,
              minutes: 0,
              seconds: Decimal.parse('0'),
            ),
          ),
          'PT0S',
        );
        expect(
          durationCodec.decoder.convert(
            XSDDuration(
              years: 1,
              months: 0,
              days: 0,
              hours: 0,
              minutes: 0,
              seconds: Decimal.parse('0'),
            ),
          ),
          'P1Y',
        );
        expect(
          durationCodec.decoder.convert(
            XSDDuration(
              years: 0,
              months: 1,
              days: 0,
              hours: 0,
              minutes: 0,
              seconds: Decimal.parse('0'),
            ),
          ),
          'P1M',
        );
        expect(
          durationCodec.decoder.convert(
            XSDDuration(
              years: 0,
              months: 0,
              days: 1,
              hours: 0,
              minutes: 0,
              seconds: Decimal.parse('0'),
            ),
          ),
          'P1D',
        );
        expect(
          durationCodec.decoder.convert(
            XSDDuration(
              years: 0,
              months: 0,
              days: 0,
              hours: 1,
              minutes: 0,
              seconds: Decimal.parse('0'),
            ),
          ),
          'PT1H',
        );
        expect(
          durationCodec.decoder.convert(
            XSDDuration(
              years: 0,
              months: 0,
              days: 0,
              hours: 0,
              minutes: 1,
              seconds: Decimal.parse('0'),
            ),
          ),
          'PT1M',
        );
        expect(
          durationCodec.decoder.convert(
            XSDDuration(
              years: 0,
              months: 0,
              days: 0,
              hours: 0,
              minutes: 0,
              seconds: Decimal.parse('1'),
            ),
          ),
          'PT1S',
        );
      });
    });
  });
}
