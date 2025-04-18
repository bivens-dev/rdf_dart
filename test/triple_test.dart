import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Triple', () {
    final innerTripleForNesting = Triple(
      IRITerm(IRI('http://example.com/nestedSubj')),
      IRITerm(IRI('http://example.com/nestedPred')),
      Literal('nestedObj', XSD.string),
    );
    final innerTripleForNesting2 = Triple(
      IRITerm(IRI('http://example.com/nestedSubj2')),
      IRITerm(IRI('http://example.com/nestedPred2')),
      Literal('nestedObj2', XSD.string),
    );
    final tripleTermObject = TripleTerm(innerTripleForNesting);
    final tripleTermObject2 = TripleTerm(innerTripleForNesting2);

    group('Creation', () {
      test('with valid subject, predicate, and object', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = IRITerm(IRI('http://example.com/object'));
        expect(() => Triple(subject, predicate, object), returnsNormally);
      });

      test('with BlankNode as subject', () {
        final subject = BlankNode();
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = IRITerm(IRI('http://example.com/object'));
        expect(() => Triple(subject, predicate, object), returnsNormally);
      });

      test('with Literal as object', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = Literal('value', XSD.string);
        expect(() => Triple(subject, predicate, object), returnsNormally);
      });

      test('with BlankNode as object', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = BlankNode();
        expect(() => Triple(subject, predicate, object), returnsNormally);
      });

      test('with IRI as subject', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = IRITerm(IRI('http://example.com/object'));
        expect(() => Triple(subject, predicate, object), returnsNormally);
      });

      test('with TripleTerm as object (RDF 1.2)', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        // tripleTermObject defined above
        expect(
          () => Triple(subject, predicate, tripleTermObject),
          returnsNormally,
        );
      });
    });

    group('toString', () {
      test('returns correct string representation', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = IRITerm(IRI('http://example.com/object'));
        final triple = Triple(subject, predicate, object);
        expect(
          triple.toString(),
          'http://example.com/subject http://example.com/predicate http://example.com/object .',
        );
      });

      test('returns correct string representation with blank node', () {
        final subject = BlankNode('someId');
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = IRITerm(IRI('http://example.com/object'));
        final triple = Triple(subject, predicate, object);
        expect(
          triple.toString(),
          '_:someId http://example.com/predicate http://example.com/object .',
        );
      });
      test('returns correct string representation with literal', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = Literal('Hello', XSD.string);
        final triple = Triple(subject, predicate, object);
        expect(
          triple.toString(),
          'http://example.com/subject http://example.com/predicate "Hello" .',
        );
      });

      test('returns correct string representation with TripleTerm object', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        // tripleTermObject defined above
        final triple = Triple(subject, predicate, tripleTermObject);
        final expectedInnerString =
            innerTripleForNesting
                .toString(); // Get the inner triple's string rep
        expect(
          triple.toString(),
          'http://example.com/subject http://example.com/predicate << $expectedInnerString >> .',
        );
      });
    });

    group('Equality', () {
      test('equal triples', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = IRITerm(IRI('http://example.com/object'));
        final triple1 = Triple(subject, predicate, object);
        final triple2 = Triple(subject, predicate, object);
        expect(triple1 == triple2, true);
      });

      test('different subjects', () {
        final subject1 = IRITerm(IRI('http://example.com/subject'));
        final subject2 = IRITerm(IRI('http://example.com/subject2'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = IRITerm(IRI('http://example.com/object'));
        final triple1 = Triple(subject1, predicate, object);
        final triple2 = Triple(subject2, predicate, object);
        expect(triple1 == triple2, false);
      });

      test('different predicates', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate1 = IRITerm(IRI('http://example.com/predicate1'));
        final predicate2 = IRITerm(IRI('http://example.com/predicate2'));
        final object = IRITerm(IRI('http://example.com/object'));
        final triple1 = Triple(subject, predicate1, object);
        final triple2 = Triple(subject, predicate2, object);
        expect(triple1 == triple2, false);
      });

      test('different objects', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object1 = IRITerm(IRI('http://example.com/object1'));
        final object2 = IRITerm(IRI('http://example.com/object2'));
        final triple1 = Triple(subject, predicate, object1);
        final triple2 = Triple(subject, predicate, object2);
        expect(triple1 == triple2, false);
      });

      test('equal triples with TripleTerm object', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        // tripleTermObject defined above

        // Create another TripleTerm wrapping an identical inner triple
        final sameInnerTriple = Triple(
          IRITerm(IRI('http://example.com/nestedSubj')),
          IRITerm(IRI('http://example.com/nestedPred')),
          Literal('nestedObj', XSD.string),
        );
        final sameTripleTermObject = TripleTerm(sameInnerTriple);

        final triple1 = Triple(subject, predicate, tripleTermObject);
        final triple2 = Triple(subject, predicate, sameTripleTermObject);
        expect(triple1 == triple2, true);
        expect(triple2 == triple1, true); // Symmetry
      });

      test('different TripleTerm objects', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        // tripleTermObject and tripleTermObject2 defined above
        final triple1 = Triple(subject, predicate, tripleTermObject);
        final triple2 = Triple(subject, predicate, tripleTermObject2);
        expect(triple1 == triple2, false);
      });

      test('different object types (TripleTerm vs IRITerm)', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final iriObject = IRITerm(IRI('http://example.com/object'));
        // tripleTermObject defined above
        final triple1 = Triple(subject, predicate, tripleTermObject);
        final triple2 = Triple(subject, predicate, iriObject);
        expect(triple1 == triple2, false);
      });
    });

    group('HashCode', () {
      test('equal triples have same hashCode', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = IRITerm(IRI('http://example.com/object'));
        final triple1 = Triple(subject, predicate, object);
        final triple2 = Triple(subject, predicate, object);
        expect(triple1.hashCode == triple2.hashCode, true);
      });

      test('different subjects have different hashCodes', () {
        final subject1 = IRITerm(IRI('http://example.com/subject1'));
        final subject2 = IRITerm(IRI('http://example.com/subject2'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object = IRITerm(IRI('http://example.com/object'));
        final triple1 = Triple(subject1, predicate, object);
        final triple2 = Triple(subject2, predicate, object);
        expect(triple1.hashCode == triple2.hashCode, false);
      });

      test('different predicates have different hashCodes', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate1 = IRITerm(IRI('http://example.com/predicate1'));
        final predicate2 = IRITerm(IRI('http://example.com/predicate2'));
        final object = IRITerm(IRI('http://example.com/object'));
        final triple1 = Triple(subject, predicate1, object);
        final triple2 = Triple(subject, predicate2, object);
        expect(triple1.hashCode == triple2.hashCode, false);
      });

      test('different objects have different hashCodes', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        final object1 = IRITerm(IRI('http://example.com/object1'));
        final object2 = IRITerm(IRI('http://example.com/object2'));
        final triple1 = Triple(subject, predicate, object1);
        final triple2 = Triple(subject, predicate, object2);
        expect(triple1.hashCode == triple2.hashCode, false);
      });

      test('equal triples with TripleTerm object have same hashCode', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        // tripleTermObject defined above

        final sameInnerTriple = Triple(
          IRITerm(IRI('http://example.com/nestedSubj')),
          IRITerm(IRI('http://example.com/nestedPred')),
          Literal('nestedObj', XSD.string),
        );
        final sameTripleTermObject = TripleTerm(sameInnerTriple);

        final triple1 = Triple(subject, predicate, tripleTermObject);
        final triple2 = Triple(subject, predicate, sameTripleTermObject);
        expect(triple1.hashCode == triple2.hashCode, true);
      });

      test('different TripleTerm objects have different hashCodes', () {
        final subject = IRITerm(IRI('http://example.com/subject'));
        final predicate = IRITerm(IRI('http://example.com/predicate'));
        // tripleTermObject and tripleTermObject2 defined above
        final triple1 = Triple(subject, predicate, tripleTermObject);
        final triple2 = Triple(subject, predicate, tripleTermObject2);
        expect(triple1.hashCode == triple2.hashCode, false);
      });

      test(
        'different object types (TripleTerm vs Literal) have different hashCodes',
        () {
          final subject = IRITerm(IRI('http://example.com/subject'));
          final predicate = IRITerm(IRI('http://example.com/predicate'));
          final literalObject = Literal('value', XSD.string);
          // tripleTermObject defined above
          final triple1 = Triple(subject, predicate, tripleTermObject);
          final triple2 = Triple(subject, predicate, literalObject);
          expect(triple1.hashCode == triple2.hashCode, false);
        },
      );
    });
  });
}
