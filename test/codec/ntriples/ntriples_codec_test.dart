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

    group('Canonicalization', () {
      // FIXME: Test currently fails with the following message:
      // Parse Error (L2:C59): Unexpected characters after final dot (.)
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 212:7   _NTriplesDecoderSink._parseTripleLine
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 163:22  _NTriplesDecoderSink._processLine
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 134:7   _NTriplesDecoderSink._processBuffer
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 80:5    _NTriplesDecoderSink.add
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 32:20   NTriplesDecoder.convert
      // dart:convert                                                      Codec.decode
      // test/codec/ntriples/ntriples_codec_test.dart 619:39               main.<fn>.<fn>.<fn>
      test('Tests canonicalization of triples including comments', (){
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

      test('Tests canonicalization of triples including language-tagged string', (){
        final input = '''
<http://a.example/s> <http://a.example/p> "chat"@en .
''';
        final expectedOutput = '''
<http://a.example/s> <http://a.example/p> "chat"@en .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of triples including directional language-tagged string', (){
        final input = '''
<http://a.example/s> <http://a.example/p> "chat"@en--ltr .
''';
        final expectedOutput = '''
<http://a.example/s> <http://a.example/p> "chat"@en--ltr .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      // FIXME: Test currently fails with the following message:
      // Expected: '<http://a.example/s> <http://a.example/p> "\\u0000\\u0001\\u0002\\u0003\\u0004\\u0005\\u0006\\u0007\\b\\t\\u000B\\f\\u000E\\u000F\\u0010\\u0011\\u0012\\u0013\\u0014\\u0015\\u0016\\u0017\\u0018\\u0019\\u001A\\u001B\\u001C\\u001D\\u001E\\u001F" .\n'
      //      ''
      // Actual: '<http://a.example/s> <http://a.example/p> "\\u0000\\u0001\\u0002\\u0003\\u0004\\u0005\\u0006\\u0007\\u0008\\t\\u000B\\u000C\\u000E\\u000F\\u0010\\u0011\\u0012\\u0013\\u0014\\u0015\\u0016\\u0017\\u0018\\u0019\\u001A\\u001B\\u001C\\u001D\\u001E\\u001F" .\n'
      //      ''
      // Which: is different.
      //    Expected: ... 6\\u0007\\b\\t\\u000 ...
      //      Actual: ... 6\\u0007\\u0008\\t\\ ...
      //                            ^
      //     Differ at offset 101
      //
      // package:matcher                                     expect
      // test/codec/ntriples/ntriples_codec_test.dart 686:9  main.<fn>.<fn>.<fn>
      test('Tests canonicalization of literals with control characters', (){
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

      test('Tests canonicalization of literals with punctuation characters', (){
        final input = r'''
<http://a.example/s> <http://a.example/p> " !\"#$%&():;<=>?@[]^_`{|}~" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> " !\"#$%&():;<=>?@[]^_`{|}~" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      // FIXME: Test currently fails with the following message:
      // Expected: '<http://a.example/s> <http://a.example/p> "\\u0000\\t\\u000B\\f\\u000E&([]\\u007F" .\n'
      //       ''
      // Actual: '<http://a.example/s> <http://a.example/p> "\\u0000\\t\\u000B\\u000C\\u000E&([]\\u007F" .\n'
      //      ''
      // Which: is different.
      //    Expected: ... t\\u000B\\f\\u000E&( ...
      //      Actual: ... t\\u000B\\u000C\\u00 ...
      //                            ^
      //     Differ at offset 62
      //
      // package:matcher                                     expect
      // test/codec/ntriples/ntriples_codec_test.dart 727:9  main.<fn>.<fn>.<fn>
      test(r"Tests canonicalization of literal_ascii_boundaries '\x00\x26\x28...'", (){
        final input = '''
<http://a.example/s> <http://a.example/p> " 	&([]" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "\u0000\t\u000B\f\u000E&([]\u007F" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test(r'Tests canonicalization of literal with 2 dquotes \"\"\"a\"\"b\"\"\"', (){
        final input = r'''
<http://a.example/s> <http://a.example/p> "x\"\"y" .
''';
        final expectedOutput = r'''
<http://a.example/s> <http://a.example/p> "x\"\"y" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test("Tests canonicalization of literal with 2 squotes \"x''y\"", (){
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

      // FIXME: Test fails with the following message:
      // Expected: '<http://a.example/s> <http://a.example/p> "\b" .\n'
      //      ''
      // Actual: '<http://a.example/s> <http://a.example/p> "\\u0008" .\n'
      //      ''
      // Which: is different.
      //    Expected: ... mple/p> "\b" .\n
      //      Actual: ... mple/p> "\\u0008" .\ ...
      //                            ^
      //     Differ at offset 44
      //
      // package:matcher                                     expect
      // test/codec/ntriples/ntriples_codec_test.dart 733:9  main.<fn>.<fn>.<fn>
      test('Tests canonicalization of literals with backspace', (){
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

      test('Tests canonicalization of literals with carriage return', (){
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

      test('Tests canonicalization of literals with character tabulation', (){
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

      // FIXME: Current test fails with message: 
      // Parse Error (L1:C46): Expected final dot (.)
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 205:7   _NTriplesDecoderSink._parseTripleLine
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 163:22  _NTriplesDecoderSink._processLine
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 93:7    _NTriplesDecoderSink.close
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 35:20   NTriplesDecoder.convert
      // dart:convert                                                      Codec.decode
      // test/codec/ntriples/ntriples_codec_test.dart 782:39               main.<fn>.<fn>.<fn>
      test('Tests canonicalization of literals with double quote', (){
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

      // FIXME: Test currently fails with the following message:
      // Expected: '<http://a.example/s> <http://a.example/p> "\f" .'
      // Actual: '<http://a.example/s> <http://a.example/p> "\\u000C" .\n'
      //      ''
      // Which: is different.
      //    Expected: ... mple/p> "\f" .
      //      Actual: ... mple/p> "\\u000C" .\ ...
      //                            ^
      //     Differ at offset 45
      //
      // package:matcher                                     expect
      // test/codec/ntriples/ntriples_codec_test.dart 858:9  main.<fn>.<fn>.<fn>
      test('Tests canonicalization of literals with form feed', (){
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

      test('Tests canonicalization of literals with line feed', (){
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

      test('Tests canonicalization of literals with numeric escapes', (){
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

      test('Tests canonicalization of literals with numeric escapes 4', (){
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

      test('Tests canonicalization of literals with numeric escapes 8', (){
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

      test('Tests canonicalization of literals with reverse solidus', (){
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

      test('Tests canonicalization of literals with reverse solidus 2', (){
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

      test('Tests canonicalization of literals with single quotes', (){
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

      test('Tests canonicalization of literal with explicit xsd:string', (){
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

      test('Tests canonicalization of literals with UTF8 boundaries', (){
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

      test('Tests canonicalization of triples without optional whitespace', (){
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

      test('Tests canonicalization of triples without optional whitespace 2', (){
        final input = '''
<http://example/s><http://example/p>"Alice".
''';
        final expectedOutput = '''
<http://example/s> <http://example/p> "Alice" .
''';

        final decoded = nTriplesCodec.decode(input);
        final reencoded = nTriplesCodec.encode(decoded);

        expect(reencoded, equals(expectedOutput));
      });

      test('Tests canonicalization of triples with extra whitespace', (){
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

      test('Tests canonicalization of triples with extra whitespace 2', (){
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

      // FIXME: Test fails with the following message:
      // Parse Error (L1:C49): Expected final dot (.)
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 205:7   _NTriplesDecoderSink._parseTripleLine
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 163:22  _NTriplesDecoderSink._processLine
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 134:7   _NTriplesDecoderSink._processBuffer
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 80:5    _NTriplesDecoderSink.add
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 32:20   NTriplesDecoder.convert
      // dart:convert                                                      Codec.decode
      // test/codec/ntriples/ntriples_codec_test.dart 1060:39              main.<fn>.<fn>.<fn>
      test('Tests canonicalization of triples with extra whitespace 3', (){
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

      // FIXME: Test fails with the following message:
      // Parse Error (L1:C46): Expected final dot (.)
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 205:7   _NTriplesDecoderSink._parseTripleLine
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 163:22  _NTriplesDecoderSink._processLine
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 134:7   _NTriplesDecoderSink._processBuffer
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 80:5    _NTriplesDecoderSink.add
      // package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart 32:20   NTriplesDecoder.convert
      // dart:convert                                                      Codec.decode
      // test/codec/ntriples/ntriples_codec_test.dart 1083:39              main.<fn>.<fn>.<fn>
      test('Tests canonicalization of triples with extra whitespace 4', (){
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

      test('Tests canonicalization of IRIs', (){
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

      test('Tests canonicalization of IRIs #2', (){
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

      test('Tests canonicalization of IRIs #3', (){
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
      // test/codec/ntriples/ntriples_codec_test.dart 1158:9  main.<fn>.<fn>.<fn>
      test('Tests canonicalization of IRIs #4', (){
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

      test('Tests canonicalization of string escapes', (){
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

      test('Tests canonicalization of string escapes #2', (){
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

      test('Tests canonicalization of string escapes #3', (){
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
}
