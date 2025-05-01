import 'package:test/test.dart';
import 'package:xsd/src/codecs/boolean/boolean_codec.dart';
import 'package:xsd/src/codecs/boolean/boolean_decoder.dart';
import 'package:xsd/src/codecs/boolean/boolean_encoder.dart';
import 'package:xsd/src/codecs/boolean/config.dart';

void main() {
  group('BooleanCodec', () {
    group('BooleanEncoder', () {
      test('convert "true" to true', () {
        expect(booleanCodec.encoder.convert('true'), true);
      });

      test('convert "1" to true', () {
        expect(booleanCodec.encoder.convert('1'), true);
      });

      test('convert "false" to false', () {
        expect(booleanCodec.encoder.convert('false'), false);
      });

      test('convert "0" to false', () {
        expect(booleanCodec.encoder.convert('0'), false);
      });

      test('throw FormatException for invalid input', () {
        expect(
          () => booleanCodec.encoder.convert('TRUE'),
          throwsFormatException,
        );
        expect(
          () => booleanCodec.encoder.convert('FALSE'),
          throwsFormatException,
        );
        expect(() => booleanCodec.encoder.convert('2'), throwsFormatException);
        expect(() => booleanCodec.encoder.convert(''), throwsFormatException);
        expect(() => booleanCodec.encoder.convert(' '), throwsFormatException);
        expect(() => booleanCodec.encoder.convert('+1'), throwsFormatException);
        expect(() => booleanCodec.encoder.convert('-1'), throwsFormatException);
        expect(() => booleanCodec.encoder.convert('+0'), throwsFormatException);
        expect(() => booleanCodec.encoder.convert('-0'), throwsFormatException);
        expect(
          () => booleanCodec.encoder.convert('1.0'),
          throwsFormatException,
        );
        expect(
          () => booleanCodec.encoder.convert('0.0'),
          throwsFormatException,
        );
      });
    });

    group('BooleanDecoder', () {
      test('convert true to "true"', () {
        expect(booleanCodec.decoder.convert(true), 'true');
      });

      test('convert false to "false"', () {
        expect(booleanCodec.decoder.convert(false), 'false');
      });
    });

    group('BooleanCodec', () {
      test('encoder and decoder are correct', () {
        expect(booleanCodec.encoder, isA<BooleanEncoder>());
        expect(booleanCodec.decoder, isA<BooleanDecoder>());
      });
    });
    group('constraints', () {
      test('pattern matches valid inputs', () {
        expect(booleanConstraints.pattern.hasMatch('true'), true);
        expect(booleanConstraints.pattern.hasMatch('false'), true);
        expect(booleanConstraints.pattern.hasMatch('1'), true);
        expect(booleanConstraints.pattern.hasMatch('0'), true);
      });

      test('pattern does not match invalid inputs', () {
        expect(booleanConstraints.pattern.hasMatch('TRUE'), false);
        expect(booleanConstraints.pattern.hasMatch('FALSE'), false);
        expect(booleanConstraints.pattern.hasMatch('2'), false);
        expect(booleanConstraints.pattern.hasMatch(''), false);
        expect(booleanConstraints.pattern.hasMatch(' '), false);
        expect(booleanConstraints.pattern.hasMatch('true '), false);
        expect(booleanConstraints.pattern.hasMatch(' false'), false);
        expect(booleanConstraints.pattern.hasMatch('+1'), false);
        expect(booleanConstraints.pattern.hasMatch('-1'), false);
        expect(booleanConstraints.pattern.hasMatch('+0'), false);
        expect(booleanConstraints.pattern.hasMatch('-0'), false);
        expect(booleanConstraints.pattern.hasMatch('1.0'), false);
        expect(booleanConstraints.pattern.hasMatch('0.0'), false);
      });
    });
  });
}
