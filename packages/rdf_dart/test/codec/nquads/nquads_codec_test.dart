// Tests for N-Quads Codec

import 'dart:io';

import 'package:iri/iri.dart';
import 'package:rdf_dart/src/codec/n_formats/parse_error.dart';
import 'package:rdf_dart/src/codec/nquads/nquads_codec.dart';
import 'package:rdf_dart/src/data_types.dart' show DatatypeRegistry;
import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/dataset.dart';
import 'package:rdf_dart/src/model/graph.dart';
import 'package:rdf_dart/src/model/iri_node.dart';
import 'package:rdf_dart/src/model/literal.dart';
import 'package:rdf_dart/src/model/triple.dart';
import 'package:rdf_dart/src/model/triple_term.dart';
import 'package:rdf_dart/src/vocab/rdf_vocab.dart';
import 'package:rdf_dart/src/vocab/xsd_vocab.dart';
import 'package:test/test.dart';

void main() {
  group('N-Quads 1.2 Conformance', () {
    group('Canonicalization', () {});

    group('Decoding', () {
      group('Syntax', () {
        group('Positive', () {
          test('Object Triple Term', () async {
            // <http://example/x> <http://example/p> <<( <http://example/s> <http://example/p> <http://example/o> )>> <http://example/g> .
            final quads = await _loadTestFile('nquads-star-syntax-2.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph =
                result.namedGraphs[IRINode(IRI('http://example/g'))]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/x'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(
                TripleTerm(
                  Triple(
                    IRINode(IRI('http://example/s')),
                    IRINode(IRI('http://example/p')),
                    IRINode(IRI('http://example/o')),
                  ),
                ),
              ),
            );
          });
        });

        group('Negative', () {
          test('Subject Triple Term', () async {
            // <<( <http://example/s> <http://example/p> <http://example/o> )>> <http://example/q> <http://example/z> <http://example/g> .
            final quads = await _loadTestFile('nquads-star-syntax-1.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Subject and Object Triple Term', () async {
            // <<( <http://example/s1> <http://example/p1> <http://example/o1> )>> <http://example/q> <<( <http://example/s2> <http://example/p2> <http://example/o2> )>> <http://example/g> .
            final quads = await _loadTestFile('nquads-star-syntax-3.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Subject and Object Triple Term without spaces', () async {
            // <<(<http://example/s1><http://example/p1><http://example/o1>)>><http://example/q><<(<http://example/s2><http://example/p2><http://example/o2>)>><http://example/g>.
            final quads = await _loadTestFile('nquads-star-syntax-4.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Nested Subject Triple Term ', () async {
            // <<(<<(<http://example/s1><http://example/p1><http://example/o1>)>><http://example/q1><<(<http://example/s2><http://example/p2><http://example/o2>)>>)>><http://example/q2><<(<<(<http://example/s3><http://example/p3><http://example/o3>)>><http://example/q3><<(<http://example/s4><http://example/p4><http://example/o4>)>>)>><http://example/g>.
            final quads = await _loadTestFile('nquads-star-syntax-5.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Triple Term with a Blank Node in Subject Position ', () async {
            // _:b0 <http://example/p> <http://example/o> .
            // <<( _:b0 <http://example/p> <http://example/o> )>> <http://example/q> "ABC" <http://example/g> .
            final quads = await _loadTestFile('nquads-star-bnode-1.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });
        });
      });
    });
  });

  group('N-Quads 1.1 Conformance', () {
    group('Decoding', () {
      group('Syntax', () {
        group('Positive', () {
          test('URI graph with URI triple', () async {
            // <http://example/s> <http://example/p> <http://example/o> <http://example/g> .
            final quads = await _loadTestFile('nq-syntax-uri-01.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph =
                result.namedGraphs[IRINode(IRI('http://example/g'))]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(IRINode(IRI('http://example/o'))),
            );
          });

          test('URI graph with BNode subject', () async {
            // _:s <http://example/p> <http://example/o> <http://example/g> .
            final quads = await _loadTestFile('nq-syntax-uri-02.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph =
                result.namedGraphs[IRINode(IRI('http://example/g'))]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(parsedTriple.subject, equals(BlankNode('s')));
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(IRINode(IRI('http://example/o'))),
            );
          });

          test('URI graph with BNode object', () async {
            // <http://example/s> <http://example/p> _:o <http://example/g> .
            final quads = await _loadTestFile('nq-syntax-uri-03.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph =
                result.namedGraphs[IRINode(IRI('http://example/g'))]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(BlankNode('o')));
          });

          test('URI graph with simple literal', () async {
            // <http://example/s> <http://example/p> "o" <http://example/g> .
            final quads = await _loadTestFile('nq-syntax-uri-04.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph =
                result.namedGraphs[IRINode(IRI('http://example/g'))]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('o', XSD.string)));
          });

          test('URI graph with language tagged literal', () async {
            // <http://example/s> <http://example/p> "o"@en <http://example/g> .
            final quads = await _loadTestFile('nq-syntax-uri-05.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph =
                result.namedGraphs[IRINode(IRI('http://example/g'))]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(Literal('o', RDF.langString, 'en')),
            );
          });

          test('URI graph with datatyped literal', () async {
            // <http://example/s> <http://example/p> "o"^^<http://www.w3.org/2001/XMLSchema#string> <http://example/g> .
            final quads = await _loadTestFile('nq-syntax-uri-06.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph =
                result.namedGraphs[IRINode(IRI('http://example/g'))]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('o', XSD.string)));
          });

          test('BNode graph with URI triple', () async {
            // <http://example/s> <http://example/p> <http://example/o> _:g .
            final quads = await _loadTestFile('nq-syntax-bnode-01.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph = result.namedGraphs[BlankNode('g')]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(IRINode(IRI('http://example/o'))),
            );
          });

          test('BNode graph with BNode subject', () async {
            // _:s <http://example/p> <http://example/o> _:g .
            final quads = await _loadTestFile('nq-syntax-bnode-02.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph = result.namedGraphs[BlankNode('g')]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(parsedTriple.subject, equals(BlankNode('s')));
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(IRINode(IRI('http://example/o'))),
            );
          });

          test('BNode graph with BNode object', () async {
            // <http://example/s> <http://example/p> _:o _:g .
            final quads = await _loadTestFile('nq-syntax-bnode-03.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph = result.namedGraphs[BlankNode('g')]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(BlankNode('o')));
          });

          test('BNode graph with simple literal', () async {
            // <http://example/s> <http://example/p> "o" _:g .
            final quads = await _loadTestFile('nq-syntax-bnode-04.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph = result.namedGraphs[BlankNode('g')]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('o', XSD.string)));
          });

          test('BNode graph with language tagged literal', () async {
            // <http://example/s> <http://example/p> "o"@en _:g .
            final quads = await _loadTestFile('nq-syntax-bnode-05.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph = result.namedGraphs[BlankNode('g')]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(Literal('o', RDF.langString, 'en')),
            );
          });

          test('BNode graph with datatyped literal', () async {
            // <http://example/s> <http://example/p> "o"^^<http://www.w3.org/2001/XMLSchema#string> _:g .
            final quads = await _loadTestFile('nq-syntax-bnode-06.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final namedGraph = result.namedGraphs[BlankNode('g')]!;
            final parsedTriple = namedGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(namedGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(1));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('o', XSD.string)));
          });

          test('Empty file', () async {
            //
            final quads = await _loadTestFile('nt-syntax-file-01.nq');
            final result = nQuadsCodec.decoder.convert(quads);

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(result.namedGraphs.length, equals(0));
          });

          test('Only comment', () async {
            // #Empty file.
            final quads = await _loadTestFile('nt-syntax-file-02.nq');
            final result = nQuadsCodec.decoder.convert(quads);

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(result.namedGraphs.length, equals(0));
          });

          test('One comment, one empty line', () async {
            // #One comment, one empty line.
            //
            final quads = await _loadTestFile('nt-syntax-file-03.nq');
            final result = nQuadsCodec.decoder.convert(quads);

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(0));
            expect(result.namedGraphs.length, equals(0));
          });

          test('Only IRIs', () async {
            // <http://example/s> <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-uri-01.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(IRINode(IRI('http://example/o'))),
            );
          });

          test('IRIs with Unicode escape', () async {
            // # x53 is capital S
            // <http://example/\u0053> <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-uri-02.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/S'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(IRINode(IRI('http://example/o'))),
            );
          });

          test('IRIs with long Unicode escape', () async {
            // # x53 is capital S
            // <http://example/\U00000053> <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-uri-03.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/S'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(IRINode(IRI('http://example/o'))),
            );
          });

          test('Legal IRIs', () async {
            // # IRI with all chars in it.
            // <http://example/s> <http://example/p> <scheme:!$%25&'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#> .

            final quads = await _loadTestFile('nt-syntax-uri-04.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(
                IRINode(
                  IRI(
                    r"scheme:!$%25&'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#",
                  ),
                ),
              ),
            );
          });

          test('string literal', () async {
            // <http://example/s> <http://example/p> "string" .
            final quads = await _loadTestFile('nt-syntax-string-01.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('string', XSD.string)));
          });

          test('langString literal', () async {
            // <http://example/s> <http://example/p> "string"@en .
            final quads = await _loadTestFile('nt-syntax-string-02.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(Literal('string', RDF.langString, 'en')),
            );
          });

          test('langString literal with region', () async {
            // <http://example/s> <http://example/p> "string"@en-uk .
            final quads = await _loadTestFile('nt-syntax-string-03.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(Literal('string', RDF.langString, 'en-uk')),
            );
          });

          test('string literal with escaped newline', () async {
            // <http://example/s> <http://example/p> "a\n" .
            final quads = await _loadTestFile('nt-syntax-str-esc-01.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('a\n', XSD.string)));
          });

          test('string literal with Unicode escape', () async {
            // <http://example/s> <http://example/p> "a\u0020b" .
            final quads = await _loadTestFile('nt-syntax-str-esc-02.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('a b', XSD.string)));
          });

          test('string literal with long Unicode escape', () async {
            // <http://example/s> <http://example/p> "a\U00000020b" .
            final quads = await _loadTestFile('nt-syntax-str-esc-03.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('a b', XSD.string)));
          });

          test('bnode subject', () async {
            // _:a  <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bnode-01.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(parsedTriple.subject, equals(BlankNode('a')));
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(IRINode(IRI('http://example/o'))),
            );
          });

          test('bnode object', () async {
            // <http://example/s> <http://example/p> _:a .
            // _:a  <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bnode-02.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final firstTriple = result.defaultGraph.triples.first;
            final secondTriple = result.defaultGraph.triples.last;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(2));
            expect(result.namedGraphs.length, equals(0));
            expect(
              firstTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              firstTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(firstTriple.object, equals(BlankNode('a')));
            expect(secondTriple.subject, equals(BlankNode('a')));
            expect(
              secondTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              secondTriple.object,
              equals(IRINode(IRI('http://example/o'))),
            );
          });

          test('Blank node labels may start with a digit', () async {
            // <http://example/s> <http://example/p> _:1a .
            // _:1a  <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bnode-03.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final firstTriple = result.defaultGraph.triples.first;
            final secondTriple = result.defaultGraph.triples.last;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(2));
            expect(result.namedGraphs.length, equals(0));
            expect(
              firstTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              firstTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(firstTriple.object, equals(BlankNode('1a')));
            expect(secondTriple.subject, equals(BlankNode('1a')));
            expect(
              secondTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(
              secondTriple.object,
              equals(IRINode(IRI('http://example/o'))),
            );
          });

          test('xsd:byte literal', () async {
            // <http://example/s> <http://example/p> "123"^^<http://www.w3.org/2001/XMLSchema#byte> .
            final quads = await _loadTestFile('nt-syntax-datatypes-01.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('123', XSD.byte)));
          });

          test('integer as xsd:string', () async {
            // <http://example/s> <http://example/p> "123"^^<http://www.w3.org/2001/XMLSchema#string> .
            final quads = await _loadTestFile('nt-syntax-datatypes-02.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('123', XSD.string)));
          });

          test('Submission test from Original RDF Test Cases', () async {
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
            final quads = await _loadTestFile('nt-syntax-subm-01.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(30));
          });

          test('Tests comments after a triple', () async {
            DatatypeRegistry().registerDatatype(
              IRI('http://example/dt'),
              String,
              (String lexicalForm) => lexicalForm,
              (Object value) => value.toString(),
            );
            // <http://example/s> <http://example/p> <http://example/o> . # comment
            // <http://example/s> <http://example/p> _:o . # comment
            // <http://example/s> <http://example/p> "o" . # comment
            // <http://example/s> <http://example/p> "o"^^<http://example/dt> . # comment
            // <http://example/s> <http://example/p> "o"@en . # comment
            final quads = await _loadTestFile('comment_following_triple.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(5));
          });

          test('literal """x"""', () async {
            // <http://a.example/s> <http://a.example/p> "x" .
            final quads = await _loadTestFile('literal.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('x', XSD.string)));
          });

          test(r'literal_all_controls \x00\x01\x02\x03\x04…', () async {
            // <http://a.example/s> <http://a.example/p> "\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u0008\t\u000B\u000C\u000E\u000F\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001A\u001B\u001C\u001D\u001E\u001F" .
            final quads = await _loadTestFile('literal_all_controls.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(
                Literal(
                  '\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u0008\t\u000B\u000C\u000E\u000F\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001A\u001B\u001C\u001D\u001E\u001F',
                  XSD.string,
                ),
              ),
            );
          });

          test(r'literal_all_punctuation !"#$%&()…', () async {
            // <http://a.example/s> <http://a.example/p> " !\"#$%&():;<=>?@[]^_`{|}~" .
            final quads = await _loadTestFile('literal_all_punctuation.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(Literal(r' !"#$%&():;<=>?@[]^_`{|}~', XSD.string)),
            );
          });

          test(r'literal_ascii_boundaries \x00\x26\x28…', () async {
            // <http://a.example/s> <http://a.example/p> " 	&([]" .
            final quads = await _loadTestFile('literal_ascii_boundaries.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(Literal(' 	&([]', XSD.string)),
            );
          });

          test('literal with 2 dquotes """a""b""""', () async {
            // <http://a.example/s> <http://a.example/p> "x\"\"y" .
            final quads = await _loadTestFile('literal_with_2_dquotes.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('x""y', XSD.string)));
          });

          test('literal with 2 squotes "x'
              'y"', () async {
            // <http://a.example/s> <http://a.example/p> "x''y" .
            final quads = await _loadTestFile('literal_with_2_squotes.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal("x''y", XSD.string)));
          });

          test('literal with BACKSPACE', () async {
            // <http://a.example/s> <http://a.example/p> "\b" .
            final quads = await _loadTestFile('literal_with_BACKSPACE.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('\b', XSD.string)));
          });

          test('literal with CARRIAGE RETURN', () async {
            // <http://a.example/s> <http://a.example/p> "\r" .
            final quads = await _loadTestFile(
              'literal_with_CARRIAGE_RETURN.nq',
            );
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('\r', XSD.string)));
          });

          test('literal with CHARACTER TABULATION', () async {
            // <http://a.example/s> <http://a.example/p> "\t" .
            final quads = await _loadTestFile(
              'literal_with_CHARACTER_TABULATION.nq',
            );
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('\t', XSD.string)));
          });

          test('literal with dquote "x"y"', () async {
            // <http://a.example/s> <http://a.example/p> "x\"y" .
            final quads = await _loadTestFile('literal_with_dquote.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('x"y', XSD.string)));
          });

          test('literal with FORM FEED', () async {
            // <http://a.example/s> <http://a.example/p> "\f" .
            final quads = await _loadTestFile('literal_with_FORM_FEED.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('\f', XSD.string)));
          });

          test('literal with LINE FEED', () async {
            // <http://a.example/s> <http://a.example/p> "\n" .
            final quads = await _loadTestFile('literal_with_LINE_FEED.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('\n', XSD.string)));
          });

          test(r'literal with numeric escape4 \u', () async {
            // <http://a.example/s> <http://a.example/p> "\u006F" .
            final quads = await _loadTestFile(
              'literal_with_numeric_escape4.nq',
            );
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('\u006F', XSD.string)));
          });

          test(r'literal with numeric escape8 \U', () async {
            // <http://a.example/s> <http://a.example/p> "\U0000006F" .
            final quads = await _loadTestFile(
              'literal_with_numeric_escape8.nq',
            );
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal('\u006F', XSD.string)));
          });

          test('literal with REVERSE SOLIDUS', () async {
            // <http://a.example/s> <http://a.example/p> "\\" .
            final quads = await _loadTestFile(
              'literal_with_REVERSE_SOLIDUS.nq',
            );
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal(r'\', XSD.string)));
          });

          test('REVERSE SOLIDUS at end of literal', () async {
            // <http://example.org/ns#s> <http://example.org/ns#p1> "test-\\" .
            final quads = await _loadTestFile(
              'literal_with_REVERSE_SOLIDUS2.nq',
            );
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example.org/ns#s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example.org/ns#p1'))),
            );
            expect(parsedTriple.object, equals(Literal(r'test-\', XSD.string)));
          });

          test('literal with squote "x\'y"', () async {
            // <http://a.example/s> <http://a.example/p> "x'y" .
            final quads = await _loadTestFile('literal_with_squote.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(parsedTriple.object, equals(Literal("x'y", XSD.string)));
          });

          test(r"literal_with_UTF8_boundaries '\x80\x7ff\x800\xfff…'", () async {
            // <http://a.example/s> <http://a.example/p> "߿ࠀ࿿က쿿퀀퟿�𐀀𿿽񀀀󿿽􀀀􏿽" .
            final quads = await _loadTestFile(
              'literal_with_UTF8_boundaries.nq',
            );
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(Literal('߿ࠀ࿿က쿿퀀퟿�𐀀𿿽񀀀󿿽􀀀􏿽', XSD.string)),
            );
          });

          test('langtagged string "x"@en', () async {
            // <http://a.example/s> <http://a.example/p> "chat"@en .
            final quads = await _loadTestFile('langtagged_string.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://a.example/s'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://a.example/p'))),
            );
            expect(
              parsedTriple.object,
              equals(Literal('chat', RDF.langString, 'en')),
            );
          });

          test('lantag with subtag "x"@en-us', () async {
            // <http://example.org/ex#a> <http://example.org/ex#b> "Cheers"@en-UK .
            final quads = await _loadTestFile('lantag_with_subtag.nq');
            final result = nQuadsCodec.decoder.convert(quads);
            final parsedTriple = result.defaultGraph.triples.first;

            expect(result, isA<Dataset>());
            expect(result.defaultGraph.triples.length, equals(1));
            expect(result.namedGraphs.length, equals(0));
            expect(
              parsedTriple.subject,
              equals(IRINode(IRI('http://example.org/ex#a'))),
            );
            expect(
              parsedTriple.predicate,
              equals(IRINode(IRI('http://example.org/ex#b'))),
            );
            expect(
              parsedTriple.object,
              equals(Literal('Cheers', RDF.langString, 'en-uk')),
            );
          });

          test(
            'tests absense of whitespace between subject, predicate, object and end-of-statement',
            () async {
              // <http://example/s><http://example/p><http://example/o>.
              // <http://example/s><http://example/p>"Alice".
              // <http://example/s><http://example/p>_:o.
              // _:s<http://example/p><http://example/o>.
              // _:s<http://example/p>"Alice".
              // _:s<http://example/p>_:bnode1.
              final quads = await _loadTestFile('minimal_whitespace.nq');
              final result = nQuadsCodec.decoder.convert(quads);
              expect(result, isA<Dataset>());
              expect(result.defaultGraph.triples.length, equals(6));
            },
          );
        });

        group('Negative', () {
          test('Graph name may not be a simple literal', () async {
            // <http://example/s> <http://example/p> <http://example/o> "o" .
            final quads = await _loadTestFile('nq-syntax-bad-literal-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Graph name may not be a language tagged literal', () async {
            // <http://example/s> <http://example/p> <http://example/o> "o"@en .
            final quads = await _loadTestFile('nq-syntax-bad-literal-02.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Graph name may not be a datatyped literal', () async {
            // <http://example/s> <http://example/p> <http://example/o> "o"^^<http://www.w3.org/2001/XMLSchema#string> .
            final quads = await _loadTestFile('nq-syntax-bad-literal-03.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Graph name URI must be absolute', () async {
            // # No relative IRIs in N-Quads
            // <http://example/s> <http://example/p> <http://example/o> <g>.
            final quads = await _loadTestFile('nq-syntax-bad-uri-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('N-Quads does not have a fifth element', () async {
            // # N-Quads rejects a quint
            // <http://example/s> <http://example/p> <http://example/o> <http://example/g> <http://example/n> .
            final quads = await _loadTestFile('nq-syntax-bad-quint-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad IRI : space', () async {
            // # Bad IRI : space.
            // <http://example/ space> <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bad-uri-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad IRI : bad escape', () async {
            // # Bad IRI : bad escape
            // <http://example/\u00ZZ11> <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bad-uri-02.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad IRI : bad long escape', () async {
            // # Bad IRI : bad escape
            // <http://example/\U00ZZ1111> <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bad-uri-03.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad IRI : character escapes not allowed', () async {
            // # Bad IRI : character escapes not allowed.
            // <http://example/\n> <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bad-uri-04.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad IRI : character escapes not allowed (2)', () async {
            // # Bad IRI : character escapes not allowed.
            // <http://example/\/> <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bad-uri-05.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad IRI : relative IRI not allowed in subject', () async {
            // # No relative IRIs in N-Quads
            // <s> <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bad-uri-06.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad IRI : relative IRI not allowed in predicate', () async {
            // # No relative IRIs in N-Quads
            // <http://example/s> <p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bad-uri-07.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad IRI : relative IRI not allowed in object', () async {
            // # No relative IRIs in N-Quads
            // <http://example/s> <http://example/p> <o> .
            final quads = await _loadTestFile('nt-syntax-bad-uri-08.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad IRI : relative IRI not allowed in datatype', () async {
            // # No relative IRIs in N-Quads
            // <http://example/s> <http://example/p> "foo"^^<dt> .
            final quads = await _loadTestFile('nt-syntax-bad-uri-09.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('@prefix not allowed in N-Quads', () async {
            // @prefix : <http://example/> .
            final quads = await _loadTestFile('nt-syntax-bad-prefix-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('@base not allowed in N-Quads', () async {
            // @base <http://example/> .
            final quads = await _loadTestFile('nt-syntax-bad-base-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Colon in bnode label not allowed', () async {
            // _::a  <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bad-bnode-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Colon in bnode label not allowed (2)', () async {
            // _:abc:def  <http://example/p> <http://example/o> .
            final quads = await _loadTestFile('nt-syntax-bad-bnode-02.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('N-Quads does not have objectList', () async {
            // <http://example/s> <http://example/p> <http://example/o>, <http://example/o2> .
            final quads = await _loadTestFile('nt-syntax-bad-struct-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('N-Quads does not have predicateObjectList', () async {
            // <http://example/s> <http://example/p> <http://example/o>; <http://example/p2>, <http://example/o2> .
            final quads = await _loadTestFile('nt-syntax-bad-struct-02.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('langString with bad lang', () async {
            // # Bad lang tag
            // <http://example/s> <http://example/p> "string"@1 .
            final quads = await _loadTestFile('nt-syntax-bad-lang-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad string escape', () async {
            // # Bad string escape
            // <http://example/s> <http://example/p> "a\zb" .
            final quads = await _loadTestFile('nt-syntax-bad-esc-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad string escape (2)', () async {
            // # Bad string escape
            // <http://example/s> <http://example/p> "\uWXYZ" .
            final quads = await _loadTestFile('nt-syntax-bad-esc-02.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('Bad string escape (3)', () async {
            // # Bad string escape
            // <http://example/s> <http://example/p> "\U0000WXYZ" .
            final quads = await _loadTestFile('nt-syntax-bad-esc-03.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('mismatching string literal open/close', () async {
            // <http://example/s> <http://example/p> "abc' .
            final quads = await _loadTestFile('nt-syntax-bad-string-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('mismatching string literal open/close (2)', () async {
            final quads = await _loadTestFile('nt-syntax-bad-string-02.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('single quotes', () async {
            // <http://example/s> <http://example/p> 1.0e1 .
            final quads = await _loadTestFile('nt-syntax-bad-string-03.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('long single string literal', () async {
            // <http://example/s> <http://example/p> '''abc''' .
            final quads = await _loadTestFile('nt-syntax-bad-string-04.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('long double string literal', () async {
            // <http://example/s> <http://example/p> """abc""" .
            final quads = await _loadTestFile('nt-syntax-bad-string-05.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('string literal with no end', () async {
            // <http://example/s> <http://example/p> "abc .
            final quads = await _loadTestFile('nt-syntax-bad-string-06.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('string literal with no start', () async {
            // <http://example/s> <http://example/p> abc" .
            final quads = await _loadTestFile('nt-syntax-bad-string-07.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('no numbers in N-Quads (integer)', () async {
            // <http://example/s> <http://example/p> 1 .
            final quads = await _loadTestFile('nt-syntax-bad-num-01.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('no numbers in N-Quads (decimal)', () async {
            // <http://example/s> <http://example/p> 1.0 .
            final quads = await _loadTestFile('nt-syntax-bad-num-02.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });

          test('no numbers in N-Quads (float)', () async {
            // <http://example/s> <http://example/p> 1.0e0 .
            final quads = await _loadTestFile('nt-syntax-bad-num-03.nq');
            expect(() => nQuadsCodec.decode(quads), throwsA(isA<ParseError>()));
          });
        });
      });
    });

    group('Encoding', () {
      test('URI graph with URI triple', () {
        final expectedResult = '''
<http://example/s> <http://example/p> <http://example/o> <http://example/g> .
''';
        final dataset = Dataset();
        final graph = Graph();
        graph.add(
          Triple(
            IRINode(IRI('http://example/s')),
            IRINode(IRI('http://example/p')),
            IRINode(IRI('http://example/o')),
          ),
        );
        dataset.addNamedGraph(IRINode(IRI('http://example/g')), graph);
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });

      test('URI graph with BNode subject', () {
        final expectedResult = '''
_:s <http://example/p> <http://example/o> <http://example/g> .
''';
        final dataset = Dataset();
        final graph = Graph();
        graph.add(
          Triple(
            BlankNode('s'),
            IRINode(IRI('http://example/p')),
            IRINode(IRI('http://example/o')),
          ),
        );
        dataset.addNamedGraph(IRINode(IRI('http://example/g')), graph);
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });

      test('URI graph with BNode object', () {
        final expectedResult = '''
<http://example/s> <http://example/p> _:o <http://example/g> .
''';
        final dataset = Dataset();
        final graph = Graph();
        graph.add(
          Triple(
            IRINode(IRI('http://example/s')),
            IRINode(IRI('http://example/p')),
            BlankNode('o'),
          ),
        );
        dataset.addNamedGraph(IRINode(IRI('http://example/g')), graph);
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });

      test('URI graph with simple literal', () {
        final expectedResult = '''
<http://example/s> <http://example/p> "o" <http://example/g> .
''';
        final dataset = Dataset();
        final graph = Graph();
        graph.add(
          Triple(
            IRINode(IRI('http://example/s')),
            IRINode(IRI('http://example/p')),
            Literal('o', XSD.string),
          ),
        );
        dataset.addNamedGraph(IRINode(IRI('http://example/g')), graph);
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });

      test('URI graph with language tagged literal', () {
        final expectedResult = '''
<http://example/s> <http://example/p> "o"@en <http://example/g> .
''';
        final dataset = Dataset();
        final graph = Graph();
        graph.add(
          Triple(
            IRINode(IRI('http://example/s')),
            IRINode(IRI('http://example/p')),
            Literal('o', RDF.langString, 'en'),
          ),
        );
        dataset.addNamedGraph(IRINode(IRI('http://example/g')), graph);
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });

      test('BNode graph with URI triple', () {
        final expectedResult = '''
<http://example/s> <http://example/p> <http://example/o> _:g .
''';
        final dataset = Dataset();
        final graph = Graph();
        graph.add(
          Triple(
            IRINode(IRI('http://example/s')),
            IRINode(IRI('http://example/p')),
            IRINode(IRI('http://example/o')),
          ),
        );
        dataset.addNamedGraph(BlankNode('g'), graph);
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });

      test('BNode graph with BNode subject', () {
        final expectedResult = '''
_:s <http://example/p> <http://example/o> _:g .
''';
        final dataset = Dataset();
        final graph = Graph();
        graph.add(
          Triple(
            BlankNode('s'),
            IRINode(IRI('http://example/p')),
            IRINode(IRI('http://example/o')),
          ),
        );
        dataset.addNamedGraph(BlankNode('g'), graph);
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });

      test('BNode graph with BNode object', () {
        final expectedResult = '''
<http://example/s> <http://example/p> _:o _:g .
''';
        final dataset = Dataset();
        final graph = Graph();
        graph.add(
          Triple(
            IRINode(IRI('http://example/s')),
            IRINode(IRI('http://example/p')),
            BlankNode('o'),
          ),
        );
        dataset.addNamedGraph(BlankNode('g'), graph);
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });

      test('BNode graph with language tagged literal', () {
        final expectedResult = '''
<http://example/s> <http://example/p> "o"@en _:g .
''';
        final dataset = Dataset();
        final graph = Graph();
        graph.add(
          Triple(
            IRINode(IRI('http://example/s')),
            IRINode(IRI('http://example/p')),
            Literal('o', RDF.langString, 'en'),
          ),
        );
        dataset.addNamedGraph(BlankNode('g'), graph);
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });

      test('BNode graph with simple literal', () {
        //
        final expectedResult = '''
<http://example/s> <http://example/p> "o" _:g .
''';
        final dataset = Dataset();
        final graph = Graph();
        graph.add(
          Triple(
            IRINode(IRI('http://example/s')),
            IRINode(IRI('http://example/p')),
            Literal('o', XSD.string),
          ),
        );
        dataset.addNamedGraph(BlankNode('g'), graph);
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });

      test('Empty Dataset', () async {
        final expectedResult = await _loadTestFile('nt-syntax-file-01.nq');
        final dataset = Dataset();
        final encodedResult = nQuadsCodec.encoder.convert(dataset);

        expect(encodedResult, equals(expectedResult));
      });
    });
  });
}

/// Helper method that takes in a filename and loads the appropriate test file
/// and returns it as a String.
Future<String> _loadTestFile(String fileName) async {
  // Make sure we load only from the `test/codec/nquads/test_cases` path
  final bytes =
      await File('test/codec/nquads/test_cases/$fileName').readAsString();
  return bytes;
}
