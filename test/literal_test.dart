import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Literal', () {
    final stringDatatype = IRI('http://www.w3.org/2001/XMLSchema#string');
    final integerDatatype = IRI('http://www.w3.org/2001/XMLSchema#integer');
    final booleanDatatype = IRI('http://www.w3.org/2001/XMLSchema#boolean');

    group('Creation', () {
      test('with string datatype', () {
        final literal = Literal('hello', stringDatatype);
        expect(literal.lexicalForm, 'hello');
        expect(literal.datatype, stringDatatype);
        expect(literal.language, isNull);
      });

      test('with integer datatype', () {
        final literal = Literal('42', integerDatatype);
        expect(literal.lexicalForm, '42');
        expect(literal.datatype, integerDatatype);
        expect(literal.language, isNull);
      });

      test('with language tag', () {
        final literal = Literal('bonjour', stringDatatype, 'fr');
        expect(literal.lexicalForm, 'bonjour');
        expect(literal.datatype, stringDatatype);
        expect(literal.language, 'fr');
      });
        test('with boolean datatype', () {
        final literal = Literal('true', booleanDatatype);
        expect(literal.lexicalForm, 'true');
        expect(literal.datatype, booleanDatatype);
        expect(literal.language, isNull);
      });
    });

    group('Type checking', () {
      test('isIRI is false', () {
        final literal = Literal('hello', stringDatatype);
        expect(literal.isIRI, false);
      });

      test('isBlankNode is false', () {
        final literal = Literal('hello', stringDatatype);
        expect(literal.isBlankNode, false);
      });

      test('isLiteral is true', () {
        final literal = Literal('hello', stringDatatype);
        expect(literal.isLiteral, true);
      });
    });

    group('TermType', () {
      test('termType is literal', () {
        final literal = Literal('hello', stringDatatype);
        expect(literal.termType, TermType.literal);
      });
    });

    group('toString', () {
      test('string literal without language tag', () {
        final literal = Literal('hello', stringDatatype);
        expect(literal.toString(), '"hello"');
      });

      test('string literal with language tag', () {
        final literal = Literal('bonjour', stringDatatype, 'fr');
        expect(literal.toString(), '"bonjour"@fr');
      });

      test('integer literal', () {
        final literal = Literal('42', integerDatatype);
        expect(literal.toString(), '"42"^^<http://www.w3.org/2001/XMLSchema#integer>');
      });
      test('boolean literal', () {
        final literal = Literal('true', booleanDatatype);
        expect(literal.toString(), '"true"^^<http://www.w3.org/2001/XMLSchema#boolean>');
      });
    });

    group('Equality', () {
      test('equal literals', () {
        final literal1 = Literal('hello', stringDatatype);
        final literal2 = Literal('hello', stringDatatype);
        expect(literal1 == literal2, true);
      });

      test('different lexical forms', () {
        final literal1 = Literal('hello', stringDatatype);
        final literal2 = Literal('world', stringDatatype);
        expect(literal1 == literal2, false);
      });

      test('different datatypes', () {
        final literal1 = Literal('42', integerDatatype);
        final literal2 = Literal('42', stringDatatype);
        expect(literal1 == literal2, false);
      });

      test('different language tags', () {
        final literal1 = Literal('bonjour', stringDatatype, 'fr');
        final literal2 = Literal('bonjour', stringDatatype, 'en');
        expect(literal1 == literal2, false);
      });

      test('one with language tag, one without', () {
        final literal1 = Literal('hello', stringDatatype);
        final literal2 = Literal('hello', stringDatatype, 'fr');
        expect(literal1 == literal2, false);
      });
    });

    group('HashCode', () {
      test('equal literals have same hashCode', () {
        final literal1 = Literal('hello', stringDatatype);
        final literal2 = Literal('hello', stringDatatype);
        expect(literal1.hashCode == literal2.hashCode, true);
      });

      test('different lexical forms have different hashCodes', () {
        final literal1 = Literal('hello', stringDatatype);
        final literal2 = Literal('world', stringDatatype);
        expect(literal1.hashCode == literal2.hashCode, false);
      });

      test('different datatypes have different hashCodes', () {
        final literal1 = Literal('42', integerDatatype);
        final literal2 = Literal('42', stringDatatype);
        expect(literal1.hashCode == literal2.hashCode, false);
      });

      test('different language tags have different hashCodes', () {
        final literal1 = Literal('bonjour', stringDatatype, 'fr');
        final literal2 = Literal('bonjour', stringDatatype, 'en');
        expect(literal1.hashCode == literal2.hashCode, false);
      });

      test('one with language tag, one without have different hashCodes', () {
        final literal1 = Literal('hello', stringDatatype);
        final literal2 = Literal('hello', stringDatatype, 'fr');
        expect(literal1.hashCode == literal2.hashCode, false);
      });
    });
  });
}
