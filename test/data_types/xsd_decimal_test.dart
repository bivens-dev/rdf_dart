import 'package:decimal/decimal.dart';
import 'package:rdf_dart/src/data_types/xsd_decimal.dart';
import 'package:test/test.dart';

void main() {
  group('XSDDecimal', () {
    late XSDDecimal xsdDecimal;

    setUp(() {
      xsdDecimal = const XSDDecimal();
    });

    test('RDF Literal Canonicalization', () {
      expect(xsdDecimal.lexicalToValue('1'), equals(Decimal.fromInt(1)));
      expect(xsdDecimal.lexicalToValue('01'), equals(Decimal.fromInt(1)));
      expect(xsdDecimal.lexicalToValue('1.'), equals(Decimal.fromInt(1)));
      expect(xsdDecimal.lexicalToValue('1.0'), equals(Decimal.fromInt(1)));
      expect(xsdDecimal.lexicalToValue('1.00'), equals(Decimal.fromInt(1)));
      expect(xsdDecimal.lexicalToValue('+001.00'), equals(Decimal.fromInt(1)));
      expect(
        xsdDecimal.lexicalToValue('123.456'),
        equals(Decimal.parse('123.456')),
      );
      expect(
        xsdDecimal.lexicalToValue('0123.456'),
        equals(Decimal.parse('123.456')),
      );
      expect(
        xsdDecimal.lexicalToValue('1.2345678901234567890123457890'),
        equals(Decimal.parse('1.2345678901234567890123457890')),
      );
    });

    test('lexicalToValue - valid values', () {
      expect(xsdDecimal.lexicalToValue('0'), equals(Decimal.zero));
      expect(
        xsdDecimal.lexicalToValue('-0'),
        equals(Decimal.zero),
      ); // -0 is valid
      expect(xsdDecimal.lexicalToValue('123'), equals(Decimal.fromInt(123)));
      expect(xsdDecimal.lexicalToValue('-123'), equals(Decimal.fromInt(-123)));
      expect(
        xsdDecimal.lexicalToValue('12678967.543233'),
        equals(Decimal.parse('12678967.543233')),
      ); //with a decimal, from spec
      expect(
        xsdDecimal.lexicalToValue('12678967543233'),
        equals(Decimal.parse('12678967543233')),
      ); // large integer
      expect(
        xsdDecimal.lexicalToValue('0.122'),
        equals(Decimal.parse('0.122')),
      ); // trailing zeros
      expect(
        xsdDecimal.lexicalToValue('.122'),
        equals(Decimal.parse('0.122')),
      ); // leading decimal
      expect(xsdDecimal.lexicalToValue('1.0'), equals(Decimal.fromInt(1)));
    });

    test('lexicalToValue - invalid values', () {
      expect(() => xsdDecimal.lexicalToValue('foo'), throwsFormatException);
      expect(() => xsdDecimal.lexicalToValue('12.xyz'), throwsFormatException);
      expect(
        () => xsdDecimal.lexicalToValue('1 2'),
        throwsFormatException,
      ); // internal space
      expect(
        () => xsdDecimal.lexicalToValue('00.123.456'),
        throwsFormatException,
      ); // Multiple decimal places
      expect(
        () => xsdDecimal.lexicalToValue('.'),
        throwsFormatException,
      ); // No numbers only a decimal place
      expect(() => xsdDecimal.lexicalToValue('0+'), throwsFormatException);
    });

    test('valueToLexical - valid values', () {
      expect(xsdDecimal.valueToLexical(Decimal.zero), '0');
      expect(xsdDecimal.valueToLexical(Decimal.fromInt(-123)), '-123');
      expect(xsdDecimal.valueToLexical(Decimal.fromInt(123)), '123');
      expect(
        xsdDecimal.valueToLexical(Decimal.parse('12678967.543233')),
        '12678967.543233',
      );

      expect(
        xsdDecimal.valueToLexical(Decimal.parse('0.122000')),
        '0.122',
      ); // Trailing zeros removed
      expect(
        xsdDecimal.valueToLexical(Decimal.parse('0012.34')),
        '12.34', //Leading zeroes now removed
      ); // Leading zeros removed
      expect(xsdDecimal.valueToLexical(Decimal.parse('1.0')), '1');
      expect(xsdDecimal.valueToLexical(Decimal.parse('0.000')), '0');

      expect(
        xsdDecimal.valueToLexical(Decimal.parse('-0')),
        '0',
      ); // Output as 0
    });

    test('isValidLexicalForm - valid forms', () {
      expect(xsdDecimal.isValidLexicalForm('0'), isTrue);
      expect(xsdDecimal.isValidLexicalForm('-0'), isTrue);
      expect(xsdDecimal.isValidLexicalForm('123'), isTrue);
      expect(xsdDecimal.isValidLexicalForm('-123'), isTrue);
      expect(xsdDecimal.isValidLexicalForm('+123'), isTrue);
      expect(xsdDecimal.isValidLexicalForm('123.456'), isTrue);
      expect(xsdDecimal.isValidLexicalForm('0.123'), isTrue);
      expect(xsdDecimal.isValidLexicalForm('.123'), isTrue);
      expect(
        xsdDecimal.isValidLexicalForm('1.'),
        isTrue,
      ); // Trailing . now valid
      expect(xsdDecimal.isValidLexicalForm('+00123.456'), isTrue);
      expect(xsdDecimal.isValidLexicalForm('01.0'), isTrue);
    });

    test('isValidLexicalForm - invalid forms', () {
      expect(xsdDecimal.isValidLexicalForm('foo'), isFalse);
      expect(xsdDecimal.isValidLexicalForm('12.xyz'), isFalse);
      expect(xsdDecimal.isValidLexicalForm('123 '), isFalse); // Trailing space
      expect(xsdDecimal.isValidLexicalForm(' 123'), isFalse); // Leading space
      expect(xsdDecimal.isValidLexicalForm('1 0'), isFalse); // internal space
    });

    test('equality', () {
      expect(xsdDecimal, equals(XSDDecimal())); // Same instance
    });

    test('hashCode', () {
      expect(xsdDecimal.hashCode, isNotNull);
      expect(
        xsdDecimal.hashCode,
        equals(XSDDecimal().hashCode),
      ); //Consistent hashcode
    });

    test('toString', () {
      expect(xsdDecimal.toString(), 'http://www.w3.org/2001/XMLSchema#decimal');
    });
  });
}
