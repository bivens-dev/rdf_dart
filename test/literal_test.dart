// test/literal_test.dart

import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Literal', () {
    final stringDatatype = IRI('http://www.w3.org/2001/XMLSchema#string');
    final integerDatatype = IRI('http://www.w3.org/2001/XMLSchema#integer');
    final doubleDatatype = IRI('http://www.w3.org/2001/XMLSchema#double');
    final dateTimeDatatype = IRI('http://www.w3.org/2001/XMLSchema#dateTime');
    final booleanDatatype = IRI('http://www.w3.org/2001/XMLSchema#boolean');

    group('Creation', () {
      test('with string datatype', () {
        final literal = Literal('hello', stringDatatype);
        expect(literal.lexicalForm, 'hello');
        expect(literal.datatype, stringDatatype);
        expect(literal.language, isNull);
        expect(literal.value, 'hello');
      });

      test('with integer datatype', () {
        final literal = Literal('42', integerDatatype);
        expect(literal.lexicalForm, '42');
        expect(literal.datatype, integerDatatype);
        expect(literal.language, isNull);
        expect(literal.value, 42);
      });
      test('with invalid integer datatype', () {
        final literal = Literal('abc', integerDatatype);
        expect(literal.lexicalForm, 'abc');
        expect(literal.datatype, integerDatatype);
        expect(literal.language, isNull);
        expect(literal.value, isNull);
      });

      test('with language tag', () {
        final literal = Literal('bonjour', stringDatatype, 'fr');
        expect(literal.lexicalForm, 'bonjour');
        expect(literal.datatype, stringDatatype);
        expect(literal.language, 'fr');
        expect(literal.value, 'bonjour');
      });
      test('with double datatype', () {
        final literal = Literal('3.14', doubleDatatype);
        expect(literal.lexicalForm, '3.14');
        expect(literal.datatype, doubleDatatype);
        expect(literal.language, isNull);
        expect(literal.value, 3.14);
      });
      test('with invalid double datatype', () {
        final literal = Literal('abc', doubleDatatype);
        expect(literal.lexicalForm, 'abc');
        expect(literal.datatype, doubleDatatype);
        expect(literal.language, isNull);
        expect(literal.value, isNull);
      });
      test('with dateTime datatype', () {
        final now = DateTime.utc(2025, 03, 12, 23, 30, 38, 917614);
        final literal = Literal(now.toIso8601String(), dateTimeDatatype);
        expect(literal.lexicalForm, now.toIso8601String());
        expect(literal.datatype, dateTimeDatatype);
        expect(literal.language, isNull);
        expect(
          (literal.value as DateTime).toIso8601String(),
          now.toIso8601String(),
        );
      });
      test('with invalid dateTime datatype', () {
        final literal = Literal('abc', dateTimeDatatype);
        expect(literal.lexicalForm, 'abc');
        expect(literal.datatype, dateTimeDatatype);
        expect(literal.language, isNull);
        expect(literal.value, isNull);
      });
      test('with boolean datatype', () {
        final literal = Literal('true', booleanDatatype);
        expect(literal.lexicalForm, 'true');
        expect(literal.datatype, booleanDatatype);
        expect(literal.language, isNull);
        expect(literal.value, true);
      });
      test('with invalid boolean datatype', () {
        final literal = Literal('abc', booleanDatatype);
        expect(literal.lexicalForm, 'abc');
        expect(literal.datatype, booleanDatatype);
        expect(literal.language, isNull);
        expect(literal.value, isNull);
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
        expect(
          literal.toString(),
          '"42"^^<http://www.w3.org/2001/XMLSchema#integer>',
        );
      });
      test('boolean literal', () {
        final literal = Literal('true', booleanDatatype);
        expect(
          literal.toString(),
          '"true"^^<http://www.w3.org/2001/XMLSchema#boolean>',
        );
      });
      test('double literal', () {
        final literal = Literal('3.14', doubleDatatype);
        expect(
          literal.toString(),
          '"3.14"^^<http://www.w3.org/2001/XMLSchema#double>',
        );
      });
      test('date time literal', () {
        final now = DateTime.utc(2025, 03, 12, 23, 30, 38, 917614);
        final literal = Literal(now.toIso8601String(), dateTimeDatatype);
        expect(
          literal.toString(),
          '"${now.toIso8601String()}"^^<http://www.w3.org/2001/XMLSchema#dateTime>',
        );
      });
    });
    group('toLexicalForm', () {
      test('string', () {
        final literal = Literal('hello', stringDatatype);
        expect(literal.toLexicalForm(), 'hello');
      });
      test('integer', () {
        final literal = Literal('42', integerDatatype);
        expect(literal.toLexicalForm(), '42');
      });
      test('double', () {
        final literal = Literal('3.14', doubleDatatype);
        expect(literal.toLexicalForm(), '3.14');
      });
      test('date time', () {
        final now = DateTime.utc(2025, 03, 12, 23, 30, 38, 917614);
        final literal = Literal(now.toIso8601String(), dateTimeDatatype);
        expect(literal.toLexicalForm(), now.toIso8601String());
      });
      test('boolean', () {
        final literal = Literal('true', booleanDatatype);
        expect(literal.toLexicalForm(), 'true');
      });
      test('invalid integer', () {
        final literal = Literal('abc', integerDatatype);
        expect(literal.toLexicalForm(), 'abc');
      });
      test('invalid double', () {
        final literal = Literal('abc', doubleDatatype);
        expect(literal.toLexicalForm(), 'abc');
      });
      test('invalid date time', () {
        final literal = Literal('abc', dateTimeDatatype);
        expect(literal.toLexicalForm(), 'abc');
      });
      test('invalid boolean', () {
        final literal = Literal('abc', booleanDatatype);
        expect(literal.toLexicalForm(), 'abc');
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
