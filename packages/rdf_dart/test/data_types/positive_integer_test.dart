import 'package:rdf_dart/src/data_types/positive_integer.dart';
import 'package:test/test.dart';

void main() {
  group('PositiveIntegerCodec', () {
    group('PositiveIntegerEncoder', () {
      test('should parse valid positiveInteger values', () {
        expect(positiveInteger.encoder.convert('1'), 1);
        expect(positiveInteger.encoder.convert('10'), 10);
        expect(positiveInteger.encoder.convert('12345'), 12345);
        expect(positiveInteger.encoder.convert('  123  '), 123);
      });

      test('should throw FormatException for invalid format', () {
        expect(
          () => positiveInteger.encoder.convert('abc'),
          throwsFormatException,
        );
        expect(
          () => positiveInteger.encoder.convert('1.2'),
          throwsFormatException,
        );
        expect(
          () => positiveInteger.encoder.convert('+-1'),
          throwsFormatException,
        );
      });

      test('should throw RangeError for values out of range', () {
        expect(() => positiveInteger.encoder.convert('0'), throwsRangeError);
        expect(() => positiveInteger.encoder.convert('-1'), throwsRangeError);
      });
    });

    group('PositiveIntegerDecoder', () {
      test('should format valid positiveInteger values', () {
        expect(positiveInteger.decoder.convert(1), '1');
        expect(positiveInteger.decoder.convert(10), '10');
        expect(positiveInteger.decoder.convert(12345), '12345');
      });

      test('should throw RangeError for values out of range', () {
        expect(() => positiveInteger.decoder.convert(0), throwsRangeError);
        expect(() => positiveInteger.decoder.convert(-1), throwsRangeError);
      });
    });
  });
}
