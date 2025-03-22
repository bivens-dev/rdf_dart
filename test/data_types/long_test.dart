import 'package:rdf_dart/src/data_types/long.dart';
import 'package:test/test.dart';

void main() {
  group('LongCodec', () {
    group('UnsignedLongEncoder', () {
      test('should parse valid long values', () {
        expect(longCodec.encoder.convert('0'), BigInt.from(0));
        expect(longCodec.encoder.convert('1'), BigInt.from(1));
        expect(
          longCodec.encoder.convert('9223372036854775807'),
          BigInt.parse('9223372036854775807'),
        );
        expect(
          longCodec.encoder.convert('-9223372036854775808'),
          BigInt.parse('-9223372036854775808'),
        );
        expect(longCodec.encoder.convert('  123  '), BigInt.from(123));
        expect(longCodec.encoder.convert('  -123  '), BigInt.from(-123));
        expect(longCodec.encoder.convert('+123'), BigInt.from(123));
      });

      test('should throw FormatException for invalid format', () {
        expect(() => longCodec.encoder.convert('abc'), throwsFormatException);
        expect(() => longCodec.encoder.convert('1.2'), throwsFormatException);
        expect(() => longCodec.encoder.convert('+-1'), throwsFormatException);
        expect(() => longCodec.encoder.convert('--1'), throwsFormatException);
      });

      test('should throw RangeError for values out of range', () {
        expect(
          () => longCodec.encoder.convert('-9223372036854775809'),
          throwsRangeError,
        );
        expect(
          () => longCodec.encoder.convert('9223372036854775808'),
          throwsRangeError,
        );
        expect(
          () => longCodec.encoder.convert('92233720368547758070'),
          throwsRangeError,
        );
      });
    });

    group('UnsignedLongDecoder', () {
      test('should format valid long values', () {
        expect(longCodec.decoder.convert(BigInt.from(0)), '0');
        expect(longCodec.decoder.convert(BigInt.from(1)), '1');
        expect(
          longCodec.decoder.convert(BigInt.parse('9223372036854775807')),
          '9223372036854775807',
        );
        expect(
          longCodec.decoder.convert(BigInt.parse('-9223372036854775808')),
          '-9223372036854775808',
        );
      });

      test('should throw RangeError for values out of range', () {
        expect(
          () => longCodec.decoder.convert(BigInt.parse('-9223372036854775809')),
          throwsRangeError,
        );
        expect(
          () => longCodec.decoder.convert(BigInt.parse('9223372036854775808')),
          throwsRangeError,
        );
        expect(
          () => longCodec.decoder.convert(BigInt.parse('92233720368547758070')),
          throwsRangeError,
        );
      });
    });
  });
}
