import 'package:rdf_dart/rdf_dart.dart'; // Assuming main library export
// Import the new class
import 'package:test/test.dart';

void main() {
  // --- Helper constants/variables for tests ---
  final iriSubj = IRITerm('http://example.com/subject');
  final iriPred = IRITerm('http://example.com/predicate');
  final literalObj = Literal('object', IRI(XMLDataType.string.iri));
  final blankNodeSubj = BlankNode('b1');
  final iriObj = IRITerm('http://example.com/object');

  final innerTriple1 = Triple(iriSubj, iriPred, literalObj);
  final innerTriple2 = Triple(blankNodeSubj, iriPred, iriObj);
  final sameAsInnerTriple1 = Triple(
    IRITerm('http://example.com/subject'),
    IRITerm('http://example.com/predicate'),
    Literal('object', IRI(XMLDataType.string.iri)),
  );

  group('TripleTerm', () {
    test('Constructor creates TripleTerm', () {
      final tt = TripleTerm(innerTriple1);
      expect(tt, isA<TripleTerm>());
      expect(tt.triple, equals(innerTriple1));
    });

    test('Type checks return correct values', () {
      final tt = TripleTerm(innerTriple1);
      expect(tt.isIRI, isFalse);
      expect(tt.isBlankNode, isFalse);
      expect(tt.isLiteral, isFalse);
      expect(tt.isTripleTerm, isTrue); // Key check for this class
    });

    test('termType returns TermType.tripleTerm', () {
      final tt = TripleTerm(innerTriple1);
      expect(tt.termType, equals(TermType.tripleTerm));
    });

    test('Equality operator (==) works correctly', () {
      final tt1 = TripleTerm(innerTriple1);
      final tt2 = TripleTerm(innerTriple2);
      final tt3 = TripleTerm(sameAsInnerTriple1); // Same inner triple content

      expect(tt1 == tt1, isTrue); // Identity
      expect(tt1 == tt3, isTrue); // Equal inner triples
      expect(tt3 == tt1, isTrue); // Symmetry
      expect(tt1 == tt2, isFalse); // Different inner triples
      // ignore: unrelated_type_equality_checks
      expect(tt1 == innerTriple1, isFalse); // Different types
      expect(tt1 == iriSubj, isFalse); // Different types
    });

    test('hashCode is consistent with equality', () {
      final tt1 = TripleTerm(innerTriple1);
      final tt2 = TripleTerm(innerTriple2);
      final tt3 = TripleTerm(sameAsInnerTriple1);

      expect(tt1.hashCode, equals(tt3.hashCode)); // Equal objects, equal hashCodes
      expect(tt1.hashCode, isNot(equals(tt2.hashCode))); // Unequal objects
    });

     test('toString() returns expected format', () {
      final tt = TripleTerm(innerTriple1);
      // Example: "<http://example.com/subject> <http://example.com/predicate> "object" ."
      final expectedInnerString = innerTriple1.toString();
      expect(tt.toString(), equals('<< $expectedInnerString >>'));

      final tt2 = TripleTerm(innerTriple2);
      // Example: "_:b1 <http://example.com/predicate> <http://example.com/object> ."
      final expectedInnerString2 = innerTriple2.toString();
       expect(tt2.toString(), equals('<< $expectedInnerString2 >>'));
    });

  });
}