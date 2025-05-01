import 'package:test/test.dart';
import 'package:xsd/src/codecs/double/double_codec.dart';

void main() {
  group('DoubleCodec', () {
    group('DoubleEncoder', () {
      test('should parse valid double values', () {
        expect(doubleCodec.encoder.convert('0'), 0.0);
        expect(doubleCodec.encoder.convert('1'), 1.0);
        expect(doubleCodec.encoder.convert('1.0'), 1.0);
        expect(doubleCodec.encoder.convert('1.23'), 1.23);
        expect(doubleCodec.encoder.convert('-1.23'), -1.23);
        expect(doubleCodec.encoder.convert('+1.23'), 1.23);
        expect(doubleCodec.encoder.convert('.23'), 0.23);
        expect(doubleCodec.encoder.convert('  123.456  '), 123.456);
        expect(doubleCodec.encoder.convert('  -123.456  '), -123.456);
        expect(doubleCodec.encoder.convert('1.0e+1'), 10.0);
        expect(doubleCodec.encoder.convert('1.0e-10'), 1e-10);
        expect(doubleCodec.encoder.convert('INF'), double.infinity);
        expect(doubleCodec.encoder.convert('-INF'), double.negativeInfinity);
        expect(doubleCodec.encoder.convert('NaN').isNaN, isTrue);
        expect(doubleCodec.encoder.convert('1E30'), 1e+30);
        expect(doubleCodec.encoder.convert('1.23456E2'), 123.456);
        expect(doubleCodec.encoder.convert('1.23456e2'), 123.456);
        expect(doubleCodec.encoder.convert('1.23456e+2'), 123.456);
        expect(doubleCodec.encoder.convert('1.23456E+2'), 123.456);
        expect(doubleCodec.encoder.convert('1.23456E-2'), 0.0123456);
        expect(doubleCodec.encoder.convert('1.23456e-2'), 0.0123456);
        expect(doubleCodec.encoder.convert('inf'), double.infinity);
        expect(doubleCodec.encoder.convert('-inf'), double.negativeInfinity);
        expect(doubleCodec.encoder.convert('nan').isNaN, isTrue);
      });

      test('should throw FormatException for invalid format', () {
        expect(() => doubleCodec.encoder.convert('abc'), throwsFormatException);
        expect(() => doubleCodec.encoder.convert('+-1'), throwsFormatException);
        expect(() => doubleCodec.encoder.convert('--1'), throwsFormatException);
        expect(
          () => doubleCodec.encoder.convert('1..2'),
          throwsFormatException,
        );
        expect(
          () => doubleCodec.encoder.convert('1.0e1 foo'),
          throwsFormatException,
        );
        expect(
          () => doubleCodec.encoder.convert('foo 1.1e1'),
          throwsFormatException,
        );
        expect(() => doubleCodec.encoder.convert('1e'), throwsFormatException);
        expect(
          () => doubleCodec.encoder.convert('1 2 3'),
          throwsFormatException,
        );
      });
    });

    group('DoubleDecoder', () {
      test('should format valid double values', () {
        expect(doubleCodec.decoder.convert(0.0), '0.0E0');
        expect(doubleCodec.decoder.convert(-0.0), '-0.0E0');
        expect(doubleCodec.decoder.convert(1.0), '1.0E0');
        expect(doubleCodec.decoder.convert(1.23), '1.23E0');
        expect(doubleCodec.decoder.convert(-1.23), '-1.23E0');
        expect(doubleCodec.decoder.convert(double.infinity), 'INF');
        expect(doubleCodec.decoder.convert(double.negativeInfinity), '-INF');
        expect(doubleCodec.decoder.convert(double.nan), 'NaN');
        expect(doubleCodec.decoder.convert(123.456), '1.23456E2');
        expect(doubleCodec.decoder.convert(0.1), '1.0E-1');
        expect(doubleCodec.decoder.convert(0.0000000001), '1.0E-10');
        expect(doubleCodec.decoder.convert(1.23e6), '1.23E6');
        expect(doubleCodec.decoder.convert(-456e-2), '-4.56E0');
        expect(
          doubleCodec.decoder.convert(1.2345678901234567890123457890),
          '1.2345678901234567E0',
        );
      });
    });

    group('matchesLexicalSpace', () {
      test('should match valid lexical space', () {
        expect(DoubleCodec.matchesLexicalSpace('0'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1.0'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1.23'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('-1.23'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('+1.23'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('.23'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('123.456'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('-123.456'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1.0e+1'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1.0e-10'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('INF'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('-INF'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('NaN'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1E30'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1.23456E2'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1.23456e2'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1.23456e+2'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1.23456E+2'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1.23456E-2'), isTrue);
        expect(DoubleCodec.matchesLexicalSpace('1.23456e-2'), isTrue);
      });

      test('should not match invalid lexical space', () {
        expect(DoubleCodec.matchesLexicalSpace('abc'), isFalse);
        expect(DoubleCodec.matchesLexicalSpace('+-1'), isFalse);
        expect(DoubleCodec.matchesLexicalSpace('--1'), isFalse);
        expect(DoubleCodec.matchesLexicalSpace('1..2'), isFalse);
        expect(DoubleCodec.matchesLexicalSpace('1.0e1 foo'), isFalse);
        expect(DoubleCodec.matchesLexicalSpace('foo 1.1e1'), isFalse);
        expect(DoubleCodec.matchesLexicalSpace('1e'), isFalse);
        expect(DoubleCodec.matchesLexicalSpace('1 2 3'), isFalse);
        // Not according to the spec provided Regex
        expect(DoubleCodec.matchesLexicalSpace('+INF'), isFalse);
        // The following also don't match according to the spec but
        // when using the condec interface to convert we uppercase
        // them in practice to they are still technically valid.
        expect(DoubleCodec.matchesLexicalSpace('inf'), isFalse);
        expect(DoubleCodec.matchesLexicalSpace('-inf'), isFalse);
        expect(DoubleCodec.matchesLexicalSpace('nan'), isFalse);
      });
    });
  });
}
