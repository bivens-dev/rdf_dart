import 'package:intl/locale.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/codec/ntriples/parse_error.dart';
import 'package:test/test.dart';

void main() {
  group('N-Triples 1.2 Syntax Tests', () {
    group('Decoding', () {
      group('with valid syntax', () {
        // ntriples-star-syntax-01.nt
        test('object triple term', () {
          final ntriple =
              '<http://example/a> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/s> <http://example/p> <http://example/o> )>> .';
          final decoded = nTriplesCodec.decode(ntriple);
          expect(decoded.length, 1);
          expect(
            (decoded.first.subject as IRITerm).value,
            equals(IRI('http://example/a')),
          );
          expect(decoded.first.predicate.value, equals(RDF.reifies));
          expect(decoded.first.object, isA<TripleTerm>());
          expect(
            (decoded.first.object as TripleTerm).triple.subject,
            equals(IRITerm(IRI('http://example/s'))),
          );
          expect(
            (decoded.first.object as TripleTerm).triple.predicate,
            equals(IRITerm(IRI('http://example/p'))),
          );
          expect(
            (decoded.first.object as TripleTerm).triple.object,
            equals(IRITerm(IRI('http://example/o'))),
          );
        });

        // ntriples-star-02
        test('object triple term, no whitespace', () {
          final ntriple =
              '<http://example/s><http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies><<(<http://example/s2><http://example/p2><http://example/o2>)>>.';
          final decoded = nTriplesCodec.decode(ntriple);
          expect(decoded.length, 1);
          expect(
            (decoded.first.subject as IRITerm).value,
            equals(IRI('http://example/s')),
          );
          expect(decoded.first.predicate.value, equals(RDF.reifies));
          expect(decoded.first.object, isA<TripleTerm>());
          expect(
            (decoded.first.object as TripleTerm).triple.subject,
            equals(IRITerm(IRI('http://example/s2'))),
          );
          expect(
            (decoded.first.object as TripleTerm).triple.predicate,
            equals(IRITerm(IRI('http://example/p2'))),
          );
          expect(
            (decoded.first.object as TripleTerm).triple.object,
            equals(IRITerm(IRI('http://example/o2'))),
          );
        });

        // ntriples-star-03
        test('Nested, no whitespace', () {
          final ntriple =
              '<http://example/s><http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies><<(<http://example/s2><http://example/q2><<(<http://example/s3><http://example/p3><http://example/o3>)>>)>>.';
          final decoded = nTriplesCodec.decode(ntriple);
          expect(decoded.length, 1);
          expect(
            (decoded.first.subject as IRITerm).value,
            equals(IRI('http://example/s')),
          );
          expect(decoded.first.predicate.value, equals(RDF.reifies));
          expect(decoded.first.object, isA<TripleTerm>());
          expect(
            (decoded.first.object as TripleTerm).triple.subject,
            equals(IRITerm(IRI('http://example/s2'))),
          );
          expect(
            (decoded.first.object as TripleTerm).triple.predicate,
            equals(IRITerm(IRI('http://example/q2'))),
          );
          expect(
            (decoded.first.object as TripleTerm).triple.object,
            isA<TripleTerm>(),
          );
          expect(
            ((decoded.first.object as TripleTerm).triple.object as TripleTerm)
                .triple
                .subject,
            equals(IRITerm(IRI('http://example/s3'))),
          );
          expect(
            ((decoded.first.object as TripleTerm).triple.object
                    as TripleTerm)
                .triple
                .predicate,
            equals(IRITerm(IRI('http://example/p3'))),
          );
          expect(
            ((decoded.first.object as TripleTerm).triple.object as TripleTerm)
                .triple
                .object,
            equals(IRITerm(IRI('http://example/o3'))),
          );
        });

        test('Blank node subject', () {
          final ntriples = '''
_:b0 <http://example/p> <http://example/o> .
_:b1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( _:b0 <http://example/p> <http://example/o> )>> .
''';
          final decoded = nTriplesCodec.decode(ntriples);
          expect(decoded.length, 2);

          expect(decoded.first.subject, isA<BlankNode>());
          expect(decoded.first.subject.isBlankNode, isTrue);
          expect((decoded.first.subject as BlankNode).id, equals('b0'));
          expect(
            decoded.first.predicate.value,
            equals(IRI('http://example/p')),
          );
          expect(
            (decoded.first.object as IRITerm).value,
            equals(IRI('http://example/o')),
          );

          expect(decoded.last.subject, isA<BlankNode>());
          expect(decoded.last.subject.isBlankNode, isTrue);
          expect(decoded.last.predicate.value, equals(RDF.reifies));
          expect(decoded.last.object, isA<TripleTerm>());
          expect(
            (decoded.last.object as TripleTerm).triple.subject,
            isA<BlankNode>(),
          );
          expect(
            decoded.first.subject,
            equals((decoded.last.object as TripleTerm).triple.subject),
          );
          expect(
            (decoded.last.object as TripleTerm).triple.predicate.value,
            equals(IRI('http://example/p')),
          );
          expect(
            ((decoded.last.object as TripleTerm).triple.object as IRITerm)
                .value,
            equals(IRI('http://example/o')),
          );
        });

        // ntriples-star-nested-1
        test('Nested object term', () {
          final ntriples = '''
<http://example/s> <http://example/p> <http://example/o> .
<http://example/a> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/s1> <http://example/p1> <http://example/o1> )>> .
<http://example/r> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/23> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/s3> <http://example/p3> <http://example/o3> )>> )>> .
''';

          final decoded = nTriplesCodec.decode(ntriples);
          final firstTriple = decoded[0];
          final secondTriple = decoded[1];
          final thirdTriple = decoded[2];

          expect(decoded.length, 3);

          expect(firstTriple.subject, isA<IRITerm>());
          expect(firstTriple.subject.isIRI, isTrue);
          expect(
            (firstTriple.subject as IRITerm).value,
            equals(IRI('http://example/s')),
          );
          expect(firstTriple.predicate, isA<IRITerm>());
          expect(firstTriple.predicate.isIRI, isTrue);
          expect(firstTriple.predicate.value, equals(IRI('http://example/p')));
          expect(firstTriple.object, isA<IRITerm>());
          expect(firstTriple.object.isIRI, isTrue);
          expect(
            (firstTriple.object as IRITerm).value,
            equals(IRI('http://example/o')),
          );

          expect(secondTriple.subject, isA<IRITerm>());
          expect(secondTriple.subject.isIRI, isTrue);
          expect(
            (secondTriple.subject as IRITerm).value,
            equals(IRI('http://example/a')),
          );
          expect(secondTriple.predicate, isA<IRITerm>());
          expect(secondTriple.predicate.isIRI, isTrue);
          expect(secondTriple.predicate.value, equals(RDF.reifies));
          expect(secondTriple.object, isA<TripleTerm>());
          expect(secondTriple.object.isTripleTerm, isTrue);
          expect(
            (secondTriple.object as TripleTerm).triple.subject,
            isA<IRITerm>(),
          );
          expect(
            (secondTriple.object as TripleTerm).triple.subject.isIRI,
            isTrue,
          );
          expect(
            ((secondTriple.object as TripleTerm).triple.subject as IRITerm)
                .value,
            equals(IRI('http://example/s1')),
          );
          expect(
            (secondTriple.object as TripleTerm).triple.predicate,
            isA<IRITerm>(),
          );
          expect(
            (secondTriple.object as TripleTerm).triple.predicate.isIRI,
            isTrue,
          );
          expect(
            (secondTriple.object as TripleTerm).triple.predicate.value,
            equals(IRI('http://example/p1')),
          );
          expect(
            (secondTriple.object as TripleTerm).triple.object,
            isA<IRITerm>(),
          );
          expect(
            (secondTriple.object as TripleTerm).triple.object.isIRI,
            isTrue,
          );
          expect(
            ((secondTriple.object as TripleTerm).triple.object as IRITerm)
                .value,
            equals(IRI('http://example/o1')),
          );

          expect(thirdTriple.subject, isA<IRITerm>());
          expect(thirdTriple.subject.isIRI, isTrue);
          expect(
            (thirdTriple.subject as IRITerm).value,
            equals(IRI('http://example/r')),
          );
          expect(thirdTriple.predicate, isA<IRITerm>());
          expect(thirdTriple.predicate.isIRI, isTrue);
          expect(thirdTriple.predicate.value, equals(RDF.reifies));
          expect(thirdTriple.object, isA<TripleTerm>());
          expect(thirdTriple.object.isTripleTerm, isTrue);
          expect(
            ((thirdTriple.object as TripleTerm).triple.subject as IRITerm)
                .value,
            equals(IRI('http://example/23')),
          );
          expect(
            (thirdTriple.object as TripleTerm).triple.predicate,
            isA<IRITerm>(),
          );
          expect(
            (thirdTriple.object as TripleTerm).triple.predicate.isIRI,
            isTrue,
          );
          expect(
            (thirdTriple.object as TripleTerm).triple.predicate.value,
            equals(RDF.reifies),
          );
          expect(
            (thirdTriple.object as TripleTerm).triple.object,
            isA<TripleTerm>(),
          );
          expect(
            (thirdTriple.object as TripleTerm).triple.object.isTripleTerm,
            isTrue,
          );
          expect(
            ((thirdTriple.object as TripleTerm).triple.object as TripleTerm)
                .triple
                .subject,
            isA<IRITerm>(),
          );
          expect(
            ((thirdTriple.object as TripleTerm).triple.object as TripleTerm)
                .triple
                .subject
                .isIRI,
            isTrue,
          );
          expect(
            (((thirdTriple.object as TripleTerm).triple.object as TripleTerm)
                        .triple
                        .subject
                    as IRITerm)
                .value,
            equals(IRI('http://example/s3')),
          );
          expect(
            ((thirdTriple.object as TripleTerm).triple.object as TripleTerm)
                .triple
                .predicate
                .value,
            equals(IRI('http://example/p3')),
          );
          expect(
            (((thirdTriple.object as TripleTerm).triple.object as TripleTerm)
                        .triple
                        .object
                    as IRITerm)
                .value,
            equals(IRI('http://example/o3')),
          );
        });

        test('literal with base direction ltr', () {
          final ntriple =
              '<http://example/a> <http://example/b> "Hello"@en--ltr .';
          final decoded = nTriplesCodec.decode(ntriple);
          expect(decoded.length, 1);
          expect(
            (decoded.first.subject as IRITerm).value,
            equals(IRI('http://example/a')),
          );
          expect(
            decoded.first.predicate.value,
            equals(IRI('http://example/b')),
          );
          expect(decoded.first.object, isA<Literal>());
          expect(decoded.first.object.isLiteral, isTrue);
          expect(
            (decoded.first.object as Literal).baseDirection,
            equals(TextDirection.ltr),
          );
          expect(
            (decoded.first.object as Literal).language,
            equals(Locale.parse('en')),
          );
          expect((decoded.first.object as Literal).value, equals('Hello'));
          // Unsure if this should actually pass or not?
          // expect(
          //   (decoded.first.object as Literal).datatype,
          //   equals(RDF.langString),
          // );
        });

        test('literal with base direction rtl', () {
          final ntriple =
              '<http://example/a> <http://example/b> "Hello"@en--rtl .';
          final decoded = nTriplesCodec.decode(ntriple);
          expect(decoded.length, 1);
          expect(
            (decoded.first.subject as IRITerm).value,
            equals(IRI('http://example/a')),
          );
          expect(
            decoded.first.predicate.value,
            equals(IRI('http://example/b')),
          );
          expect(decoded.first.object, isA<Literal>());
          expect(decoded.first.object.isLiteral, isTrue);
          expect(
            (decoded.first.object as Literal).baseDirection,
            equals(TextDirection.rtl),
          );
          expect(
            (decoded.first.object as Literal).language,
            equals(Locale.parse('en')),
          );
          expect((decoded.first.object as Literal).value, equals('Hello'));
          // Unsure if this should actually pass or not?
          // expect(
          //   (decoded.first.object as Literal).datatype,
          //   equals(RDF.langString),
          // );
        });
      });

      group('with invalid syntax', () {
        // ntriples-star-bad-01
        test('reified triple as predicate', () {
          final ntriple =
              '<http://example/a> <<( <http://example/s> <http://example/p> <http://example/o> )>>  <http://example/z> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-02
        test('reified triple, literal subject', () {
          final ntriple =
              '<http://example/q> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( "XYZ" <http://example/p> <http://example/o> )>> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-03
        test('reified triple, literal predicate', () {
          final ntriple =
              '<http://example/q> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/s> "XYZ" <http://example/o> )>> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-04
        test('reified triple, blank node predicate', () {
          final ntriple =
              '<http://example/q> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> << <http://example/s> _:label <http://example/o> >> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-05
        test('triple term as predicate', () {
          final ntriple =
              '<http://example/a> <<( <http://example/s> <http://example/p>  <http://example/o> )>> <http://example/z> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-06
        test('triple term, literal subject', () {
          final ntriple =
              '<<( "XYZ" <http://example/p> <http://example/o> )>> <http://example/q> <http://example/z> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-07
        test('triple term, literal predicate', () {
          final ntriple =
              '<<( <http://example/s> "XYZ" <http://example/o> )>> <http://example/q> <http://example/z> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-08
        test('triple term, blank node predicate', () {
          final ntriple =
              '<<( <http://example/s> _:label <http://example/o> )>> <http://example/q> <http://example/z> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-09
        test('reified triple object', () {
          final ntriple =
              '<http://example/a> <http://example/b> << <http://example/s> <http://example/p> <http://example/o> >> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-10
        test('triple term as subject', () {
          final ntriple =
              '<<( <http://example/s> <http://example/p> <http://example/o> )>> <http://example/a> <http://example/z> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-reified-1
        test('subject reified triple', () {
          final ntriple =
              '<< <http://example/s> <http://example/p> <http://example/o> >> <http://example/q> <http://example/z> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-reified-2
        test('object reified triple', () {
          final ntriple =
              '<http://example/x> <http://example/p> << <http://example/s> <http://example/p> <http://example/o> >> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-reified-3
        test('subject and object reified triples', () {
          final ntriple =
              '<< <http://example/s1> <http://example/p1> <http://example/o1> >> <http://example/q> << <http://example/s2> <http://example/p2> <http://example/o2> >> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bad-reified-4
        test('predicate reified triple', () {
          final ntriple =
              '<http://example/x> << <http://example/s> <http://example/p> <http://example/o> >> <http://example/z> .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bnode-bad-annotated-syntax-1
        test('annotated triple, blank node subject', () {
          final ntriple =
              '_:b0 <http://example/p> <http://example/o> {| <http://example/q> "ABC" |} .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-star-bnode-bad-annotated-syntax-2
        test('annotated triple, blank node object', () {
          final ntriple =
              '<http://example/s> <http://example/p> _:b1 {| <http://example/q> "456"^^<http://www.w3.org/2001/XMLSchema#integer> |} .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-langdir-bad-1
        test('undefined base direction', () {
          final ntriple =
              '<http://example/a> <http://example/b> "Hello"@en--unk .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });

        // ntriples-langdir-bad-2
        test('upper case LTR', () {
          final ntriple =
              '<http://example/a> <http://example/b> "Hello"@en--LTR .';

          expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
        });
      });
    });
    group('Encoding', () {
      // ntriples-star-syntax-01.nt
      test('object triple term', () {
        final triple = Triple(
          IRITerm(IRI('http://example/a')),
          IRITerm(RDF.reifies),
          TripleTerm(
            Triple(
              IRITerm(IRI('http://example/s')),
              IRITerm(IRI('http://example/p')),
              IRITerm(IRI('http://example/o')),
            ),
          ),
        );

        final encoded = nTriplesCodec.encode([triple]);
        final expectedOutcome =
            '<http://example/a> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/s> <http://example/p> <http://example/o> )>> .\n';
        expect(encoded, equals(expectedOutcome));
      });

      // ntriples-star-bnode-1
      test('Blank node subject', () {
        final triples = [
          Triple(
            BlankNode('b0'),
            IRITerm(IRI('http://example/p')),
            IRITerm(IRI('http://example/o')),
          ),
          Triple(
            BlankNode('b1'),
            IRITerm(RDF.reifies),
            TripleTerm(
              Triple(
                BlankNode('b0'),
                IRITerm(IRI('http://example/p')),
                IRITerm(IRI('http://example/o')),
              ),
            ),
          ),
        ];

        final encoded = nTriplesCodec.encode(triples);
        final expectedOutcome = '''
_:b0 <http://example/p> <http://example/o> .
_:b1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( _:b0 <http://example/p> <http://example/o> )>> .
''';
        expect(encoded, equals(expectedOutcome));
      });

      test('Nested object term', () {
        final triples = [
          Triple(
            IRITerm(IRI('http://example/s')),
            IRITerm(IRI('http://example/p')),
            IRITerm(IRI('http://example/o')),
          ),
          Triple(
            IRITerm(IRI('http://example/a')),
            IRITerm(RDF.reifies),
            TripleTerm(
              Triple(
                IRITerm(IRI('http://example/s1')),
                IRITerm(IRI('http://example/p1')),
                IRITerm(IRI('http://example/o1')),
              ),
            ),
          ),
          Triple(
            IRITerm(IRI('http://example/r')),
            IRITerm(RDF.reifies),
            TripleTerm(
              Triple(
                IRITerm(IRI('http://example/23')),
                IRITerm(RDF.reifies),
                TripleTerm(
                  Triple(
                    IRITerm(IRI('http://example/s3')),
                    IRITerm(IRI('http://example/p3')),
                    IRITerm(IRI('http://example/o3')),
                  ),
                ),
              ),
            ),
          ),
        ];

        final encoded = nTriplesCodec.encode(triples);
        final expectedOutcome = '''
<http://example/s> <http://example/p> <http://example/o> .
<http://example/a> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/s1> <http://example/p1> <http://example/o1> )>> .
<http://example/r> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/23> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/s3> <http://example/p3> <http://example/o3> )>> )>> .
''';
        expect(encoded, equals(expectedOutcome));
      });
    });
  });
}
