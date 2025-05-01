import 'package:test/test.dart';
import 'package:xsd/src/codecs/unsignedLong/unsigned_long_codec.dart';

void main() {
  group('UnsignedLongCodec', () {
    group('UnsignedLongEncoder', () {
      test('should parse valid unsignedLong values', () {
        expect(unsignedLong.encoder.convert('0'), BigInt.from(0));
        expect(unsignedLong.encoder.convert('1'), BigInt.from(1));
        expect(
          unsignedLong.encoder.convert('18446744073709551615'),
          BigInt.parse('18446744073709551615'),
        );
        expect(unsignedLong.encoder.convert('  123  '), BigInt.from(123));
      });

      test('should throw FormatException for invalid format', () {
        expect(
          () => unsignedLong.encoder.convert('abc'),
          throwsFormatException,
        );
        expect(
          () => unsignedLong.encoder.convert('1.2'),
          throwsFormatException,
        );
        expect(
          () => unsignedLong.encoder.convert('+-1'),
          throwsFormatException,
        );
      });

      test('should throw RangeError for values out of range', () {
        expect(() => unsignedLong.encoder.convert('-1'), throwsRangeError);
        expect(
          () => unsignedLong.encoder.convert('18446744073709551616'),
          throwsRangeError,
        );
        expect(
          () => unsignedLong.encoder.convert('184467440737095516150'),
          throwsRangeError,
        );
      });
    });

    group('UnsignedLongDecoder', () {
      test('should format valid unsignedLong values', () {
        expect(unsignedLong.decoder.convert(BigInt.from(0)), '0');
        expect(unsignedLong.decoder.convert(BigInt.from(1)), '1');
        expect(
          unsignedLong.decoder.convert(BigInt.parse('18446744073709551615')),
          '18446744073709551615',
        );
      });
    });
  });
}
