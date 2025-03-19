import 'package:rdf_dart/src/data_types/xsd_token.dart';
import 'package:test/test.dart';

void main() {
  group('XSDToken', () {
    late XSDToken xsdToken;

    setUp(() {
      xsdToken = const XSDToken();
    });

    test('lexicalToValue - valid values', () {
      expect(xsdToken.lexicalToValue('valid'), equals('valid'));
      expect(xsdToken.lexicalToValue('a b c'), equals('a b c'));
      expect(xsdToken.lexicalToValue('123'), equals('123'));
    });

    test('lexicalToValue - invalid values', () {
      expect(() => xsdToken.lexicalToValue('  invalid'), throwsFormatException);
      expect(() => xsdToken.lexicalToValue('invalid  '), throwsFormatException);
      expect(() => xsdToken.lexicalToValue('in  valid'), throwsFormatException);
      expect(() => xsdToken.lexicalToValue('invalid\t'), throwsFormatException);
      expect(() => xsdToken.lexicalToValue('invalid\n'), throwsFormatException);
      expect(() => xsdToken.lexicalToValue('invalid\r'), throwsFormatException);
      expect(
        () => xsdToken.lexicalToValue('\tinvalid'),
        throwsFormatException,
      ); // Leading Tab
      expect(
        () => xsdToken.lexicalToValue('\rinvalid'),
        throwsFormatException,
      ); // Leading CR
      expect(
        () => xsdToken.lexicalToValue('\ninvalid'),
        throwsFormatException,
      ); // Leading LF
      expect(
        () => xsdToken.lexicalToValue('invalid\t '),
        throwsFormatException,
      ); // Trailing Tab and space
      expect(
        () => xsdToken.lexicalToValue('invalid\r '),
        throwsFormatException,
      ); // Trailing CR and space
      expect(
        () => xsdToken.lexicalToValue('invalid\n '),
        throwsFormatException,
      ); // Trailing LF and space
      expect(
        () => xsdToken.lexicalToValue('abc\rdef'),
        throwsFormatException,
      ); // Contains carriage return
      expect(
        () => xsdToken.lexicalToValue('abc\ndef'),
        throwsFormatException,
      ); // Contains newline
      expect(
        () => xsdToken.lexicalToValue('abc\tdef'),
        throwsFormatException,
      ); // Contains tab
      expect(
        () => xsdToken.lexicalToValue('trailing space '),
        throwsFormatException,
      ); // Trailing Space
    });

    test('valueToLexical - valid values', () {
      expect(xsdToken.valueToLexical('valid'), equals('valid'));
      expect(xsdToken.valueToLexical('a b c'), equals('a b c'));
      expect(xsdToken.valueToLexical('123'), equals('123'));
    });

    test('valueToLexical - invalid values (throws ArgumentError)', () {
      expect(
        () => xsdToken.valueToLexical('  invalid'),
        throwsArgumentError,
      ); // Leading space
      expect(
        () => xsdToken.valueToLexical('invalid  '),
        throwsArgumentError,
      ); // Trailing space
      expect(
        () => xsdToken.valueToLexical('in  valid'),
        throwsArgumentError,
      ); // Double space
      expect(
        () => xsdToken.valueToLexical('invalid\t'),
        throwsArgumentError,
      ); // Tab
      expect(
        () => xsdToken.valueToLexical('invalid\n'),
        throwsArgumentError,
      ); // Newline
      expect(
        () => xsdToken.valueToLexical('invalid\r'),
        throwsArgumentError,
      ); // Carriage Return
      expect(
        () => xsdToken.valueToLexical('\rinvalid'),
        throwsArgumentError,
      ); // Leading CR
      expect(
        () => xsdToken.valueToLexical('\ninvalid'),
        throwsArgumentError,
      ); // Leading LF
      expect(
        () => xsdToken.valueToLexical('invalid\t '),
        throwsArgumentError,
      ); // Trailing Tab and space
      expect(
        () => xsdToken.valueToLexical('invalid\r '),
        throwsArgumentError,
      ); // Trailing CR and space
      expect(
        () => xsdToken.valueToLexical('invalid\n '),
        throwsArgumentError,
      ); // Trailing LF and space
    });

    test('isValidLexicalForm - valid forms', () {
      expect(xsdToken.isValidLexicalForm('valid'), isTrue);
      expect(xsdToken.isValidLexicalForm('a b c'), isTrue);
      expect(xsdToken.isValidLexicalForm('123'), isTrue);
      expect(xsdToken.isValidLexicalForm('  a'), isFalse); // Leading Space
      expect(xsdToken.isValidLexicalForm('a  '), isFalse); // Trailing Space

      expect(xsdToken.isValidLexicalForm('a  b'), isFalse); // Double Space
      expect(xsdToken.isValidLexicalForm('a\tb'), isFalse); // Contains tab
      expect(xsdToken.isValidLexicalForm('a\nb'), isFalse); // Contains newline
      expect(
        xsdToken.isValidLexicalForm('a\rb'),
        isFalse,
      ); // Contains carriage return
    });

    test('isValidLexicalForm - invalid forms', () {
      expect(xsdToken.isValidLexicalForm('  invalid'), isFalse);
      expect(xsdToken.isValidLexicalForm('invalid  '), isFalse);
      expect(xsdToken.isValidLexicalForm('in  valid'), isFalse);
      expect(xsdToken.isValidLexicalForm('invalid\t'), isFalse);
      expect(xsdToken.isValidLexicalForm('invalid\n'), isFalse);
      expect(xsdToken.isValidLexicalForm('invalid\r'), isFalse);
    });
    test('equality', () {
      expect(xsdToken, equals(XSDToken())); // Same instance
    });

    test('hashCode', () {
      expect(xsdToken.hashCode, isNotNull);
      expect(
        xsdToken.hashCode,
        equals(XSDToken().hashCode),
      ); //Consistent hashcode
    });

    test('toString', () {
      expect(xsdToken.toString(), 'http://www.w3.org/2001/XMLSchema#token');
    });
  });
}
