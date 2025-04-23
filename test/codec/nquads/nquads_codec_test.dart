// Tests for N-Quads Codec

import 'dart:io';
import 'package:rdf_dart/src/blank_node.dart';
import 'package:rdf_dart/src/codec/n_formats/parse_error.dart';
import 'package:rdf_dart/src/codec/nquads/nquads_codec.dart';
import 'package:rdf_dart/src/dataset.dart';
import 'package:rdf_dart/src/iri.dart';
import 'package:rdf_dart/src/iri_term.dart';
import 'package:test/test.dart';

void main() {
  group('N-Quads 1.2 Conformance', () {
    group('Canonicalization', () {});
    group('Syntax', () {
      group('Positive', () {});

      group('Negative', () {});
    });
  });

  group('N-Quads 1.1 Conformance', () {
    group('Syntax', () {
      group('Positive', () {
        test('URI graph with URI triple', () async {
          // <http://example/s> <http://example/p> <http://example/o> <http://example/g> .
          final quads = await _loadTestFile('nq-syntax-uri-01.nq');
          final result = nQuadsCodec.decoder.convert(quads);
          final namedGraph = result.namedGraphs[IRITerm(IRI('http://example/g'))]!;
          final parsedTriple = namedGraph.triples.first;

          expect(result, isA<Dataset>());
          expect(result.defaultGraph.triples.length, equals(0));
          expect(namedGraph.triples.length, equals(1));
          expect(result.namedGraphs.length, equals(1));
          expect(parsedTriple.subject, equals(IRITerm(IRI('http://example/s'))));
          expect(parsedTriple.predicate, equals(IRITerm(IRI('http://example/p'))));
          expect(parsedTriple.object, equals(IRITerm(IRI('http://example/o'))));
        });

        test('URI graph with BNode subject', () async {
          // _:s <http://example/p> <http://example/o> <http://example/g> .
          final quads = await _loadTestFile('nq-syntax-uri-02.nq');
          final result = nQuadsCodec.decoder.convert(quads);
          final namedGraph = result.namedGraphs[IRITerm(IRI('http://example/g'))]!;
          final parsedTriple = namedGraph.triples.first;

          expect(result, isA<Dataset>());
          expect(result.defaultGraph.triples.length, equals(0));
          expect(namedGraph.triples.length, equals(1));
          expect(result.namedGraphs.length, equals(1));
          expect(parsedTriple.subject, equals(BlankNode('s')));
          expect(parsedTriple.predicate, equals(IRITerm(IRI('http://example/p'))));
          expect(parsedTriple.object, equals(IRITerm(IRI('http://example/o'))));
        });

        test('URI graph with BNode object', () async {
          // <http://example/s> <http://example/p> _:o <http://example/g> .
          final quads = await _loadTestFile('nq-syntax-uri-03.nq');
          final result = nQuadsCodec.decoder.convert(quads);
          final namedGraph = result.namedGraphs[IRITerm(IRI('http://example/g'))]!;
          final parsedTriple = namedGraph.triples.first;

          expect(result, isA<Dataset>());
          expect(result.defaultGraph.triples.length, equals(0));
          expect(namedGraph.triples.length, equals(1));
          expect(result.namedGraphs.length, equals(1));
          expect(parsedTriple.subject, equals(IRITerm(IRI('http://example/s'))));
          expect(parsedTriple.predicate, equals(IRITerm(IRI('http://example/p'))));
          expect(parsedTriple.object, equals(BlankNode('s')));
        });

        test('URI graph with simple literal', () async {
          final quads = await _loadTestFile('nq-syntax-uri-04.nq');
        });

        test('URI graph with language tagged literal', () async {
          final quads = await _loadTestFile('nq-syntax-uri-05.nq');
        });

        test('URI graph with datatyped literal', () async {
          final quads = await _loadTestFile('nq-syntax-uri-06.nq');
        });

        test('BNode graph with URI triple', () async {
          final quads = await _loadTestFile('nq-syntax-bnode-01.nq');
        });

        test('BNode graph with BNode subject', () async {
          final quads = await _loadTestFile('nq-syntax-bnode-02.nq');
        });

        test('BNode graph with BNode object', () async {
          final quads = await _loadTestFile('nq-syntax-bnode-03.nq');
        });

        test('BNode graph with simple literal', () async {
          final quads = await _loadTestFile('nq-syntax-bnode-04.nq');
        });

        test('BNode graph with language tagged literal', () async {
          final quads = await _loadTestFile('nq-syntax-bnode-05.nq');
        });

        test('BNode graph with datatyped literal', () async {
          final quads = await _loadTestFile('nq-syntax-bnode-06.nq');
        });

        test('Empty file', () async {
          final quads = await _loadTestFile('nt-syntax-file-01.nq');
        });

        test('Only comment', () async {
          final quads = await _loadTestFile('nt-syntax-file-02.nq');
        });

        test('One comment, one empty line', () async {
          final quads = await _loadTestFile('nt-syntax-file-03.nq');
        });

        test('Only IRIs', () async {
          final quads = await _loadTestFile('nt-syntax-uri-01.nq');
        });

        test('IRIs with Unicode escape', () async {
          final quads = await _loadTestFile('nt-syntax-uri-02.nq');
        });

        test('IRIs with long Unicode escape', () async {
          final quads = await _loadTestFile('nt-syntax-uri-03.nq');
        });

        test('Legal IRIs', () async {
          final quads = await _loadTestFile('nt-syntax-uri-04.nq');
        });

        test('string literal', () async {
          final quads = await _loadTestFile('nt-syntax-string-01.nq');
        });

        test('langString literal', () async {
          final quads = await _loadTestFile('nt-syntax-string-02.nq');
        });

        test('langString literal with region', () async {
          final quads = await _loadTestFile('nt-syntax-string-03.nq');
        });

        test('string literal with escaped newline', () async {
          final quads = await _loadTestFile('nt-syntax-str-esc-01.nq');
        });

        test('string literal with Unicode escape', () async {
          final quads = await _loadTestFile('nt-syntax-str-esc-02.nq');
        });

        test('string literal with long Unicode escape', () async {
          final quads = await _loadTestFile('nt-syntax-str-esc-03.nq');
        });

        test('bnode subject', () async {
          final quads = await _loadTestFile('nt-syntax-bnode-01.nq');
        });

        test('bnode object', () async {
          final quads = await _loadTestFile('nt-syntax-bnode-02.nq');
        });

        test('Blank node labels may start with a digit', () async {
          final quads = await _loadTestFile('nt-syntax-bnode-03.nq');
        });

        test('xsd:byte literal', () async {
          final quads = await _loadTestFile('nt-syntax-datatypes-01.nq');
        });

        test('integer as xsd:string', () async {
          final quads = await _loadTestFile('nt-syntax-datatypes-02.nq');
        });

        test('Submission test from Original RDF Test Cases', () async {
          final quads = await _loadTestFile('nt-syntax-subm-01.nq');
        });

        test('Tests comments after a triple', () async {
          final quads = await _loadTestFile('comment_following_triple.nq');
        });

        test('literal """x"""', () async {
          final quads = await _loadTestFile('literal.nq');
        });

        test(r'literal_all_controls \x00\x01\x02\x03\x04…', () async {
          final quads = await _loadTestFile('literal_all_controls.nq');
        });

        test(r'literal_all_punctuation !"#$%&()…', () async {
          final quads = await _loadTestFile('literal_all_punctuation.nq');
        });

        test(r'literal_ascii_boundaries \x00\x26\x28…', () async {
          final quads = await _loadTestFile('literal_ascii_boundaries.nq');
        });

        test('literal with 2 dquotes """a""b""""', () async {
          final quads = await _loadTestFile('literal_with_2_dquotes.nq');
        });

        test('literal with 2 squotes "x'
            'y"', () async {
          final quads = await _loadTestFile('literal_with_2_squotes.nq');
        });

        test('literal with BACKSPACE', () async {
          final quads = await _loadTestFile('literal_with_BACKSPACE.nq');
        });

        test('literal with CARRIAGE RETURN', () async {
          final quads = await _loadTestFile('literal_with_CARRIAGE_RETURN.nq');
        });

        test('literal with CHARACTER TABULATION', () async {
          final quads = await _loadTestFile(
            'literal_with_CHARACTER_TABULATION.nq',
          );
        });

        test('literal with dquote "x"y"', () async {
          final quads = await _loadTestFile('literal_with_dquote.nq');
        });

        test('literal with FORM FEED', () async {
          final quads = await _loadTestFile('literal_with_FORM_FEED.nq');
        });

        test('literal with LINE FEED', () async {
          final quads = await _loadTestFile('literal_with_LINE_FEED.nq');
        });

        test(r'literal with numeric escape4 \u', () async {
          final quads = await _loadTestFile('literal_with_numeric_escape4.nq');
        });

        test(r'literal with numeric escape8 \U', () async {
          final quads = await _loadTestFile('literal_with_numeric_escape8.nq');
        });

        test('literal with REVERSE SOLIDUS', () async {
          final quads = await _loadTestFile('literal_with_REVERSE_SOLIDUS.nq');
        });

        test('REVERSE SOLIDUS at end of literal', () async {
          final quads = await _loadTestFile('literal_with_REVERSE_SOLIDUS.nq');
        });

        test('literal with squote "x\'y"', () async {
          final quads = await _loadTestFile('literal_with_squote.nq');
        });

        test(r"literal_with_UTF8_boundaries '\x80\x7ff\x800\xfff…'", () async {
          final quads = await _loadTestFile('literal_with_UTF8_boundaries.nq');
        });

        test('langtagged string "x"@en', () async {
          final quads = await _loadTestFile('langtagged_string.nq');
        });

        test('lantag with subtag "x"@en-us', () async {
          final quads = await _loadTestFile('lantag_with_subtag.nq');
        });

        test('tests absense of whitespace between subject, predicate, object and end-of-statement', () async {
          final quads = await _loadTestFile('minimal_whitespace.nq');
        });
      });

      group('Negative', () {
        test('Graph name may not be a simple literal', () async {
          final quads = await _loadTestFile('nq-syntax-bad-literal-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Graph name may not be a language tagged literal', () async {
          final quads = await _loadTestFile('nq-syntax-bad-literal-02.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Graph name may not be a datatyped literal', () async {
          final quads = await _loadTestFile('nq-syntax-bad-literal-03.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Graph name URI must be absolute', () async {
          final quads = await _loadTestFile('nq-syntax-bad-uri-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('N-Quads does not have a fifth element', () async {
          final quads = await _loadTestFile('nq-syntax-bad-quint-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('N-Quads does not have a fifth element', () async {
          final quads = await _loadTestFile('nq-syntax-bad-quint-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad IRI : space', () async {
          final quads = await _loadTestFile('nt-syntax-bad-uri-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad IRI : bad escape', () async {
          final quads = await _loadTestFile('nt-syntax-bad-uri-02.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad IRI : bad long escape', () async {
          final quads = await _loadTestFile('nt-syntax-bad-uri-03.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad IRI : character escapes not allowed', () async {
          final quads = await _loadTestFile('nt-syntax-bad-uri-04.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad IRI : character escapes not allowed (2)', () async {
          final quads = await _loadTestFile('nt-syntax-bad-uri-05.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad IRI : relative IRI not allowed in subject', () async {
          final quads = await _loadTestFile('nt-syntax-bad-uri-06.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad IRI : relative IRI not allowed in predicate', () async {
          final quads = await _loadTestFile('nt-syntax-bad-uri-07.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad IRI : relative IRI not allowed in object', () async {
          final quads = await _loadTestFile('nt-syntax-bad-uri-08.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad IRI : relative IRI not allowed in datatype', () async {
          final quads = await _loadTestFile('nt-syntax-bad-uri-09.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('@prefix not allowed in N-Quads', () async {
          final quads = await _loadTestFile('nt-syntax-bad-prefix-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('@base not allowed in N-Quads', () async {
          final quads = await _loadTestFile('nt-syntax-bad-base-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Colon in bnode label not allowed', () async {
          final quads = await _loadTestFile('nt-syntax-bad-bnode-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Colon in bnode label not allowed (2)', () async {
          final quads = await _loadTestFile('nt-syntax-bad-bnode-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('N-Quads does not have objectList', () async {
          final quads = await _loadTestFile('nt-syntax-bad-struct-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('N-Quads does not have predicateObjectList', () async {
          final quads = await _loadTestFile('nt-syntax-bad-struct-02.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('langString with bad lang', () async {
          final quads = await _loadTestFile('nt-syntax-bad-lang-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad string escape', () async {
          final quads = await _loadTestFile('nt-syntax-bad-esc-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad string escape (2)', () async {
          final quads = await _loadTestFile('nt-syntax-bad-esc-02.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('Bad string escape (3)', () async {
          final quads = await _loadTestFile('nt-syntax-bad-esc-03.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('mismatching string literal open/close', () async {
          final quads = await _loadTestFile('nt-syntax-bad-string-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('mismatching string literal open/close (2)', () async {
          final quads = await _loadTestFile('nt-syntax-bad-string-02.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('single quotes', () async {
          final quads = await _loadTestFile('nt-syntax-bad-string-03.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('long single string literal', () async {
          final quads = await _loadTestFile('nt-syntax-bad-string-04.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('long double string literal', () async {
          final quads = await _loadTestFile('nt-syntax-bad-string-05.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('string literal with no end', () async {
          final quads = await _loadTestFile('nt-syntax-bad-string-06.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('string literal with no start', () async {
          final quads = await _loadTestFile('nt-syntax-bad-string-07.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('no numbers in N-Quads (integer)', () async {
          final quads = await _loadTestFile('nt-syntax-bad-num-01.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('no numbers in N-Quads (decimal)', () async {
          final quads = await _loadTestFile('nt-syntax-bad-num-02.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });

        test('no numbers in N-Quads (float)', () async {
          final quads = await _loadTestFile('nt-syntax-bad-num-03.nq');
          expect(
            () => nQuadsCodec.decode(quads),
            throwsA(isA<ParseError>()),
          );
        });
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
