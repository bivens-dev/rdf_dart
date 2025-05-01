import 'package:test/test.dart';
import 'package:xsd/src/codecs/integer/config.dart';
import 'package:xsd/src/codecs/integer/integer_codec.dart';
import 'package:xsd/src/codecs/integer/integer_decoder.dart';
import 'package:xsd/src/codecs/integer/integer_encoder.dart';
import 'package:xsd/src/helpers/whitespace.dart';

void main() {
  group('IntegerCodec', () {
    group('IntegerEncoder', () {
      test('convert "0" to BigInt.zero', () {
        expect(bigIntCodec.encoder.convert('0'), BigInt.zero);
      });

      test('convert "123" to BigInt.from(123)', () {
        expect(bigIntCodec.encoder.convert('123'), BigInt.from(123));
      });

      test('convert "-123" to BigInt.from(-123)', () {
        expect(bigIntCodec.encoder.convert('-123'), BigInt.from(-123));
      });

      test('convert "+123" to BigInt.from(123)', () {
        expect(bigIntCodec.encoder.convert('+123'), BigInt.from(123));
      });

      test('convert large number to BigInt', () {
        expect(
          bigIntCodec.encoder.convert('9223372036854775807'),
          BigInt.parse('9223372036854775807'),
        );
      });

      test('convert leading zeros', () {
        expect(bigIntCodec.encoder.convert('000123'), BigInt.from(123));
        expect(bigIntCodec.encoder.convert('-000123'), BigInt.from(-123));
        expect(bigIntCodec.encoder.convert('+000123'), BigInt.from(123));
      });

      test('throw FormatException for invalid input', () {
        expect(
          () => bigIntCodec.encoder.convert('123.45'),
          throwsFormatException,
        );
        expect(() => bigIntCodec.encoder.convert('abc'), throwsFormatException);
        expect(() => bigIntCodec.encoder.convert(''), throwsFormatException);
        expect(() => bigIntCodec.encoder.convert(' '), throwsFormatException);
        expect(
          () => bigIntCodec.encoder.convert('+ 123'),
          throwsFormatException,
        );
        expect(
          () => bigIntCodec.encoder.convert('- 123'),
          throwsFormatException,
        );
        expect(
          () => bigIntCodec.encoder.convert('+-123'),
          throwsFormatException,
        );
        expect(
          () => bigIntCodec.encoder.convert('-+123'),
          throwsFormatException,
        );
      });
    });

    group('IntegerDecoder', () {
      test('convert BigInt.zero to "0"', () {
        expect(bigIntCodec.decoder.convert(BigInt.zero), '0');
      });

      test('convert BigInt.from(123) to "123"', () {
        expect(bigIntCodec.decoder.convert(BigInt.from(123)), '123');
      });

      test('convert BigInt.from(-123) to "-123"', () {
        expect(bigIntCodec.decoder.convert(BigInt.from(-123)), '-123');
      });

      test('convert large BigInt to string', () {
        expect(
          bigIntCodec.decoder.convert(BigInt.parse('9223372036854775807')),
          '9223372036854775807',
        );
      });
      test('convert large negative BigInt to string', () {
        expect(
          bigIntCodec.decoder.convert(BigInt.parse('-9223372036854775808')),
          '-9223372036854775808',
        );
      });
    });

    group('IntegerCodec', () {
      test('encoder and decoder are correct', () {
        expect(bigIntCodec.encoder, isA<IntegerEncoder>());
        expect(bigIntCodec.decoder, isA<IntegerDecoder>());
      });
    });

    group('constraints', () {
      test('pattern matches valid inputs', () {
        expect(integerConstraints.pattern.hasMatch('0'), true);
        expect(integerConstraints.pattern.hasMatch('123'), true);
        expect(integerConstraints.pattern.hasMatch('-123'), true);
        expect(integerConstraints.pattern.hasMatch('+123'), true);
        expect(
          integerConstraints.pattern.hasMatch('9223372036854775807'),
          true,
        );
        expect(
          integerConstraints.pattern.hasMatch('-9223372036854775808'),
          true,
        );
        expect(integerConstraints.pattern.hasMatch('000123'), true);
        expect(integerConstraints.pattern.hasMatch('-000123'), true);
        expect(integerConstraints.pattern.hasMatch('+000123'), true);
      });

      test('pattern does not match invalid inputs', () {
        expect(integerConstraints.pattern.hasMatch('abc'), false);
        expect(integerConstraints.pattern.hasMatch(''), false);
        expect(integerConstraints.pattern.hasMatch(' '), false);
      });
      test('whitespace is collapsed', () {
        expect(integerConstraints.whitespace, Whitespace.collapse);
      });
    });
  });
}
