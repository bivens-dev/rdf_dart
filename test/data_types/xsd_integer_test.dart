import 'package:rdf_dart/src/data_types/xsd_integer.dart';
import 'package:test/test.dart';

void main() {
  group('XSDInteger', () {
    late XSDInteger xsdInteger;

    setUp(() {
      xsdInteger = const XSDInteger();
    });

    test('lexicalToValue - valid values', () {
      expect(xsdInteger.lexicalToValue('0'), equals(BigInt.zero));
      expect(xsdInteger.lexicalToValue('-0'), equals(BigInt.zero));
      expect(xsdInteger.lexicalToValue('123'), equals(BigInt.from(123)));
      expect(xsdInteger.lexicalToValue('-123'), equals(BigInt.from(-123)));
      expect(
        xsdInteger.lexicalToValue('+123'),
        equals(BigInt.from(123)),
      ); // Valid, though not canonical
      expect(
        xsdInteger.lexicalToValue('12678967543233'),
        equals(BigInt.parse('12678967543233')),
      );
    });

    test('lexicalToValue - invalid values', () {
      expect(() => xsdInteger.lexicalToValue('123.45'), throwsFormatException);
      expect(() => xsdInteger.lexicalToValue('abc'), throwsFormatException);
      expect(() => xsdInteger.lexicalToValue(''), throwsFormatException);
      expect(
        () => xsdInteger.lexicalToValue(' 123'),
        throwsFormatException,
      ); // Leading space
    });

    test('valueToLexical - valid values', () {
      expect(xsdInteger.valueToLexical(BigInt.zero), '0');
      expect(xsdInteger.valueToLexical(BigInt.from(-123)), '-123');
      expect(xsdInteger.valueToLexical(BigInt.from(123)), '123');
      expect(
        xsdInteger.valueToLexical(BigInt.parse('9223372036854775807')),
        '9223372036854775807',
      );
      expect(
        xsdInteger.valueToLexical(BigInt.parse('-9223372036854775808')),
        '-9223372036854775808',
      );
    });

    test('isValidLexicalForm - valid forms', () {
      expect(xsdInteger.isValidLexicalForm('0'), isTrue);
      expect(
        xsdInteger.isValidLexicalForm('-0'),
        isTrue,
      ); // Valid, though not canonical
      expect(xsdInteger.isValidLexicalForm('123'), isTrue);
      expect(xsdInteger.isValidLexicalForm('-123'), isTrue);
      expect(
        xsdInteger.isValidLexicalForm('+123'),
        isTrue,
      ); // Valid, though not canonical
    });

    test('isValidLexicalForm - invalid forms', () {
      expect(xsdInteger.isValidLexicalForm('123.45'), isFalse);
      expect(xsdInteger.isValidLexicalForm('abc'), isFalse);
      expect(xsdInteger.isValidLexicalForm(''), isFalse);
      expect(xsdInteger.isValidLexicalForm(' 123'), isFalse); // Leading space
      expect(
        xsdInteger.isValidLexicalForm('00123'),
        isTrue,
      ); //Leading zeroes is valid (but not canonical)
      expect(
        xsdInteger.isValidLexicalForm('-00123'),
        isTrue,
      ); //Leading zeros valid
    });

    test('equality', () {
      expect(xsdInteger, equals(XSDInteger())); // Same instance
    });

    test('hashCode', () {
      expect(xsdInteger.hashCode, isNotNull);
      expect(
        xsdInteger.hashCode,
        equals(XSDInteger().hashCode),
      ); //Consistent hashcode
    });

    test('toString', () {
      expect(xsdInteger.toString(), 'http://www.w3.org/2001/XMLSchema#integer');
    });

    test('from boolean', () {
      expect(xsdInteger.lexicalToValue('0'), BigInt.zero);
      expect(xsdInteger.lexicalToValue('1'), BigInt.one);
    });
  });
}
