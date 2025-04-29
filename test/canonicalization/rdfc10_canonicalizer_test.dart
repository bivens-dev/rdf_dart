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

    test('test011c: type-coerced type', () async {
      // Input File Contents:
      // <http://example.org/test#example> <http://example.org/vocab#validFrom> "2011-01-25T00:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
      final quads = await _loadTestFile('test011-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test#example> <http://example.org/vocab#validFrom> "2011-01-25T00:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
      final expectedQuads = await _loadTestFile('test011-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test013c: type-coerced type, cycle', () async {
      // Input File Contents:
      // <http://example.org/test#example1> <http://example.org/vocab#date> "2011-01-25T00:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
      // <http://example.org/test#example1> <http://example.org/vocab#embed> <http://example.org/test#example2> .
      // <http://example.org/test#example2> <http://example.org/vocab#parent> <http://example.org/test#example1> .
      final quads = await _loadTestFile('test013-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test#example1> <http://example.org/vocab#date> "2011-01-25T00:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
      // <http://example.org/test#example1> <http://example.org/vocab#embed> <http://example.org/test#example2> .
      // <http://example.org/test#example2> <http://example.org/vocab#parent> <http://example.org/test#example1> .
      final expectedQuads = await _loadTestFile('test013-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test014c: check types', () async {
      // Input File Contents:
      // <http://example.org/test> <http://example.org/vocab#bool> "true"^^<http://www.w3.org/2001/XMLSchema#boolean> .
      // <http://example.org/test> <http://example.org/vocab#double> "1.23E0"^^<http://www.w3.org/2001/XMLSchema#double> .
      // <http://example.org/test> <http://example.org/vocab#int> "123"^^<http://www.w3.org/2001/XMLSchema#integer> .
      final quads = await _loadTestFile('test014-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test> <http://example.org/vocab#bool> "true"^^<http://www.w3.org/2001/XMLSchema#boolean> .
      // <http://example.org/test> <http://example.org/vocab#double> "1.23E0"^^<http://www.w3.org/2001/XMLSchema#double> .
      // <http://example.org/test> <http://example.org/vocab#int> "123"^^<http://www.w3.org/2001/XMLSchema#integer> .
      final expectedQuads = await _loadTestFile('test014-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test016c: blank node - dual link - embed', () async {
      // Input File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:e0 .
      final quads = await _loadTestFile('test016-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:c14n0 .
      final expectedQuads = await _loadTestFile('test016-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test017c: blank node - dual link - non-embed', () async {
      // Input File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:e0 .
      final quads = await _loadTestFile('test017-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:c14n0 .
      final expectedQuads = await _loadTestFile('test017-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test018c: blank node - self link', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#self> _:e0 .
      final quads = await _loadTestFile('test018-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#self> _:c14n0 .
      final expectedQuads = await _loadTestFile('test018-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test019c: blank node - disjoint self links', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#self> _:e0 .
      // _:e1 <http://example.org/vocab#self> _:e1 .
      final quads = await _loadTestFile('test019-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#self> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#self> _:c14n1 .
      final expectedQuads = await _loadTestFile('test019-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test020c: blank node - diamond', () async {
      // Input File Contents:
      // <http://example.org/vocab#test> <http://example.org/vocab#A> _:e0 .
      // <http://example.org/vocab#test> <http://example.org/vocab#B> _:e1 .
      // _:e0 <http://example.org/vocab#next> _:e2 .
      // _:e1 <http://example.org/vocab#next> _:e2 .
      final quads = await _loadTestFile('test020-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/vocab#test> <http://example.org/vocab#A> _:c14n2 .
      // <http://example.org/vocab#test> <http://example.org/vocab#B> _:c14n0 .
      // _:c14n0 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      final expectedQuads = await _loadTestFile('test020-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test021c: blank node - circle of 2', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#next> _:e1 .
      // _:e1 <http://example.org/vocab#next> _:e0 .
      final quads = await _loadTestFile('test021-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      final expectedQuads = await _loadTestFile('test021-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test022c: blank node - double circle of 2', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#next> _:e1 .
      // _:e0 <http://example.org/vocab#prev> _:e1 .
      // _:e1 <http://example.org/vocab#next> _:e0 .
      // _:e1 <http://example.org/vocab#prev> _:e0 .
      final quads = await _loadTestFile('test022-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test022-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test023c: blank node - circle of 3', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#next> _:e1 .
      // _:e1 <http://example.org/vocab#next> _:e2 .
      // _:e2 <http://example.org/vocab#next> _:e0 .
      final quads = await _loadTestFile('test023-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n0 .
      final expectedQuads = await _loadTestFile('test023-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test024c: blank node - double circle of 3 (0-1-2)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#next> _:e1 .
      // _:e0 <http://example.org/vocab#prev> _:e2 .
      // _:e1 <http://example.org/vocab#next> _:e2 .
      // _:e1 <http://example.org/vocab#prev> _:e0 .
      // _:e2 <http://example.org/vocab#next> _:e0 .
      // _:e2 <http://example.org/vocab#prev> _:e1 .
      final quads = await _loadTestFile('test024-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test024-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test025c: blank node - double circle of 3 (0-2-1)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#next> _:e1 .
      // _:e0 <http://example.org/vocab#prev> _:e2 .
      // _:e2 <http://example.org/vocab#next> _:e0 .
      // _:e2 <http://example.org/vocab#prev> _:e1 .
      // _:e1 <http://example.org/vocab#next> _:e2 .
      // _:e1 <http://example.org/vocab#prev> _:e0 .
      final quads = await _loadTestFile('test025-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test025-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test026c: blank node - double circle of 3 (1-0-2)', () async {
      // Input File Contents:
      // _:e1 <http://example.org/vocab#next> _:e2 .
      // _:e1 <http://example.org/vocab#prev> _:e0 .
      // _:e0 <http://example.org/vocab#next> _:e1 .
      // _:e0 <http://example.org/vocab#prev> _:e2 .
      // _:e2 <http://example.org/vocab#next> _:e0 .
      // _:e2 <http://example.org/vocab#prev> _:e1 .
      final quads = await _loadTestFile('test026-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test026-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test027c: blank node - double circle of 3 (1-2-0)', () async {
      // Input File Contents:
      // _:e1 <http://example.org/vocab#next> _:e2 .
      // _:e1 <http://example.org/vocab#prev> _:e0 .
      // _:e2 <http://example.org/vocab#next> _:e0 .
      // _:e2 <http://example.org/vocab#prev> _:e1 .
      // _:e0 <http://example.org/vocab#next> _:e1 .
      // _:e0 <http://example.org/vocab#prev> _:e2 .
      final quads = await _loadTestFile('test027-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test027-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test028c: blank node - double circle of 3 (2-1-0)', () async {
      // Input File Contents:
      // _:e2 <http://example.org/vocab#next> _:e0 .
      // _:e2 <http://example.org/vocab#prev> _:e1 .
      // _:e1 <http://example.org/vocab#next> _:e2 .
      // _:e1 <http://example.org/vocab#prev> _:e0 .
      // _:e0 <http://example.org/vocab#next> _:e1 .
      // _:e0 <http://example.org/vocab#prev> _:e2 .
      final quads = await _loadTestFile('test028-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test028-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test029c: blank node - double circle of 3 (2-0-1)', () async {
      // Input File Contents:
      // _:e2 <http://example.org/vocab#next> _:e0 .
      // _:e2 <http://example.org/vocab#prev> _:e1 .
      // _:e0 <http://example.org/vocab#next> _:e1 .
      // _:e0 <http://example.org/vocab#prev> _:e2 .
      // _:e1 <http://example.org/vocab#next> _:e2 .
      // _:e1 <http://example.org/vocab#prev> _:e0 .
      final quads = await _loadTestFile('test029-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test029-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test030c: blank node - point at circle of 3', () async {
      // Input File Contents:
      // <http://example.org/vocab#test> <http://example.org/vocab#A> _:e0 .
      // <http://example.org/vocab#test> <http://example.org/vocab#B> _:e1 .
      // <http://example.org/vocab#test> <http://example.org/vocab#C> _:e2 .
      // _:e0 <http://example.org/vocab#next> _:e1 .
      // _:e1 <http://example.org/vocab#next> _:e2 .
      // _:e2 <http://example.org/vocab#next> _:e0 .
      final quads = await _loadTestFile('test030-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/vocab#test> <http://example.org/vocab#A> _:c14n0 .
      // <http://example.org/vocab#test> <http://example.org/vocab#B> _:c14n1 .
      // <http://example.org/vocab#test> <http://example.org/vocab#C> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n0 .
      final expectedQuads = await _loadTestFile('test030-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test033c: disjoint identical subgraphs (1)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#prop> _:e1 .
      // _:e2 <http://example.org/vocab#prop> _:e3 .
      final quads = await _loadTestFile('test033-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#prop> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prop> _:c14n3 .
      final expectedQuads = await _loadTestFile('test033-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test034c: disjoint identical subgraphs (2)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#prop> _:e1 .
      // _:e2 <http://example.org/vocab#prop> _:e3 .
      final quads = await _loadTestFile('test034-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#prop> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prop> _:c14n3 .
      final expectedQuads = await _loadTestFile('test034-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test034c: disjoint identical subgraphs (2)', () async {
      // Input File Contents:
      // _:e2 <http://example.org/vocab#prop> _:e3 .
      // _:e0 <http://example.org/vocab#prop> _:e1 .
      final quads = await _loadTestFile('test034-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#prop> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prop> _:c14n3 .
      final expectedQuads = await _loadTestFile('test034-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test035c: reordered w/strings (1)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p1> _:e2 .
      // _:e1 <http://example.org/vocab#p1> _:e3 .
      // _:e2 <http://example.org/vocab#p2> "Foo" .
      // _:e3 <http://example.org/vocab#p2> "Foo" .
      final quads = await _loadTestFile('test035-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p1> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#p2> "Foo" .
      // _:c14n2 <http://example.org/vocab#p1> _:c14n3 .
      // _:c14n3 <http://example.org/vocab#p2> "Foo" .
      final expectedQuads = await _loadTestFile('test035-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test036c: reordered w/strings (2)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p1> _:e3 .
      // _:e1 <http://example.org/vocab#p1> _:e2 .
      // _:e2 <http://example.org/vocab#p2> "Foo" .
      // _:e3 <http://example.org/vocab#p2> "Foo" .
      final quads = await _loadTestFile('test036-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p1> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#p2> "Foo" .
      // _:c14n2 <http://example.org/vocab#p1> _:c14n3 .
      // _:c14n3 <http://example.org/vocab#p2> "Foo" .
      final expectedQuads = await _loadTestFile('test036-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test038c: reordered 4 bnodes, reordered 2 properties (1)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p1> _:e1 .
      // _:e0 <http://example.org/vocab#p1> _:e2 .
      // _:e1 <http://example.org/vocab#p1> _:e3 .
      final quads = await _loadTestFile('test038-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p1> _:c14n2 .
      // _:c14n1 <http://example.org/vocab#p1> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#p1> _:c14n3 .
      final expectedQuads = await _loadTestFile('test038-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test039c: reordered 4 bnodes, reordered 2 properties (2)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p1> _:e1 .
      // _:e0 <http://example.org/vocab#p1> _:e2 .
      // _:e2 <http://example.org/vocab#p1> _:e3 .
      final quads = await _loadTestFile('test039-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p1> _:c14n2 .
      // _:c14n1 <http://example.org/vocab#p1> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#p1> _:c14n3 .
      final expectedQuads = await _loadTestFile('test039-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test040c: reordered 6 bnodes (1)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p1> _:e1 .
      // _:e1 <http://example.org/vocab#p1> _:e2 .
      // _:e3 <http://example.org/vocab#p1> _:e4 .
      // _:e4 <http://example.org/vocab#p1> _:e5 .
      final quads = await _loadTestFile('test040-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p1> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#p1> _:c14n2 .
      // _:c14n3 <http://example.org/vocab#p1> _:c14n4 .
      // _:c14n4 <http://example.org/vocab#p1> _:c14n5 .
      final expectedQuads = await _loadTestFile('test040-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test043c: literal with language', () async {
      // Input File Contents:
      // <http://example.org/test> <http://example.org/vocab#test> "test"@en .
      final quads = await _loadTestFile('test043-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test> <http://example.org/vocab#test> "test"@en .
      final expectedQuads = await _loadTestFile('test043-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    // A poison graph which is computable given defined limits.
    test('test044c: poison - evil (1)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p> _:e1 .
      // _:e0 <http://example.org/vocab#p> _:e2 .
      // _:e0 <http://example.org/vocab#p> _:e3 .
      // _:e1 <http://example.org/vocab#p> _:e0 .
      // _:e1 <http://example.org/vocab#p> _:e3 .
      // _:e1 <http://example.org/vocab#p> _:e4 .
      // _:e2 <http://example.org/vocab#p> _:e0 .
      // _:e2 <http://example.org/vocab#p> _:e4 .
      // _:e2 <http://example.org/vocab#p> _:e5 .
      // _:e3 <http://example.org/vocab#p> _:e0 .
      // _:e3 <http://example.org/vocab#p> _:e1 .
      // _:e3 <http://example.org/vocab#p> _:e5 .
      // _:e4 <http://example.org/vocab#p> _:e1 .
      // _:e4 <http://example.org/vocab#p> _:e2 .
      // _:e4 <http://example.org/vocab#p> _:e5 .
      // _:e5 <http://example.org/vocab#p> _:e3 .
      // _:e5 <http://example.org/vocab#p> _:e2 .
      // _:e5 <http://example.org/vocab#p> _:e4 .
      // _:e6 <http://example.org/vocab#p> _:e7 .
      // _:e6 <http://example.org/vocab#p> _:e8 .
      // _:e6 <http://example.org/vocab#p> _:e9 .
      // _:e7 <http://example.org/vocab#p> _:e6 .
      // _:e7 <http://example.org/vocab#p> _:e10 .
      // _:e7 <http://example.org/vocab#p> _:e11 .
      // _:e8 <http://example.org/vocab#p> _:e6 .
      // _:e8 <http://example.org/vocab#p> _:e10 .
      // _:e8 <http://example.org/vocab#p> _:e11 .
      // _:e9 <http://example.org/vocab#p> _:e6 .
      // _:e9 <http://example.org/vocab#p> _:e10 .
      // _:e9 <http://example.org/vocab#p> _:e11 .
      // _:e10 <http://example.org/vocab#p> _:e7 .
      // _:e10 <http://example.org/vocab#p> _:e8 .
      // _:e10 <http://example.org/vocab#p> _:e9 .
      // _:e11 <http://example.org/vocab#p> _:e7 .
      // _:e11 <http://example.org/vocab#p> _:e8 .
      // _:e11 <http://example.org/vocab#p> _:e9 .
      final quads = await _loadTestFile('test044-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n0 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#p> _:c14n3 .
      // _:c14n1 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#p> _:c14n4 .
      // _:c14n1 <http://example.org/vocab#p> _:c14n5 .
      // _:c14n10 <http://example.org/vocab#p> _:c14n7 .
      // _:c14n10 <http://example.org/vocab#p> _:c14n8 .
      // _:c14n10 <http://example.org/vocab#p> _:c14n9 .
      // _:c14n11 <http://example.org/vocab#p> _:c14n7 .
      // _:c14n11 <http://example.org/vocab#p> _:c14n8 .
      // _:c14n11 <http://example.org/vocab#p> _:c14n9 .
      // _:c14n2 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n2 <http://example.org/vocab#p> _:c14n3 .
      // _:c14n2 <http://example.org/vocab#p> _:c14n5 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n4 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n3 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n5 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n4 .
      // _:c14n6 <http://example.org/vocab#p> _:c14n7 .
      // _:c14n6 <http://example.org/vocab#p> _:c14n8 .
      // _:c14n6 <http://example.org/vocab#p> _:c14n9 .
      // _:c14n7 <http://example.org/vocab#p> _:c14n10 .
      // _:c14n7 <http://example.org/vocab#p> _:c14n11 .
      // _:c14n7 <http://example.org/vocab#p> _:c14n6 .
      // _:c14n8 <http://example.org/vocab#p> _:c14n10 .
      // _:c14n8 <http://example.org/vocab#p> _:c14n11 .
      // _:c14n8 <http://example.org/vocab#p> _:c14n6 .
      // _:c14n9 <http://example.org/vocab#p> _:c14n10 .
      // _:c14n9 <http://example.org/vocab#p> _:c14n11 .
      // _:c14n9 <http://example.org/vocab#p> _:c14n6 .
      final expectedQuads = await _loadTestFile('test044-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    // A poison graph which is computable given defined limits.
    test('test045c: poison - evil (2)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p> _:e1 .
      // _:e0 <http://example.org/vocab#p> _:e2 .
      // _:e0 <http://example.org/vocab#p> _:e3 .
      // _:e1 <http://example.org/vocab#p> _:e0 .
      // _:e1 <http://example.org/vocab#p> _:e4 .
      // _:e1 <http://example.org/vocab#p> _:e5 .
      // _:e2 <http://example.org/vocab#p> _:e0 .
      // _:e2 <http://example.org/vocab#p> _:e4 .
      // _:e2 <http://example.org/vocab#p> _:e5 .
      // _:e3 <http://example.org/vocab#p> _:e0 .
      // _:e3 <http://example.org/vocab#p> _:e4 .
      // _:e3 <http://example.org/vocab#p> _:e5 .
      // _:e4 <http://example.org/vocab#p> _:e1 .
      // _:e4 <http://example.org/vocab#p> _:e2 .
      // _:e4 <http://example.org/vocab#p> _:e3 .
      // _:e5 <http://example.org/vocab#p> _:e1 .
      // _:e5 <http://example.org/vocab#p> _:e2 .
      // _:e5 <http://example.org/vocab#p> _:e3 .
      // _:e6 <http://example.org/vocab#p> _:e7 .
      // _:e6 <http://example.org/vocab#p> _:e8 .
      // _:e6 <http://example.org/vocab#p> _:e9 .
      // _:e7 <http://example.org/vocab#p> _:e6 .
      // _:e7 <http://example.org/vocab#p> _:e9 .
      // _:e7 <http://example.org/vocab#p> _:e10 .
      // _:e8 <http://example.org/vocab#p> _:e6 .
      // _:e8 <http://example.org/vocab#p> _:e10 .
      // _:e8 <http://example.org/vocab#p> _:e11 .
      // _:e9 <http://example.org/vocab#p> _:e6 .
      // _:e9 <http://example.org/vocab#p> _:e7 .
      // _:e9 <http://example.org/vocab#p> _:e11 .
      // _:e10 <http://example.org/vocab#p> _:e7 .
      // _:e10 <http://example.org/vocab#p> _:e8 .
      // _:e10 <http://example.org/vocab#p> _:e11 .
      // _:e11 <http://example.org/vocab#p> _:e9 .
      // _:e11 <http://example.org/vocab#p> _:e8 .
      // _:e11 <http://example.org/vocab#p> _:e10 .
      final quads = await _loadTestFile('test045-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n0 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#p> _:c14n3 .
      // _:c14n1 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#p> _:c14n4 .
      // _:c14n1 <http://example.org/vocab#p> _:c14n5 .
      // _:c14n10 <http://example.org/vocab#p> _:c14n7 .
      // _:c14n10 <http://example.org/vocab#p> _:c14n8 .
      // _:c14n10 <http://example.org/vocab#p> _:c14n9 .
      // _:c14n11 <http://example.org/vocab#p> _:c14n7 .
      // _:c14n11 <http://example.org/vocab#p> _:c14n8 .
      // _:c14n11 <http://example.org/vocab#p> _:c14n9 .
      // _:c14n2 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n2 <http://example.org/vocab#p> _:c14n3 .
      // _:c14n2 <http://example.org/vocab#p> _:c14n5 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n4 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n3 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n5 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n4 .
      // _:c14n6 <http://example.org/vocab#p> _:c14n7 .
      // _:c14n6 <http://example.org/vocab#p> _:c14n8 .
      // _:c14n6 <http://example.org/vocab#p> _:c14n9 .
      // _:c14n7 <http://example.org/vocab#p> _:c14n10 .
      // _:c14n7 <http://example.org/vocab#p> _:c14n11 .
      // _:c14n7 <http://example.org/vocab#p> _:c14n6 .
      // _:c14n8 <http://example.org/vocab#p> _:c14n10 .
      // _:c14n8 <http://example.org/vocab#p> _:c14n11 .
      // _:c14n8 <http://example.org/vocab#p> _:c14n6 .
      // _:c14n9 <http://example.org/vocab#p> _:c14n10 .
      // _:c14n9 <http://example.org/vocab#p> _:c14n11 .
      // _:c14n9 <http://example.org/vocab#p> _:c14n6 .
      final expectedQuads = await _loadTestFile('test045-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    // A poison graph which is computable given defined limits.
    test('test046c: poison - evil (3)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p> _:e1 .
      // _:e0 <http://example.org/vocab#p> _:e2 .
      // _:e0 <http://example.org/vocab#p> _:e3 .
      // _:e1 <http://example.org/vocab#p> _:e0 .
      // _:e1 <http://example.org/vocab#p> _:e9 .
      // _:e1 <http://example.org/vocab#p> _:e8 .
      // _:e2 <http://example.org/vocab#p> _:e3 .
      // _:e2 <http://example.org/vocab#p> _:e8 .
      // _:e2 <http://example.org/vocab#p> _:e0 .
      // _:e3 <http://example.org/vocab#p> _:e0 .
      // _:e3 <http://example.org/vocab#p> _:e2 .
      // _:e3 <http://example.org/vocab#p> _:e9 .
      // _:e4 <http://example.org/vocab#p> _:e5 .
      // _:e4 <http://example.org/vocab#p> _:e6 .
      // _:e4 <http://example.org/vocab#p> _:e7 .
      // _:e5 <http://example.org/vocab#p> _:e10 .
      // _:e5 <http://example.org/vocab#p> _:e4 .
      // _:e5 <http://example.org/vocab#p> _:e11 .
      // _:e6 <http://example.org/vocab#p> _:e4 .
      // _:e6 <http://example.org/vocab#p> _:e11 .
      // _:e6 <http://example.org/vocab#p> _:e10 .
      // _:e7 <http://example.org/vocab#p> _:e10 .
      // _:e7 <http://example.org/vocab#p> _:e11 .
      // _:e7 <http://example.org/vocab#p> _:e4 .
      // _:e8 <http://example.org/vocab#p> _:e1 .
      // _:e8 <http://example.org/vocab#p> _:e2 .
      // _:e8 <http://example.org/vocab#p> _:e9 .
      // _:e9 <http://example.org/vocab#p> _:e8 .
      // _:e9 <http://example.org/vocab#p> _:e3 .
      // _:e9 <http://example.org/vocab#p> _:e1 .
      // _:e10 <http://example.org/vocab#p> _:e6 .
      // _:e10 <http://example.org/vocab#p> _:e7 .
      // _:e10 <http://example.org/vocab#p> _:e5 .
      // _:e11 <http://example.org/vocab#p> _:e5 .
      // _:e11 <http://example.org/vocab#p> _:e6 .
      // _:e11 <http://example.org/vocab#p> _:e7 .
      final quads = await _loadTestFile('test046-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n0 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#p> _:c14n3 .
      // _:c14n1 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#p> _:c14n4 .
      // _:c14n1 <http://example.org/vocab#p> _:c14n5 .
      // _:c14n10 <http://example.org/vocab#p> _:c14n7 .
      // _:c14n10 <http://example.org/vocab#p> _:c14n8 .
      // _:c14n10 <http://example.org/vocab#p> _:c14n9 .
      // _:c14n11 <http://example.org/vocab#p> _:c14n7 .
      // _:c14n11 <http://example.org/vocab#p> _:c14n8 .
      // _:c14n11 <http://example.org/vocab#p> _:c14n9 .
      // _:c14n2 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n2 <http://example.org/vocab#p> _:c14n3 .
      // _:c14n2 <http://example.org/vocab#p> _:c14n5 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n4 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n3 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n5 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n4 .
      // _:c14n6 <http://example.org/vocab#p> _:c14n7 .
      // _:c14n6 <http://example.org/vocab#p> _:c14n8 .
      // _:c14n6 <http://example.org/vocab#p> _:c14n9 .
      // _:c14n7 <http://example.org/vocab#p> _:c14n10 .
      // _:c14n7 <http://example.org/vocab#p> _:c14n11 .
      // _:c14n7 <http://example.org/vocab#p> _:c14n6 .
      // _:c14n8 <http://example.org/vocab#p> _:c14n10 .
      // _:c14n8 <http://example.org/vocab#p> _:c14n11 .
      // _:c14n8 <http://example.org/vocab#p> _:c14n6 .
      // _:c14n9 <http://example.org/vocab#p> _:c14n10 .
      // _:c14n9 <http://example.org/vocab#p> _:c14n11 .
      // _:c14n9 <http://example.org/vocab#p> _:c14n6 .
      final expectedQuads = await _loadTestFile('test046-rdfc10.nq');
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
