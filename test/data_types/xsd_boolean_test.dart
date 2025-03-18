import 'package:rdf_dart/src/data_types/xsd_boolean.dart';
import 'package:test/test.dart';

void main() {
  group('XSDBoolean', () {
    late XSDBoolean xsdBoolean;

    setUp(() {
      xsdBoolean = const XSDBoolean();
    });

    test('lexicalToValue - valid values', () {
      expect(xsdBoolean.lexicalToValue('true'), isTrue);
      expect(xsdBoolean.lexicalToValue('1'), isTrue);
      expect(xsdBoolean.lexicalToValue('false'), isFalse);
      expect(xsdBoolean.lexicalToValue('0'), isFalse);
    });

    test('lexicalToValue - invalid values', () {
      expect(() => xsdBoolean.lexicalToValue('TRUE'), throwsFormatException);
      expect(() => xsdBoolean.lexicalToValue('FALSE'), throwsFormatException);
      expect(() => xsdBoolean.lexicalToValue('2'), throwsFormatException);
      expect(
        () => xsdBoolean.lexicalToValue('true '),
        throwsFormatException,
      ); // Trailing space
    });

    test('valueToLexical', () {
      expect(xsdBoolean.valueToLexical(true), 'true');
      expect(xsdBoolean.valueToLexical(false), 'false');
    });

    test('isValidLexicalForm - valid forms', () {
      expect(xsdBoolean.isValidLexicalForm('true'), isTrue);
      expect(xsdBoolean.isValidLexicalForm('1'), isTrue);
      expect(xsdBoolean.isValidLexicalForm('false'), isTrue);
      expect(xsdBoolean.isValidLexicalForm('0'), isTrue);
    });

    test('isValidLexicalForm - invalid forms', () {
      expect(xsdBoolean.isValidLexicalForm('TRUE'), isFalse);
      expect(xsdBoolean.isValidLexicalForm('FALSE'), isFalse);
      expect(xsdBoolean.isValidLexicalForm('2'), isFalse);
      expect(xsdBoolean.isValidLexicalForm(' true'), isFalse); // Leading space
    });

    test('equality', () {
      expect(xsdBoolean, equals(XSDBoolean())); // Same instance
    });

    test('hashCode', () {
      expect(xsdBoolean.hashCode, isNotNull);
      expect(
        xsdBoolean.hashCode,
        equals(XSDBoolean().hashCode),
      ); //Consistent hashcode
    });

    test('toString', () {
      expect(xsdBoolean.toString(), 'http://www.w3.org/2001/XMLSchema#boolean');
    });
  });
}
