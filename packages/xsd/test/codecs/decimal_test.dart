import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:xsd/src/codecs/decimal/decimal_codec.dart';

void main() {
  group('DecimalCodec', () {
    group('DecimalEncoder', () {
      test('should parse valid decimal values', () {
        expect(decimalCodec.encoder.convert('0'), Decimal.parse('0'));
        expect(decimalCodec.encoder.convert('1'), Decimal.parse('1'));
        expect(decimalCodec.encoder.convert('1.0'), Decimal.parse('1.0'));
        expect(decimalCodec.encoder.convert('1.23'), Decimal.parse('1.23'));
        expect(decimalCodec.encoder.convert('-1.23'), Decimal.parse('-1.23'));
        expect(decimalCodec.encoder.convert('+1.23'), Decimal.parse('+1.23'));
        expect(decimalCodec.encoder.convert('.23'), Decimal.parse('.23'));
        expect(
          decimalCodec.encoder.convert('  123.456  '),
          Decimal.parse('123.456'),
        );
        expect(
          decimalCodec.encoder.convert('  -123.456  '),
          Decimal.parse('-123.456'),
        );
      });

      test('should throw FormatException for invalid format', () {
        expect(
          () => decimalCodec.encoder.convert('abc'),
          throwsFormatException,
        );
        expect(
          () => decimalCodec.encoder.convert('+-1'),
          throwsFormatException,
        );
        expect(
          () => decimalCodec.encoder.convert('--1'),
          throwsFormatException,
        );
        expect(
          () => decimalCodec.encoder.convert('1..2'),
          throwsFormatException,
        );
        expect(
          () => decimalCodec.encoder.convert('1,2'),
          throwsFormatException,
        );
      });
    });

    group('DecimalDecoder', () {
      test('should format valid decimal values', () {
        expect(decimalCodec.decoder.convert(Decimal.parse('0')), '0');
        expect(decimalCodec.decoder.convert(Decimal.parse('1')), '1');
        expect(decimalCodec.decoder.convert(Decimal.parse('1.0')), '1');
        expect(decimalCodec.decoder.convert(Decimal.parse('1.23')), '1.23');
        expect(decimalCodec.decoder.convert(Decimal.parse('-1.23')), '-1.23');
        expect(decimalCodec.decoder.convert(Decimal.parse('+1.23')), '1.23');
      });
    });
  });
}
