import 'package:rdf_dart/src/data_types/boolean.dart';
import 'package:test/test.dart';

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
        expect(
          () => booleanCodec.encoder.convert('true '),
          throwsFormatException,
        );
        expect(
          () => booleanCodec.encoder.convert(' false'),
          throwsFormatException,
        );
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
        expect(BooleanCodec.constraints.pattern.hasMatch('true'), true);
        expect(BooleanCodec.constraints.pattern.hasMatch('false'), true);
        expect(BooleanCodec.constraints.pattern.hasMatch('1'), true);
        expect(BooleanCodec.constraints.pattern.hasMatch('0'), true);
      });

      test('pattern does not match invalid inputs', () {
        expect(BooleanCodec.constraints.pattern.hasMatch('TRUE'), false);
        expect(BooleanCodec.constraints.pattern.hasMatch('FALSE'), false);
        expect(BooleanCodec.constraints.pattern.hasMatch('2'), false);
        expect(BooleanCodec.constraints.pattern.hasMatch(''), false);
        expect(BooleanCodec.constraints.pattern.hasMatch(' '), false);
        expect(BooleanCodec.constraints.pattern.hasMatch('true '), false);
        expect(BooleanCodec.constraints.pattern.hasMatch(' false'), false);
        expect(BooleanCodec.constraints.pattern.hasMatch('+1'), false);
        expect(BooleanCodec.constraints.pattern.hasMatch('-1'), false);
        expect(BooleanCodec.constraints.pattern.hasMatch('+0'), false);
        expect(BooleanCodec.constraints.pattern.hasMatch('-0'), false);
        expect(BooleanCodec.constraints.pattern.hasMatch('1.0'), false);
        expect(BooleanCodec.constraints.pattern.hasMatch('0.0'), false);
      });
    });
  });
}
