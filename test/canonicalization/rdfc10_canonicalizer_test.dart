import 'dart:io';

import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/canonicalization/canonicalization_algorithm.dart';
import 'package:rdf_dart/src/canonicalization/canonicalizer.dart';
import 'package:test/test.dart';

void main() {
  group('RDF Dataset Canonicalization (RDFC-1.0) Test Suite', () {
    test('test001c: simple id', () async {
      final quads = await _loadTestFile('test001-in.nq');
      // Input File Contents (Blank File):
      //
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents (Blank File):
      //
      final expectedQuads = await _loadTestFile('test001-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test002c: duplicate property iri values', () async {
      // Input File Contents:
      // <http://example.org/test#example1> <http://example.org/vocab#p> <http://example.org/test#example2> .
      final quads = await _loadTestFile('test002-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test#example1> <http://example.org/vocab#p> <http://example.org/test#example2> .
      final expectedQuads = await _loadTestFile('test002-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test003c: bnode', () async {
      // Input File Contents:
      // _:e0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Foo> .
      final quads = await _loadTestFile('test003-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Foo> .
      final expectedQuads = await _loadTestFile('test003-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test004c: bnode plus embed w/subject', () async {
      // Input File Contents:
      // _:e0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Foo> .
      // _:e0 <http://example.org/vocab#embed> <http://example.org/test#example> .
      final quads = await _loadTestFile('test004-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#embed> <http://example.org/test#example> .
      // _:c14n0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Foo> .
      final expectedQuads = await _loadTestFile('test004-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test005c: bnode embed', () async {
      // Input File Contents:
      // <http://example.org/test#example> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Foo> .
      // <http://example.org/test#example> <http://example.org/vocab#embed> _:e0 .
      // _:e0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Bar> .

      final quads = await _loadTestFile('test005-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test#example> <http://example.org/vocab#embed> _:c14n0 .
      // <http://example.org/test#example> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Foo> .
      // _:c14n0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Bar> .

      final expectedQuads = await _loadTestFile('test005-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test006c: multiple rdf types', () async {
      // Input File Contents:
      // <http://example.org/test#example> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Foo> .
      // <http://example.org/test#example> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Bar> .
      final quads = await _loadTestFile('test006-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test#example> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Bar> .
      // <http://example.org/test#example> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/vocab#Foo> .
      final expectedQuads = await _loadTestFile('test006-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test008c: single subject complex', () async {
      // Input File Contents:
      // <http://example.org/test#library> <http://example.org/vocab#contains> <http://example.org/test#book> .
      // <http://example.org/test#book> <http://example.org/vocab#contains> <http://example.org/test#chapter> .
      // <http://example.org/test#book> <http://purl.org/dc/elements/1.1/contributor> "Writer" .
      // <http://example.org/test#book> <http://purl.org/dc/elements/1.1/title> "My Book" .
      // <http://example.org/test#chapter> <http://purl.org/dc/elements/1.1/description> "Fun" .
      // <http://example.org/test#chapter> <http://purl.org/dc/elements/1.1/title> "Chapter One" .
      final quads = await _loadTestFile('test008-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test#book> <http://example.org/vocab#contains> <http://example.org/test#chapter> .
      // <http://example.org/test#book> <http://purl.org/dc/elements/1.1/contributor> "Writer" .
      // <http://example.org/test#book> <http://purl.org/dc/elements/1.1/title> "My Book" .
      // <http://example.org/test#chapter> <http://purl.org/dc/elements/1.1/description> "Fun" .
      // <http://example.org/test#chapter> <http://purl.org/dc/elements/1.1/title> "Chapter One" .
      // <http://example.org/test#library> <http://example.org/vocab#contains> <http://example.org/test#book> .
      final expectedQuads = await _loadTestFile('test008-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test009c: multiple subjects - complex', () async {
      // Input File Contents:
      // <http://example.org/test#chapter> <http://purl.org/dc/elements/1.1/description> "Fun" .
      // <http://example.org/test#chapter> <http://purl.org/dc/elements/1.1/title> "Chapter One" .
      // <http://example.org/test#jane> <http://example.org/vocab#authored> <http://example.org/test#chapter> .
      // <http://example.org/test#jane> <http://xmlns.com/foaf/0.1/name> "Jane" .
      // <http://example.org/test#john> <http://xmlns.com/foaf/0.1/name> "John" .
      // <http://example.org/test#library> <http://example.org/vocab#contains> <http://example.org/test#book> .
      // <http://example.org/test#book> <http://example.org/vocab#contains> <http://example.org/test#chapter> .
      // <http://example.org/test#book> <http://purl.org/dc/elements/1.1/contributor> "Writer" .
      // <http://example.org/test#book> <http://purl.org/dc/elements/1.1/title> "My Book" .
      final quads = await _loadTestFile('test009-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test#book> <http://example.org/vocab#contains> <http://example.org/test#chapter> .
      // <http://example.org/test#book> <http://purl.org/dc/elements/1.1/contributor> "Writer" .
      // <http://example.org/test#book> <http://purl.org/dc/elements/1.1/title> "My Book" .
      // <http://example.org/test#chapter> <http://purl.org/dc/elements/1.1/description> "Fun" .
      // <http://example.org/test#chapter> <http://purl.org/dc/elements/1.1/title> "Chapter One" .
      // <http://example.org/test#jane> <http://example.org/vocab#authored> <http://example.org/test#chapter> .
      // <http://example.org/test#jane> <http://xmlns.com/foaf/0.1/name> "Jane" .
      // <http://example.org/test#john> <http://xmlns.com/foaf/0.1/name> "John" .
      // <http://example.org/test#library> <http://example.org/vocab#contains> <http://example.org/test#book> .
      final expectedQuads = await _loadTestFile('test009-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test010c: type', () async {
      // Input File Contents:
      // <http://example.org/test#example> <http://example.org/vocab#validFrom> "2011-01-25T00:00:00+00:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
      final quads = await _loadTestFile('test010-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test#example> <http://example.org/vocab#validFrom> "2011-01-25T00:00:00+00:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
      final expectedQuads = await _loadTestFile('test010-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });
  });
}

/// Helper method that takes in a filename and loads the appropriate test file
/// and returns it as a String.
Future<String> _loadTestFile(String fileName) async {
  // Make sure we load only from the `test/canonicalization/test_cases` path
  final bytes =
      await File('test/canonicalization/test_cases/$fileName').readAsString();
  return bytes;
}
