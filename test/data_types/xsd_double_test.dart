import 'package:rdf_dart/src/data_types/xsd_double.dart';
import 'package:test/test.dart';

void main() {
  group('XSDDouble', () {
    late XSDDouble xsdDouble;

    setUp(() {
      xsdDouble = const XSDDouble();
    });

    test('lexicalToValue - valid values', () {
      expect(xsdDouble.lexicalToValue('0.0E0'), 0.0);
      expect(xsdDouble.lexicalToValue('-0.0E0'), -0.0); // Negative zero
      expect(xsdDouble.lexicalToValue('1.0E0'), 1.0);
      expect(xsdDouble.lexicalToValue('123.456'), 123.456);
      expect(xsdDouble.lexicalToValue('1.23456E2'), 123.456);
      expect(xsdDouble.lexicalToValue('1.0e+1'), 10.0);
      expect(xsdDouble.lexicalToValue('1.0e-10'), 1e-10);
      expect(xsdDouble.lexicalToValue('INF'), double.infinity);
      expect(xsdDouble.lexicalToValue('+INF'), double.infinity);
      expect(xsdDouble.lexicalToValue('-INF'), double.negativeInfinity);
      expect(
        xsdDouble.lexicalToValue('NaN'),
        isNaN,
      ); // Dart's double.nan.isNaN is true

      // Test cases that check correct rounding to float precision
      expect(xsdDouble.lexicalToValue('1E30'), 1e+30);
    });

    test('lexicalToValue - invalid values', () {
      expect(
        () => xsdDouble.lexicalToValue('1.0e1 foo'),
        throwsFormatException,
      );
      expect(
        () => xsdDouble.lexicalToValue('foo 1.1e1'),
        throwsFormatException,
      );
      expect(() => xsdDouble.lexicalToValue('foo'), throwsFormatException);
      expect(() => xsdDouble.lexicalToValue('12.xyz'), throwsFormatException);
    });

    test('valueToLexical - Special values', () {
      expect(xsdDouble.valueToLexical(double.nan), 'NaN');
      expect(xsdDouble.valueToLexical(double.infinity), 'INF');
      expect(xsdDouble.valueToLexical(double.negativeInfinity), '-INF');
      expect(xsdDouble.valueToLexical(0.0), '0.0E0');
      expect(xsdDouble.valueToLexical(-0.0), '-0.0E0');
    });

    test('valueToLexical - canonical forms', () {
      expect(xsdDouble.valueToLexical(1.0), '1.0E0'); //Ensure it's an exponent
      expect(
        xsdDouble.valueToLexical(123.456),
        '1.23456E2',
      ); //Ensure correct formatting
      expect(xsdDouble.valueToLexical(0.1), '1.0E-1');
      expect(xsdDouble.valueToLexical(0.0000000001), '1.0E-10');
      expect(
        xsdDouble.valueToLexical(1.23e6),
        '1.23E6',
      ); //Check existing exponent handling
      expect(
        xsdDouble.valueToLexical(-456e-2),
        '-4.56E0',
      ); // Negative, with exponent
    });

    test('valueToLexical - rounding', () {
      // Test with sufficient decimal places
      expect(
        xsdDouble.valueToLexical(1.2345678901234567890123457890),
        '1.2345678901234567E0',
      );
    });

    test('isValidLexicalForm - valid forms', () {
      expect(xsdDouble.isValidLexicalForm('0.0E0'), isTrue);
      expect(xsdDouble.isValidLexicalForm('1.0E0'), isTrue);
      expect(xsdDouble.isValidLexicalForm('123.456'), isTrue);
      expect(xsdDouble.isValidLexicalForm('1.23456E2'), isTrue);
      expect(xsdDouble.isValidLexicalForm('1.0e+1'), isTrue);
      expect(xsdDouble.isValidLexicalForm('1.0e-10'), isTrue);
      expect(xsdDouble.isValidLexicalForm('INF'), isTrue);
      expect(xsdDouble.isValidLexicalForm('-INF'), isTrue);
      expect(xsdDouble.isValidLexicalForm('NaN'), isTrue);
    });

    test('isValidLexicalForm - invalid forms', () {
      expect(
        xsdDouble.isValidLexicalForm('1.0e1 foo'),
        isFalse,
      ); // Trailing chars
      expect(
        xsdDouble.isValidLexicalForm('foo 1.0e1'),
        isFalse,
      ); //Leading chars
      expect(xsdDouble.isValidLexicalForm('abc'), isFalse);
      expect(xsdDouble.isValidLexicalForm('1.2.3'), isFalse);
      expect(
        xsdDouble.isValidLexicalForm('1e'),
        isFalse,
      ); // Incomplete exponent
    });

    test('equality', () {
      expect(xsdDouble, equals(XSDDouble())); // Same instance
    });

    test('hashCode', () {
      expect(xsdDouble.hashCode, isNotNull);
      expect(
        xsdDouble.hashCode,
        equals(XSDDouble().hashCode),
      ); //Consistent hashcode
    });

    test('toString', () {
      expect(xsdDouble.toString(), 'http://www.w3.org/2001/XMLSchema#double');
    });
  });
}
