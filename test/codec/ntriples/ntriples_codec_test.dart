import 'package:intl/locale.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/codec/ntriples/parse_error.dart';
import 'package:rdf_dart/src/data_types.dart' show DatatypeRegistry;
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
            ((decoded.first.object as TripleTerm).triple.object as TripleTerm)
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
          expect(
            (decoded.first.object as Literal).datatype,
            equals(RDF.langString),
          );
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
          expect(
            (decoded.first.object as Literal).datatype,
            equals(RDF.langString),
          );
        });
      });

      group('with invalid syntax', () {
        // ntriples-star-bad-01
        test('reified triple as predicate', () {
          final ntriple =
              '<http://example/a> <<( <http://example/s> <http://example/p> <http://example/o> )>>  <http://example/z> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-02
        test('reified triple, literal subject', () {
          final ntriple =
              '<http://example/q> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( "XYZ" <http://example/p> <http://example/o> )>> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-03
        test('reified triple, literal predicate', () {
          final ntriple =
              '<http://example/q> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> <<( <http://example/s> "XYZ" <http://example/o> )>> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-04
        test('reified triple, blank node predicate', () {
          final ntriple =
              '<http://example/q> <http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies> << <http://example/s> _:label <http://example/o> >> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-05
        test('triple term as predicate', () {
          final ntriple =
              '<http://example/a> <<( <http://example/s> <http://example/p>  <http://example/o> )>> <http://example/z> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-06
        test('triple term, literal subject', () {
          final ntriple =
              '<<( "XYZ" <http://example/p> <http://example/o> )>> <http://example/q> <http://example/z> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-07
        test('triple term, literal predicate', () {
          final ntriple =
              '<<( <http://example/s> "XYZ" <http://example/o> )>> <http://example/q> <http://example/z> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-08
        test('triple term, blank node predicate', () {
          final ntriple =
              '<<( <http://example/s> _:label <http://example/o> )>> <http://example/q> <http://example/z> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-09
        test('reified triple object', () {
          final ntriple =
              '<http://example/a> <http://example/b> << <http://example/s> <http://example/p> <http://example/o> >> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-10
        test('triple term as subject', () {
          final ntriple =
              '<<( <http://example/s> <http://example/p> <http://example/o> )>> <http://example/a> <http://example/z> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-reified-1
        test('subject reified triple', () {
          final ntriple =
              '<< <http://example/s> <http://example/p> <http://example/o> >> <http://example/q> <http://example/z> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-reified-2
        test('object reified triple', () {
          final ntriple =
              '<http://example/x> <http://example/p> << <http://example/s> <http://example/p> <http://example/o> >> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-reified-3
        test('subject and object reified triples', () {
          final ntriple =
              '<< <http://example/s1> <http://example/p1> <http://example/o1> >> <http://example/q> << <http://example/s2> <http://example/p2> <http://example/o2> >> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bad-reified-4
        test('predicate reified triple', () {
          final ntriple =
              '<http://example/x> << <http://example/s> <http://example/p> <http://example/o> >> <http://example/z> .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bnode-bad-annotated-syntax-1
        test('annotated triple, blank node subject', () {
          final ntriple =
              '_:b0 <http://example/p> <http://example/o> {| <http://example/q> "ABC" |} .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-star-bnode-bad-annotated-syntax-2
        test('annotated triple, blank node object', () {
          final ntriple =
              '<http://example/s> <http://example/p> _:b1 {| <http://example/q> "456"^^<http://www.w3.org/2001/XMLSchema#integer> |} .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-langdir-bad-1
        test('undefined base direction', () {
          final ntriple =
              '<http://example/a> <http://example/b> "Hello"@en--unk .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
        });

        // ntriples-langdir-bad-2
        test('upper case LTR', () {
          final ntriple =
              '<http://example/a> <http://example/b> "Hello"@en--LTR .';

          expect(
            () => nTriplesCodec.decode(ntriple),
            throwsA(isA<ParseError>()),
          );
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

    group('Canonicalization', () {
      test('Tests canonicalization of triples including comments', () {
        final input = '''
# comment
<http://example/s> <http://example/p> <http://example/o> . # comment
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> <http://example/o> .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test(
        'Tests canonicalization of triples including language-tagged string',
        () {
          final input = '''
<http://a.example/s> <http://a.example/p> "chat"@en .
''';
          final expectedOutput = '''
<http://a.example/s> <http://a.example/p> "chat"@en .
''';

          final decoded = nTriplesCodec.decode(input);
          final reencoded = nTriplesCodec.encode(decoded);

          expect(reencoded, equals(expectedOutput));
        },
      );

      test(
        'Tests canonicalization of triples including directional language-tagged string',
        () {
          final input = '''
<http://a.example/s> <http://a.example/p> "chat"@en--ltr .
''';
          final expectedOutput = '''
<http://a.example/s> <http://a.example/p> "chat"@en--ltr .
''';

          final decoded = nTriplesCodec.decode(input);
          final reencoded = nTriplesCodec.encode(decoded);

          expect(reencoded, equals(expectedOutput));
        },
      );

      test('Tests canonicalization of literals with control characters', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u0008\t\u000B\u000C\u000E\u000F\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001A\u001B\u001C\u001D\u001E\u001F" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\b\t\u000B\f\u000E\u000F\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001A\u001B\u001C\u001D\u001E\u001F" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test(
        'Tests canonicalization of literals with punctuation characters',
        () {
          final input = r'''
<http://a.example/s> <http://a.example/p> " !\"#$%&():;<=>?@[]^_`{|}~" .
''';
          final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> " !\"#$%&():;<=>?@[]^_`{|}~" .
''';

          final decoded = nTriplesCodec.decode(input);
          final reencoded = nTriplesCodec.encode(decoded);

          expect(reencoded, equals(expectedOutput));
        },
      );

      test(
        r"Tests canonicalization of literal_ascii_boundaries '\x00\x26\x28...'",
        () {
          final input = '''
<http://a.example/s> <http://a.example/p> " 	&([]" .
''';
          final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "\u0000\t\u000B\f\u000E&([]\u007F" .
''';

          final decoded = nTriplesCodec.decode(input);
          final reencoded = nTriplesCodec.encode(decoded);

          expect(reencoded, equals(expectedOutput));
        },
      );

      test(
        r'Tests canonicalization of literal with 2 dquotes \"\"\"a\"\"b\"\"\"',
        () {
          final input = r'''
<http://a.example/s> <http://a.example/p> "x\"\"y" .
''';
          final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "x\"\"y" .
''';

          final decoded = nTriplesCodec.decode(input);
          final reencoded = nTriplesCodec.encode(decoded);

          expect(reencoded, equals(expectedOutput));
        },
      );

      test("Tests canonicalization of literal with 2 squotes \"x''y\"", () {
        final input = '''
<http://a.example/s> <http://a.example/p> "x''y" .
''';
        final expectedOutput = '''
<http://a.example/s> <http://a.example/p> "x''y" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with backspace', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "\b" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "\b" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with carriage return', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "\r" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "\r" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with character tabulation', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "\t" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "\t" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with double quote', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "x\"y" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "x\"y" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with form feed', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "\f" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "\f" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with line feed', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "\n" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "\n" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with numeric escapes', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "\u006F" .
''';
        final expectedOutput = '''
<http://a.example/s> <http://a.example/p> "o" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with numeric escapes 4', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "\u006F" .
''';
        final expectedOutput = '''
<http://a.example/s> <http://a.example/p> "o" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with numeric escapes 8', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "\U0000006F" .
''';
        final expectedOutput = '''
<http://a.example/s> <http://a.example/p> "o" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with reverse solidus', () {
        final input = r'''
<http://a.example/s> <http://a.example/p> "\\" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "\\" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with reverse solidus 2', () {
        final input = r'''
<http://example.org/ns#s> <http://example.org/ns#p1> "test-\\" .
''';
        final expectedOutput = r'''
<http://example.org/ns#s> <http://example.org/ns#p1> "test-\\" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with single quotes', () {
        final input = '''
<http://a.example/s> <http://a.example/p> "x'y" .
''';
        final expectedOutput = '''
<http://a.example/s> <http://a.example/p> "x'y" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literal with explicit xsd:string', () {
        final input = '''
<http://example/s> <http://example/p> "foo"^^<http://www.w3.org/2001/XMLSchema#string> .
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> "foo" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of literals with UTF8 boundaries', () {
        final input = '''
<http://a.example/s> <http://a.example/p> "߿ࠀ࿿က쿿퀀퟿�𐀀𿿽񀀀󿿽􀀀􏿽" .
''';
        final expectedOutput = '''
<http://a.example/s> <http://a.example/p> "߿ࠀ࿿က쿿퀀퟿�𐀀𿿽񀀀󿿽􀀀􏿽" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of triples without optional whitespace', () {
        final input = '''
<http://example/s><http://example/p><http://example/o>.
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> <http://example/o> .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test(
        'Tests canonicalization of triples without optional whitespace 2',
        () {
          final input = '''
<http://example/s><http://example/p>"Alice".
''';
          final expectedOutput = '''
<http://example/s> <http://example/p> "Alice" .
''';

          final decoded = nTriplesCodec.decode(input);
          final reencoded = nTriplesCodec.encode(decoded);

          expect(reencoded, equals(expectedOutput));
        },
      );

      test('Tests canonicalization of triples with extra whitespace', () {
        final input = '''
<http://example/s>  <http://example/p>  <http://example/o>  .  
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> <http://example/o> .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of triples with extra whitespace 2', () {
        final input = '''
<http://example/s>  <http://example/p>  "Alice"  .
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> "Alice" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of triples with extra whitespace 3', () {
        final input = '''
<http://example/s>  <http://example/p>  "Alice" @en  .
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> "Alice"@en .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of triples with extra whitespace 4', () {
        final input = '''
<http://example/s>  <http://example/p>  "2"  ^^  <http://www.w3.org/2001/XMLSchema#integer>  .
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> "2"^^<http://www.w3.org/2001/XMLSchema#integer> .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of IRIs', () {
        final input = '''
<http://example/s> <http://example/p> <http://example/o> .
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> <http://example/o> .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of IRIs #2', () {
        final input = '''
# x53 is capital S
<http://example/\u0053> <http://example/p> <http://example/o> .
''';
        final expectedOutput = '''
<http://example/S> <http://example/p> <http://example/o> .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of IRIs #3', () {
        final input = r'''
# x53 is capital S
<http://example/\U00000053> <http://example/p> <http://example/o> .
''';
        final expectedOutput = '''
<http://example/S> <http://example/p> <http://example/o> .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      // FIXME: Test fails with the following message:
      // Expected: '<http://example/s> <http://example/p> <scheme:!$%25&\'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#> .\n'
      //      ''
      // Actual: '<http://example/s> <http://example/p> <scheme:!$%25&\'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~#> .\n'
      //      ''
      // Which: is different.
      //    Expected: ... rstuvwxyz~?#> .\n
      //      Actual: ... rstuvwxyz~#> .\n
      //                            ^
      //     Differ at offset 128
      //
      // package:matcher                                      expect
      // test/codec/ntriples/ntriples_codec_test.dart 1090:9  main.<fn>.<fn>.<fn>
      test('Tests canonicalization of IRIs #4', () {
        final input = r'''
# IRI with all chars in it.
<http://example/s> <http://example/p> <scheme:!$%25&'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#> .
''';
        final expectedOutput = r'''
<http://example/s> <http://example/p> <scheme:!$%25&'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#> .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of string escapes', () {
        final input = r'''
<http://example/s> <http://example/p> "a\n" .
''';
        final expectedOutput = r'''
<http://example/s> <http://example/p> "a\n" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of string escapes #2', () {
        final input = r'''
<http://example/s> <http://example/p> "a\u0020b" .
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> "a b" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of string escapes #3', () {
        final input = r'''
<http://example/s> <http://example/p> "a\U00000020b" .
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> "a b" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });
    });
  });

  group('N-Triples 1.1 Syntax Tests', () {
    group('Positive syntax', () {
      // nt-syntax-file-01
      test('Empty file', () {
        final ntriple = '';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 0);
      });
      // nt-syntax-file-02
      test('Only comment', () {
        final ntriple = '''
#Empty file.
''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 0);
      });
      // nt-syntax-file-03
      test('One comment, one empty line', () {
        final ntriple = '''
#One comment, one empty line.


''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 0);
      });

      // nt-syntax-uri-01
      test('Only IRIs', () {
        final ntriple = '''
<http://example/s> <http://example/p> <http://example/o> .
''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          (decoded.first.subject as IRITerm).value,
          equals(IRI('http://example/s')),
        );
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(
          (decoded.first.object as IRITerm).value,
          equals(IRI('http://example/o')),
        );
      });

      // nt-syntax-uri-02
      test('IRIs with Unicode escape', () {
        final ntriple = r'''
# x53 is capital S
<http://example/\u0053> <http://example/p> <http://example/o> .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          (decoded.first.subject as IRITerm).value,
          equals(IRI('http://example/S')),
        );
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(
          (decoded.first.object as IRITerm).value,
          equals(IRI('http://example/o')),
        );
      });

      // nt-syntax-uri-03
      test('IRIs with long Unicode escape', () {
        final ntriple = r'''
# x53 is capital S
<http://example/\U00000053> <http://example/p> <http://example/o> .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          (decoded.first.subject as IRITerm).value,
          equals(IRI('http://example/S')),
        );
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(
          (decoded.first.object as IRITerm).value,
          equals(IRI('http://example/o')),
        );
      });

      // nt-syntax-uri-04
      test('Legal IRIs', () {
        final ntriple = r'''
# IRI with all chars in it.
<http://example/s> <http://example/p> <scheme:!$%25&'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#> .
''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          (decoded.first.subject as IRITerm).value,
          equals(IRI('http://example/s')),
        );
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(
          (decoded.first.object as IRITerm).value,
          equals(
            IRI(
              r"scheme:!$%25&'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#",
            ),
          ),
        );
      });

      // nt-syntax-string-01
      test('string literal', () {
        final ntriple = '''
<http://example/s> <http://example/p> "string" .
''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          (decoded.first.subject as IRITerm).value,
          equals(IRI('http://example/s')),
        );
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(decoded.first.object, equals(Literal('string', XSD.string)));
      });

      // nt-syntax-string-02
      test('langString literal', () {
        final ntriple = '''
<http://example/s> <http://example/p> "string"@en .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          (decoded.first.subject as IRITerm).value,
          equals(IRI('http://example/s')),
        );
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(
          decoded.first.object,
          equals(Literal('string', RDF.langString, 'en')),
        );
      });

      // nt-syntax-string-03
      test('langString literal with region', () {
        final ntriple = '''
<http://example/s> <http://example/p> "string"@en-uk .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          (decoded.first.subject as IRITerm).value,
          equals(IRI('http://example/s')),
        );
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(
          decoded.first.object,
          equals(Literal('string', RDF.langString, 'en-uk')),
        );
      });

      // nt-syntax-str-esc-01
      test('string literal with escaped newline', () {
        final ntriple = r'''
<http://example/s> <http://example/p> "a\n" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          (decoded.first.subject as IRITerm).value,
          equals(IRI('http://example/s')),
        );
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(decoded.first.object, equals(Literal('a\n', XSD.string)));
      });

      // nt-syntax-str-esc-02
      test('string literal with Unicode escape', () {
        final ntriple = r'''
<http://example/s> <http://example/p> "a\u0020b" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          (decoded.first.subject as IRITerm).value,
          equals(IRI('http://example/s')),
        );
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(decoded.first.object, equals(Literal('a b', XSD.string)));
      });

      // nt-syntax-str-esc-03
      test('string literal with long Unicode escape', () {
        final ntriple = r'''
<http://example/s> <http://example/p> "a\U00000020b" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          (decoded.first.subject as IRITerm).value,
          equals(IRI('http://example/s')),
        );
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(decoded.first.object, equals(Literal('a b', XSD.string)));
      });

      // nt-syntax-bnode-01
      test('bnode subject', () {
        final ntriple = '''
_:a  <http://example/p> <http://example/o> .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(decoded.first.subject, equals(BlankNode('a')));
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(decoded.first.object, equals(IRITerm(IRI('http://example/o'))));
      });

      // nt-syntax-bnode-02
      test('bnode object', () {
        final ntriple = '''
<http://example/s> <http://example/p> _:a .
_:a  <http://example/p> <http://example/o> .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 2);
        expect(decoded.first.subject, equals(IRITerm(IRI('http://example/s'))));
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(decoded.first.object, equals(BlankNode('a')));
        expect(decoded.last.subject, equals(BlankNode('a')));
        expect(
          decoded.last.predicate,
          equals(IRITerm(IRI('http://example/p'))),
        );
        expect(decoded.last.object, equals(IRITerm(IRI('http://example/o'))));
      });

      // nt-syntax-bnode-03
      test('Blank node labels may start with a digit', () {
        final ntriple = '''
<http://example/s> <http://example/p> _:1a .
_:1a  <http://example/p> <http://example/o> .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 2);
        expect(decoded.first.subject, equals(IRITerm(IRI('http://example/s'))));
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(decoded.first.object, equals(BlankNode('1a')));
        expect(decoded.last.subject, equals(BlankNode('1a')));
        expect(
          decoded.last.predicate,
          equals(IRITerm(IRI('http://example/p'))),
        );
        expect(decoded.last.object, equals(IRITerm(IRI('http://example/o'))));
      });

      // nt-syntax-datatypes-01
      test('xsd:byte literal', () {
        final ntriple = '''
<http://example/s> <http://example/p> "123"^^<http://www.w3.org/2001/XMLSchema#byte> .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(decoded.first.subject, equals(IRITerm(IRI('http://example/s'))));
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(decoded.first.object, equals(Literal('123', XSD.byte)));
      });

      // nt-syntax-datatypes-02
      test('integer as xsd:string', () {
        final ntriple = '''
<http://example/s> <http://example/p> "123"^^<http://www.w3.org/2001/XMLSchema#string> .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(decoded.first.subject, equals(IRITerm(IRI('http://example/s'))));
        expect(decoded.first.predicate.value, equals(IRI('http://example/p')));
        expect(decoded.first.object, equals(Literal('123', XSD.string)));
      });

      // nt-syntax-bad-num-03
      test('Submission test from Original RDF Test Cases', () {
        DatatypeRegistry().registerDatatype(
          IRI('http://www.w3.org/2000/01/rdf-schema#XMLLiteral'),
          String,
          (String lexicalForm) => lexicalForm,
          (Object value) => value.toString(),
        );
        DatatypeRegistry().registerDatatype(
          IRI('http://example.org/datatype1'),
          String,
          (String lexicalForm) => lexicalForm,
          (Object value) => value.toString(),
        );
        final ntriplesDoc = r'''
#
# Copyright World Wide Web Consortium, (Massachusetts Institute of
# Technology, Institut National de Recherche en Informatique et en
# Automatique, Keio University).
#
# All Rights Reserved.
#
# Please see the full Copyright clause at
# <http://www.w3.org/Consortium/Legal/copyright-software.html>
#
# Test file with a variety of legal N-Triples
#
# Dave Beckett - http://purl.org/net/dajobe/
# 
# $Id: test.nt,v 1.7 2003/10/06 15:52:19 dbeckett2 Exp $
# 
#####################################################################

# comment lines
  	  	   # comment line after whitespace
# empty blank line, then one with spaces and tabs

         	
<http://example.org/resource1> <http://example.org/property> <http://example.org/resource2> .
_:anon <http://example.org/property> <http://example.org/resource2> .
<http://example.org/resource2> <http://example.org/property> _:anon .
# spaces and tabs throughout:
 	 <http://example.org/resource3> 	 <http://example.org/property>	 <http://example.org/resource2> 	.	 

# line ending with CR NL (ASCII 13, ASCII 10)
<http://example.org/resource4> <http://example.org/property> <http://example.org/resource2> .

# 2 statement lines separated by single CR (ASCII 10)
<http://example.org/resource5> <http://example.org/property> <http://example.org/resource2> .
<http://example.org/resource6> <http://example.org/property> <http://example.org/resource2> .


# All literal escapes
<http://example.org/resource7> <http://example.org/property> "simple literal" .
<http://example.org/resource8> <http://example.org/property> "backslash:\\" .
<http://example.org/resource9> <http://example.org/property> "dquote:\"" .
<http://example.org/resource10> <http://example.org/property> "newline:\n" .
<http://example.org/resource11> <http://example.org/property> "return\r" .
<http://example.org/resource12> <http://example.org/property> "tab:\t" .

# Space is optional before final .
<http://example.org/resource13> <http://example.org/property> <http://example.org/resource2>.
<http://example.org/resource14> <http://example.org/property> "x".
<http://example.org/resource15> <http://example.org/property> _:anon.

# \u and \U escapes
# latin small letter e with acute symbol \u00E9 - 3 UTF-8 bytes #xC3 #A9
<http://example.org/resource16> <http://example.org/property> "\u00E9" .
# Euro symbol \u20ac  - 3 UTF-8 bytes #xE2 #x82 #xAC
<http://example.org/resource17> <http://example.org/property> "\u20AC" .
# resource18 test removed
# resource19 test removed
# resource20 test removed

# XML Literals as Datatyped Literals
<http://example.org/resource21> <http://example.org/property> ""^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource22> <http://example.org/property> " "^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource23> <http://example.org/property> "x"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource23> <http://example.org/property> "\""^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource24> <http://example.org/property> "<a></a>"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource25> <http://example.org/property> "a <b></b>"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource26> <http://example.org/property> "a <b></b> c"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource26> <http://example.org/property> "a\n<b></b>\nc"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource27> <http://example.org/property> "chat"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
# resource28 test removed 2003-08-03
# resource29 test removed 2003-08-03

# Plain literals with languages
<http://example.org/resource30> <http://example.org/property> "chat"@fr .
<http://example.org/resource31> <http://example.org/property> "chat"@en .

# Typed Literals
<http://example.org/resource32> <http://example.org/property> "abc"^^<http://example.org/datatype1> .
# resource33 test removed 2003-08-03
''';
        final decoded = nTriplesCodec.decode(ntriplesDoc);
        expect(decoded.length, 30);
      });

      // comment_following_triple
      test('Tests comments after a triple', () {
        DatatypeRegistry().registerDatatype(
          IRI('http://example/dt'),
          String,
          (String lexicalForm) => lexicalForm,
          (Object value) => value.toString(),
        );

        final ntriple = '''
<http://example/s> <http://example/p> <http://example/o> . # comment
<http://example/s> <http://example/p> _:o . # comment
<http://example/s> <http://example/p> "o" . # comment
<http://example/s> <http://example/p> "o"^^<http://example/dt> . # comment
<http://example/s> <http://example/p> "o"@en . # comment

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 5);
      });

      // literal
      test('literal """x"""', () {
        final ntriple = '''
<http://a.example/s> <http://a.example/p> "x" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal('x', XSD.string)));
      });

      // literal_all_controls
      test(r"literal_all_controls '\x00\x01\x02\x03\x04…'", () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u0008\t\u000B\u000C\u000E\u000F\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001A\u001B\u001C\u001D\u001E\u001F" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(
          decoded.first.object,
          equals(
            Literal(
              '\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u0008\t\u000B\u000C\u000E\u000F\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001A\u001B\u001C\u001D\u001E\u001F',
              XSD.string,
            ),
          ),
        );
      });

      // literal_all_punctuation
      test('literal all punctuation', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> " !\"#$%&():;<=>?@[]^_`{|}~" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(
          decoded.first.object,
          equals(Literal(r' !"#$%&():;<=>?@[]^_`{|}~', XSD.string)),
        );
      });

      // literal_ascii_boundaries
      test(r"literal_ascii_boundaries '\x00\x26\x28…'", () {
        final ntriple = '''
<http://a.example/s> <http://a.example/p> " 	&([]" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal(' 	&([]', XSD.string)));
      });

      // literal_with_2_dquotes
      test('literal with 2 dquotes """a""b"""', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "x\"\"y" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal('x""y', XSD.string)));
      });

      // literal_with_2_squotes
      test("literal with 2 squotes x''y", () {
        final ntriple = '''
<http://a.example/s> <http://a.example/p> "x''y" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal("x''y", XSD.string)));
      });

      // literal_with_BACKSPACE
      test('literal with BACKSPACE', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "\b" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal('\b', XSD.string)));
      });

      // literal_with_CARRIAGE_RETURN
      test('literal with CARRIAGE RETURN', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "\r" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal('\r', XSD.string)));
      });

      // literal_with_CHARACTER_TABULATION
      test('literal with CHARACTER TABULATION', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "\t" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal('\t', XSD.string)));
      });

      // literal_with_dquote
      test('literal with dquote "x"y"', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "x\"y" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal('x"y', XSD.string)));
      });

      // literal_with_FORM_FEED
      test('literal with FORM FEED', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "\f" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal('\f', XSD.string)));
      });

      // literal_with_LINE_FEED
      test('literal with LINE FEED', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "\n" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal('\n', XSD.string)));
      });

      // literal_with_numeric_escape4
      test(r'literal with numeric escape4 \u', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "\u006F" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal('\u006F', XSD.string)));
      });

      // literal_with_numeric_escape4
      test(r'literal with numeric escape8 \U', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "\U0000006F" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal('\u006F', XSD.string)));
      });

      // literal_with_REVERSE_SOLIDUS
      test('literal with REVERSE SOLIDUS', () {
        final ntriple = r'''
<http://a.example/s> <http://a.example/p> "\\" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal(r'\', XSD.string)));
      });

      // literal_with_REVERSE_SOLIDUS2
      test('REVERSE SOLIDUS at end of literal', () {
        final ntriple = r'''
<http://example.org/ns#s> <http://example.org/ns#p1> "test-\\" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://example.org/ns#s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://example.org/ns#p1')),
        );
        expect(decoded.first.object, equals(Literal(r'test-\', XSD.string)));
      });

      // literal_with_squote
      test("literal with squote x'y", () {
        final ntriple = '''
<http://a.example/s> <http://a.example/p> "x'y" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(decoded.first.object, equals(Literal("x'y", XSD.string)));
      });

      // literal_with_UTF8_boundaries
      test(r"literal with UTF8 boundaries '\x80\x7ff\x800\xfff…'", () {
        final ntriple = '''
<http://a.example/s> <http://a.example/p> "߿ࠀ࿿က쿿퀀퟿�𐀀𿿽񀀀󿿽􀀀􏿽" .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(
          decoded.first.object,
          equals(Literal('߿ࠀ࿿က쿿퀀퟿�𐀀𿿽񀀀󿿽􀀀􏿽', XSD.string)),
        );
      });

      // langtagged_string
      test('langtagged string "x"@en', () {
        final ntriple = '''
<http://a.example/s> <http://a.example/p> "chat"@en .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://a.example/s'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://a.example/p')),
        );
        expect(
          decoded.first.object,
          equals(Literal('chat', RDF.langString, 'en')),
        );
      });

      // lantag_with_subtag
      test('lantag with subtag "x"@en-us', () {
        final ntriple = '''
<http://example.org/ex#a> <http://example.org/ex#b> "Cheers"@en-UK .

''';
        final decoded = nTriplesCodec.decode(ntriple);
        expect(decoded.length, 1);
        expect(
          decoded.first.subject,
          equals(IRITerm(IRI('http://example.org/ex#a'))),
        );
        expect(
          decoded.first.predicate.value,
          equals(IRI('http://example.org/ex#b')),
        );
        expect(
          decoded.first.object,
          equals(Literal('Cheers', RDF.langString, 'en-UK')),
        );
      });

      // minimal_whitespace
      test(
        'tests absense of whitespace between subject, predicate, object and end-of-statement',
        () {
          final ntriple = '''
<http://example/s><http://example/p><http://example/o>.
<http://example/s><http://example/p>"Alice".
<http://example/s><http://example/p>_:o.
_:s<http://example/p><http://example/o>.
_:s<http://example/p>"Alice".
_:s<http://example/p>_:bnode1.

''';
          final decoded = nTriplesCodec.decode(ntriple);
          expect(decoded.length, 6);
        },
      );
    });

    group('Negative Syntax', () {
      // nt-syntax-bad-uri-01
      test('Bad IRI : space', () {
        final ntriple = '''
# Bad IRI : space.
<http://example/ space> <http://example/p> <http://example/o> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-uri-02
      test('Bad IRI : bad escape', () {
        final ntriple = r'''
# Bad IRI : bad escape
<http://example/\u00ZZ11> <http://example/p> <http://example/o> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-uri-03
      test('Bad IRI : bad long escape', () {
        final ntriple = r'''
# Bad IRI : bad escape
<http://example/\U00ZZ1111> <http://example/p> <http://example/o> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-uri-04
      test('Bad IRI : character escapes not allowed', () {
        final ntriple = r'''
# Bad IRI : character escapes not allowed.
<http://example/\n> <http://example/p> <http://example/o> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-uri-05
      test('Bad IRI : character escapes not allowed (2)', () {
        final ntriple = r'''
# Bad IRI : character escapes not allowed.
<http://example/\/> <http://example/p> <http://example/o> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      test('Bad IRI : relative IRI not allowed in subject', () {
        final ntriple = '''
# No relative IRIs in N-Triples
<s> <http://example/p> <http://example/o> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      test('Bad IRI : relative IRI not allowed in predicate', () {
        final ntriple = '''
# No relative IRIs in N-Triples
<http://example/s> <p> <http://example/o> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      test('Bad IRI : relative IRI not allowed in object', () {
        final ntriple = '''
# No relative IRIs in N-Triples
<http://example/s> <http://example/p> <o> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-uri-09
      test('Bad IRI : relative IRI not allowed in datatype', () {
        final ntriple = '''
# No relative IRIs in N-Triples
<http://example/s> <http://example/p> "foo"^^<dt> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-prefix-01
      test('@prefix not allowed in n-triples', () {
        final ntriple = '''
@prefix : <http://example/> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-base-01
      test('@base not allowed in N-Triples', () {
        final ntriple = '''
@base <http://example/> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-bnode-01
      test('Colon in bnode label not allowed', () {
        final ntriple = '''
_::a  <http://example/p> <http://example/o> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-bnode-02
      test('Colon in bnode label not allowed (2)', () {
        final ntriple = '''
_:abc:def  <http://example/p> <http://example/o> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-struct-01
      test('N-Triples does not have objectList', () {
        final ntriple = '''
<http://example/s> <http://example/p> <http://example/o>, <http://example/o2> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-struct-02
      test('N-Triples does not have predicateObjectList', () {
        final ntriple = '''
<http://example/s> <http://example/p> <http://example/o>; <http://example/p2>, <http://example/o2> .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-lang-01
      test('langString with bad lang', () {
        final ntriple = '''
# Bad lang tag
<http://example/s> <http://example/p> "string"@1 .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-esc-01
      test('Bad string escape', () {
        final ntriple = r'''
# Bad string escape
<http://example/s> <http://example/p> "a\zb" .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-esc-02
      test('Bad string escape #2', () {
        final ntriple = r'''
# Bad string escape
<http://example/s> <http://example/p> "\uWXYZ" .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-esc-03
      test('Bad string escape #3', () {
        final ntriple = r'''
# Bad string escape
<http://example/s> <http://example/p> "\U0000WXYZ" .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-string-01
      test('mismatching string literal open/close', () {
        final ntriple = '''
<http://example/s> <http://example/p> "abc' .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-string-02
      test('mismatching string literal open/close #2', () {
        final ntriple = '''
<http://example/s> <http://example/p> 1.0 .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-string-03
      test('single quotes', () {
        final ntriple = '''
<http://example/s> <http://example/p> 1.0e1 .

''';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-string-04
      test('long single string literal', () {
        final ntriple = "<http://example/s> <http://example/p> '''abc''' .";
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-string-05
      test('long double string literal', () {
        final ntriple = '<http://example/s> <http://example/p> """abc""" .';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-string-06
      test('string literal with no end', () {
        final ntriple = '<http://example/s> <http://example/p> "abc .';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-string-07
      test('string literal with no start', () {
        final ntriple = '<http://example/s> <http://example/p> abc" .';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-num-01
      test('no numbers in N-Triples (integer)', () {
        final ntriple = '<http://example/s> <http://example/p> 1 .';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-num-02
      test('no numbers in N-Triples (decimal)', () {
        final ntriple = '<http://example/s> <http://example/p> 1.0 .';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });

      // nt-syntax-bad-num-03
      test('no numbers in N-Triples (float)', () {
        final ntriple = '<http://example/s> <http://example/p> 1.0e0 .';
        expect(() => nTriplesCodec.decode(ntriple), throwsA(isA<ParseError>()));
      });
    });
  });
}
