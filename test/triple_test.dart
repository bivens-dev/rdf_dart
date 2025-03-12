import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Triple', () {
    group('Creation', () {
      test('with valid subject, predicate, and object', () {
        final subject = IRI('http://example.com/subject');
        final predicate = IRI('http://example.com/predicate');
        final object = IRI('http://example.com/object');
        expect(() => Triple(subject, predicate, object), returnsNormally);
      });

      test('with BlankNode as subject', () {
        final subject = BlankNode();
        final predicate = IRI('http://example.com/predicate');
        final object = IRI('http://example.com/object');
        expect(() => Triple(subject, predicate, object), returnsNormally);
      });

      test('with Literal as object', () {
        final subject = IRI('http://example.com/subject');
        final predicate = IRI('http://example.com/predicate');
        final object = Literal('value', IRI('http://www.w3.org/2001/XMLSchema#string'));
        expect(() => Triple(subject, predicate, object), returnsNormally);
      });

      test('with BlankNode as object', () {
        final subject = IRI('http://example.com/subject');
        final predicate = IRI('http://example.com/predicate');
        final object = BlankNode();
        expect(() => Triple(subject, predicate, object), returnsNormally);
      });

      test('with IRI as subject', () {
        final subject = IRI('http://example.com/subject');
        final predicate = IRI('http://example.com/predicate');
        final object = IRI('http://example.com/object');
        expect(() => Triple(subject, predicate, object), returnsNormally);
      });
    });

    group('toString', () {
      test('returns correct string representation', () {
        final subject = IRI('http://example.com/subject');
        final predicate = IRI('http://example.com/predicate');
        final object = IRI('http://example.com/object');
        final triple = Triple(subject, predicate, object);
        expect(triple.toString(), 'http://example.com/subject http://example.com/predicate http://example.com/object .');
      });

       test('returns correct string representation with blank node', () {
        final subject = BlankNode('someId');
        final predicate = IRI('http://example.com/predicate');
        final object = IRI('http://example.com/object');
        final triple = Triple(subject, predicate, object);
        expect(triple.toString(), '_:someId http://example.com/predicate http://example.com/object .');
      });
      test('returns correct string representation with literal', () {
        final subject = IRI('http://example.com/subject');
        final predicate = IRI('http://example.com/predicate');
        final object = Literal('Hello', IRI('http://www.w3.org/2001/XMLSchema#string'));
        final triple = Triple(subject, predicate, object);
        expect(triple.toString(), 'http://example.com/subject http://example.com/predicate "Hello" .');
      });
    });

    group('Equality', () {
      test('equal triples', () {
        final subject = IRI('http://example.com/subject');
        final predicate = IRI('http://example.com/predicate');
        final object = IRI('http://example.com/object');
        final triple1 = Triple(subject, predicate, object);
        final triple2 = Triple(subject, predicate, object);
        expect(triple1 == triple2, true);
      });

      test('different subjects', () {
        final subject1 = IRI('http://example.com/subject1');
        final subject2 = IRI('http://example.com/subject2');
        final predicate = IRI('http://example.com/predicate');
        final object = IRI('http://example.com/object');
        final triple1 = Triple(subject1, predicate, object);
        final triple2 = Triple(subject2, predicate, object);
        expect(triple1 == triple2, false);
      });

      test('different predicates', () {
        final subject = IRI('http://example.com/subject');
        final predicate1 = IRI('http://example.com/predicate1');
        final predicate2 = IRI('http://example.com/predicate2');
        final object = IRI('http://example.com/object');
        final triple1 = Triple(subject, predicate1, object);
        final triple2 = Triple(subject, predicate2, object);
        expect(triple1 == triple2, false);
      });

      test('different objects', () {
        final subject = IRI('http://example.com/subject');
        final predicate = IRI('http://example.com/predicate');
        final object1 = IRI('http://example.com/object1');
        final object2 = IRI('http://example.com/object2');
        final triple1 = Triple(subject, predicate, object1);
        final triple2 = Triple(subject, predicate, object2);
        expect(triple1 == triple2, false);
      });
    });

    group('HashCode', () {
      test('equal triples have same hashCode', () {
        final subject = IRI('http://example.com/subject');
        final predicate = IRI('http://example.com/predicate');
        final object = IRI('http://example.com/object');
        final triple1 = Triple(subject, predicate, object);
        final triple2 = Triple(subject, predicate, object);
        expect(triple1.hashCode == triple2.hashCode, true);
      });

      test('different subjects have different hashCodes', () {
        final subject1 = IRI('http://example.com/subject1');
        final subject2 = IRI('http://example.com/subject2');
        final predicate = IRI('http://example.com/predicate');
        final object = IRI('http://example.com/object');
        final triple1 = Triple(subject1, predicate, object);
        final triple2 = Triple(subject2, predicate, object);
        expect(triple1.hashCode == triple2.hashCode, false);
      });

      test('different predicates have different hashCodes', () {
        final subject = IRI('http://example.com/subject');
        final predicate1 = IRI('http://example.com/predicate1');
        final predicate2 = IRI('http://example.com/predicate2');
        final object = IRI('http://example.com/object');
        final triple1 = Triple(subject, predicate1, object);
        final triple2 = Triple(subject, predicate2, object);
        expect(triple1.hashCode == triple2.hashCode, false);
      });

      test('different objects have different hashCodes', () {
        final subject = IRI('http://example.com/subject');
        final predicate = IRI('http://example.com/predicate');
        final object1 = IRI('http://example.com/object1');
        final object2 = IRI('http://example.com/object2');
        final triple1 = Triple(subject, predicate, object1);
        final triple2 = Triple(subject, predicate, object2);
        expect(triple1.hashCode == triple2.hashCode, false);
      });
    });
  });
}
