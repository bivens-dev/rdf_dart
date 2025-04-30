import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/canonicalization/canonicalization_algorithm.dart';
import 'package:rdf_dart/src/canonicalization/complexity_limits.dart';
import 'package:rdf_dart/src/data_types.dart';
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
        complexityLimits: ComplexityLimits.medium
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
        complexityLimits: ComplexityLimits.medium
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
        complexityLimits: ComplexityLimits.medium
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
        complexityLimits: ComplexityLimits.medium
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
        complexityLimits: ComplexityLimits.medium
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
        complexityLimits: ComplexityLimits.medium
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
        complexityLimits: ComplexityLimits.medium
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
        complexityLimits: ComplexityLimits.medium
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
        complexityLimits: ComplexityLimits.medium
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
        complexityLimits: ComplexityLimits.low
        
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
        complexityLimits: ComplexityLimits.low
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
        complexityLimits: ComplexityLimits.low
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

    test('test047c: deep diff (1)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p> _:e1 .
      // _:e1 <http://example.org/vocab#p> _:e2 .
      // _:e2 <http://example.org/vocab#z> "foo1" .
      // _:e2 <http://example.org/vocab#z> "foo2" .
      // _:e3 <http://example.org/vocab#p> _:e4 .
      // _:e4 <http://example.org/vocab#p> _:e5 .
      // _:e5 <http://example.org/vocab#z> "bar1" .
      // _:e5 <http://example.org/vocab#z> "bar2" .
      final quads = await _loadTestFile('test047-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#z> "bar1" .
      // _:c14n0 <http://example.org/vocab#z> "bar2" .
      // _:c14n1 <http://example.org/vocab#z> "foo1" .
      // _:c14n1 <http://example.org/vocab#z> "foo2" .
      // _:c14n2 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n4 .
      final expectedQuads = await _loadTestFile('test047-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test048c: deep diff (2)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p> _:e1 .
      // _:e1 <http://example.org/vocab#p> _:e2 .
      // _:e2 <http://example.org/vocab#z> "bar1" .
      // _:e2 <http://example.org/vocab#z> "bar2" .
      // _:e3 <http://example.org/vocab#p> _:e4 .
      // _:e4 <http://example.org/vocab#p> _:e5 .
      // _:e5 <http://example.org/vocab#z> "foo1" .
      // _:e5 <http://example.org/vocab#z> "foo2" .
      final quads = await _loadTestFile('test048-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#z> "bar1" .
      // _:c14n0 <http://example.org/vocab#z> "bar2" .
      // _:c14n1 <http://example.org/vocab#z> "foo1" .
      // _:c14n1 <http://example.org/vocab#z> "foo2" .
      // _:c14n2 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n4 .
      final expectedQuads = await _loadTestFile('test048-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test053c: @list', () async {
      // Input File Contents:
      // _:e1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "1" .
      // _:e1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:e2 .
      // _:e2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "2" .
      // _:e2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:e3 .
      // _:e3 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "3" .
      // _:e3 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
      // _:e0 <http://example.org/test#property1> _:e1 .
      // _:e4 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "4" .
      // _:e4 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:e5 .
      // _:e5 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "5" .
      // _:e5 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:e6 .
      // _:e6 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "6" .
      // _:e6 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
      // _:e0 <http://example.org/test#property2> _:e4 .
      final quads = await _loadTestFile('test053-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "3" .
      // _:c14n0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
      // _:c14n1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "6" .
      // _:c14n1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
      // _:c14n2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "1" .
      // _:c14n2 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:c14n5 .
      // _:c14n3 <http://example.org/test#property1> _:c14n2 .
      // _:c14n3 <http://example.org/test#property2> _:c14n6 .
      // _:c14n4 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "5" .
      // _:c14n4 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:c14n1 .
      // _:c14n5 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "2" .
      // _:c14n5 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:c14n0 .
      // _:c14n6 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "4" .
      // _:c14n6 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:c14n4 .
      final expectedQuads = await _loadTestFile('test053-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test054c: t-graph', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p> _:e1 .
      // _:e1 <http://example.org/vocab#p> _:e2 .
      // _:e2 <http://example.org/vocab#p> _:e3 .
      // _:e2 <http://example.org/vocab#p> _:e4 .
      // _:e3 <http://example.org/vocab#p> _:e5 .
      // _:e4 <http://example.org/vocab#p> _:e10 .
      // _:e5 <http://example.org/vocab#p> _:e6 .
      // _:e6 <http://example.org/vocab#p> _:e7 .
      // _:e7 <http://example.org/vocab#p> _:e8 .
      // _:e8 <http://example.org/vocab#p> _:e9 .
      // _:e10 <http://example.org/vocab#p> _:e11 .
      // _:e11 <http://example.org/vocab#p> _:e12 .
      // _:e12 <http://example.org/vocab#p> _:e13 .
      // _:e13 <http://example.org/vocab#p> _:e14 .
      // _:e14 <http://example.org/vocab#p> _:e15 .
      final quads = await _loadTestFile('test054-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p> _:c14n14 .
      // _:c14n0 <http://example.org/vocab#p> _:c14n7 .
      // _:c14n1 <http://example.org/vocab#p> _:c14n15 .
      // _:c14n10 <http://example.org/vocab#p> _:c14n9 .
      // _:c14n11 <http://example.org/vocab#p> _:c14n10 .
      // _:c14n12 <http://example.org/vocab#p> _:c14n11 .
      // _:c14n13 <http://example.org/vocab#p> _:c14n12 .
      // _:c14n14 <http://example.org/vocab#p> _:c14n13 .
      // _:c14n15 <http://example.org/vocab#p> _:c14n0 .
      // _:c14n3 <http://example.org/vocab#p> _:c14n2 .
      // _:c14n4 <http://example.org/vocab#p> _:c14n3 .
      // _:c14n5 <http://example.org/vocab#p> _:c14n4 .
      // _:c14n6 <http://example.org/vocab#p> _:c14n5 .
      // _:c14n7 <http://example.org/vocab#p> _:c14n6 .
      // _:c14n9 <http://example.org/vocab#p> _:c14n8 .
      final expectedQuads = await _loadTestFile('test054-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test055c: simple reorder (1)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p> _:e1 .
      // _:e0 <http://example.org/vocab#p> <http://example.com> .
      // _:e1 <http://example.org/vocab#p> <http://example.org> .
      final quads = await _loadTestFile('test055-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p> <http://example.com> .
      // _:c14n0 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#p> <http://example.org> .
      final expectedQuads = await _loadTestFile('test055-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test056c: simple reorder (2)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#p> <http://example.org> .
      // _:e1 <http://example.org/vocab#p> _:e0 .
      // _:e1 <http://example.org/vocab#p> <http://example.com> .
      final quads = await _loadTestFile('test056-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#p> <http://example.com> .
      // _:c14n0 <http://example.org/vocab#p> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#p> <http://example.org> .
      final expectedQuads = await _loadTestFile('test056-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test057c: unnamed graph', () async {
      // Input File Contents:
      // _:b1 <http://xmlns.com/foaf/0.1/homepage> <http://manu.sporny.org/> _:g .
      // _:b1 <http://xmlns.com/foaf/0.1/name> "Manu Sporny" _:g .
      final quads = await _loadTestFile('test057-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n1 <http://xmlns.com/foaf/0.1/homepage> <http://manu.sporny.org/> _:c14n0 .
      // _:c14n1 <http://xmlns.com/foaf/0.1/name> "Manu Sporny" _:c14n0 .
      final expectedQuads = await _loadTestFile('test057-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test058c: unnamed graph with blank node objects', () async {
      // Input File Contents:
      // <https://example.com/1> <https://example.com/2> _:e0 _:e3 .
      // <https://example.com/1> <https://example.com/2> _:e1 _:e3 .
      final quads = await _loadTestFile('test058-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <https://example.com/1> <https://example.com/2> _:c14n1 _:c14n0 .
      // <https://example.com/1> <https://example.com/2> _:c14n2 _:c14n0 .
      final expectedQuads = await _loadTestFile('test058-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test059c: n-quads parsing', () async {
      // Input File Contents:
      // <urn:ex:s> <urn:ex:p> <urn:ex:o> <urn:ex:g> .
      // _:s0 <urn:ex:p> _:o0 _:g0 .
      // _:s1 <urn:ex:p> _:o1 _:g1 .
      // _:s2 <urn:ex:p> _:o2 _:g2 .
      // _:s3 <urn:ex:p> _:o3 _:g3 .
      // _:s4 <urn:ex:p> _:o4 _:g4 .
      // _:s5 <urn:ex:p> _:o5 _:g5 .
      // _:s6 <urn:ex:p> <urn:ex:o> <urn:ex:g> .
      final quads = await _loadTestFile('test059-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <urn:ex:s> <urn:ex:p> <urn:ex:o> <urn:ex:g> .
      // _:c14n0 <urn:ex:p> <urn:ex:o> <urn:ex:g> .
      // _:c14n1 <urn:ex:p> _:c14n3 _:c14n2 .
      // _:c14n10 <urn:ex:p> _:c14n12 _:c14n11 .
      // _:c14n13 <urn:ex:p> _:c14n15 _:c14n14 .
      // _:c14n16 <urn:ex:p> _:c14n18 _:c14n17 .
      // _:c14n4 <urn:ex:p> _:c14n6 _:c14n5 .
      // _:c14n7 <urn:ex:p> _:c14n9 _:c14n8 .
      final expectedQuads = await _loadTestFile('test059-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test060c: n-quads escaping', () async {
      // Input File Contents:
      // <urn:ex:s:000:s\u20701> <urn:ex:000:p\u2070> <urn:ex:000:o\u2070> <urn:ex:000:g\u2070> .
      // <urn:ex:s:000:s⁰2> <urn:ex:000:p⁰> <urn:ex:000:o⁰> <urn:ex:000:g⁰> .
      // <urn:ex:s:001> <urn:ex:000:empty> "" .
      // <urn:ex:s:001> <urn:ex:001:simple> "simple" .
      // <urn:ex:s:001> <urn:ex:002:quote> "\"" .
      // <urn:ex:s:001> <urn:ex:003:backslash> "\\" .
      // <urn:ex:s:001> <urn:ex:004:nl> "\n" .
      // <urn:ex:s:001> <urn:ex:005:cr> "\r" .
      // <urn:ex:s:001> <urn:ex:006:all> "\"\\\n\r" .
      // <urn:ex:s:001> <urn:ex:007:uchar> "\u0022\u005c" .
      // <urn:ex:s:001> <urn:ex:008:echar> "\t\b\n\r\f\"\'\\" .
      // <urn:ex:s:001> <urn:ex:009> "\\u0039" .
      // <urn:ex:s:001> <urn:ex:010> "\\n" .
      // <urn:ex:s:001> <urn:ex:011> "\\\\" .
      // <urn:ex:s:001> <urn:ex:012> "\"\"" .
      // <urn:ex:s:001> <urn:ex:013> "\\\\\\" .
      // <urn:ex:s:001> <urn:ex:014> "\"\"\"" .
      // <urn:ex:s:001> <urn:ex:015> "\u221e" .
      // <urn:ex:s:001> <urn:ex:016> "∞" .
      // <urn:ex:s:001> <urn:ex:017> <urn:ex:\u0065\u0078> .
      // <urn:ex:s:001> <urn:ex:018> <urn:ex:\u221e> .
      // <urn:ex:s:001> <urn:ex:019> <urn:ex:\u002b> .
      // <urn:ex:s:003> <urn:ex:020> <urn:ex:\u00a0> .
      // <urn:ex:s:003> <urn:ex:021> "\uf600"^^<urn:ex:\u1f43> .
      // <urn:ex:s:003> <urn:ex:022> "d"^^<urn:ex:\u0064\u0074> .
      // <urn:ex:s:003> <urn:ex:023> "d"^^<urn:ex:\u0064> .
      // <urn:ex:s:004> <urn:ex:024> "\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u0008\u0009\u000a\u000b\u000c\u000d\u000e\u000f" .
      // <urn:ex:s:004> <urn:ex:025> "\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001a\u001b\u001c\u001d\u001e\u001f" .
      // <urn:ex:s:004> <urn:ex:026> "\u0020\u0021\u0022\u0023\u0024\u0025\u0026\u0027\u0028\u0029\u002a\u002b\u002c\u002d\u002e\u002f" .
      // <urn:ex:s:004> <urn:ex:027> "\u0030\u0031\u0032\u0033\u0034\u0035\u0036\u0037\u0038\u0039\u003a\u003b\u003c\u003d\u003e\u003f" .
      // <urn:ex:s:004> <urn:ex:028> "\u0040\u0041\u0042\u0043\u0044\u0045\u0046\u0047\u0048\u0049\u004a\u004b\u004c\u004d\u004e\u004f" .
      // <urn:ex:s:004> <urn:ex:029> "\u0050\u0051\u0052\u0053\u0054\u0055\u0056\u0057\u0058\u0059\u005a\u005b\u005c\u005d\u005e\u005f" .
      // <urn:ex:s:004> <urn:ex:030> "\u0060\u0061\u0062\u0063\u0064\u0065\u0066\u0067\u0068\u0069\u006a\u006b\u006c\u006d\u006e\u006f" .
      // <urn:ex:s:004> <urn:ex:031> "\u0070\u0071\u0072\u0073\u0074\u0075\u0076\u0077\u0078\u0079\u007a\u007b\u007c\u007d\u007e\u007f" .
      // <urn:ex:s:004> <urn:ex:032> "\u0080\u0081\u0082\u0083\u0084\u0085\u0086\u0087\u0088\u0089\u008a\u008b\u008c\u008d\u008e\u008f" .
      // <urn:ex:s:004> <urn:ex:033> "\U0001F303" .
      // <urn:ex:s:004> <urn:ex:034> "🌃" .
      // <urn:ex:s:005> <urn:ex:035> <urn:ex:\U0001F303> .
      // <urn:ex:s:006> <urn:ex:036> "o" <urn:ex:\u221e> .
      // <urn:ex:s:006> <urn:ex:037> "o" <urn:ex:∞> .
      // <urn:ex:s:006> <urn:ex:038> "o" <urn:ex:\u221e> .
      // <urn:ex:s:006> <urn:ex:039> "\u0009\u0020<>\"{}|^`\\" .
      // <urn:ex:s:007> <urn:ex:040> "\U00000000\U00000001\U00000002\U00000003\U00000004\U00000005\U00000006\U00000007\U00000008\U00000009\U0000000a\U0000000b\U0000000c\U0000000d\U0000000e\U0000000f" .
      final quads = await _loadTestFile('test060-in.nq');
       // Add the custom datatypes to the registry so they can be parsed correctly
      DatatypeRegistry().registerDatatype(
        IRI('urn:ex:ὃ'),
        String,
        (String lexicalForm) => lexicalForm,
        (Object value) => value.toString(),
      );
      DatatypeRegistry().registerDatatype(
        IRI('urn:ex:dt'),
        String,
        (String lexicalForm) => lexicalForm,
        (Object value) => value.toString(),
      );
      DatatypeRegistry().registerDatatype(
        IRI('urn:ex:d'),
        String,
        (String lexicalForm) => lexicalForm,
        (Object value) => value.toString(),
      );
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <urn:ex:s:000:s⁰1> <urn:ex:000:p⁰> <urn:ex:000:o⁰> <urn:ex:000:g⁰> .
      // <urn:ex:s:000:s⁰2> <urn:ex:000:p⁰> <urn:ex:000:o⁰> <urn:ex:000:g⁰> .
      // <urn:ex:s:001> <urn:ex:000:empty> "" .
      // <urn:ex:s:001> <urn:ex:001:simple> "simple" .
      // <urn:ex:s:001> <urn:ex:002:quote> "\"" .
      // <urn:ex:s:001> <urn:ex:003:backslash> "\\" .
      // <urn:ex:s:001> <urn:ex:004:nl> "\n" .
      // <urn:ex:s:001> <urn:ex:005:cr> "\r" .
      // <urn:ex:s:001> <urn:ex:006:all> "\"\\\n\r" .
      // <urn:ex:s:001> <urn:ex:007:uchar> "\"\\" .
      // <urn:ex:s:001> <urn:ex:008:echar> "\t\b\n\r\f\"'\\" .
      // <urn:ex:s:001> <urn:ex:009> "\\u0039" .
      // <urn:ex:s:001> <urn:ex:010> "\\n" .
      // <urn:ex:s:001> <urn:ex:011> "\\\\" .
      // <urn:ex:s:001> <urn:ex:012> "\"\"" .
      // <urn:ex:s:001> <urn:ex:013> "\\\\\\" .
      // <urn:ex:s:001> <urn:ex:014> "\"\"\"" .
      // <urn:ex:s:001> <urn:ex:015> "∞" .
      // <urn:ex:s:001> <urn:ex:016> "∞" .
      // <urn:ex:s:001> <urn:ex:017> <urn:ex:ex> .
      // <urn:ex:s:001> <urn:ex:018> <urn:ex:∞> .
      // <urn:ex:s:001> <urn:ex:019> <urn:ex:+> .
      // <urn:ex:s:003> <urn:ex:020> <urn:ex: > .
      // <urn:ex:s:003> <urn:ex:021> ""^^<urn:ex:ὃ> .
      // <urn:ex:s:003> <urn:ex:022> "d"^^<urn:ex:dt> .
      // <urn:ex:s:003> <urn:ex:023> "d"^^<urn:ex:d> .
      // <urn:ex:s:004> <urn:ex:024> "\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\b\t\n\u000B\f\r\u000E\u000F" .
      // <urn:ex:s:004> <urn:ex:025> "\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001A\u001B\u001C\u001D\u001E\u001F" .
      // <urn:ex:s:004> <urn:ex:026> " !\"#$%&'()*+,-./" .
      // <urn:ex:s:004> <urn:ex:027> "0123456789:;<=>?" .
      // <urn:ex:s:004> <urn:ex:028> "@ABCDEFGHIJKLMNO" .
      // <urn:ex:s:004> <urn:ex:029> "PQRSTUVWXYZ[\\]^_" .
      // <urn:ex:s:004> <urn:ex:030> "`abcdefghijklmno" .
      // <urn:ex:s:004> <urn:ex:031> "pqrstuvwxyz{|}~\u007F" .
      // <urn:ex:s:004> <urn:ex:032> "" .
      // <urn:ex:s:004> <urn:ex:033> "🌃" .
      // <urn:ex:s:004> <urn:ex:034> "🌃" .
      // <urn:ex:s:005> <urn:ex:035> <urn:ex:🌃> .
      // <urn:ex:s:006> <urn:ex:036> "o" <urn:ex:∞> .
      // <urn:ex:s:006> <urn:ex:037> "o" <urn:ex:∞> .
      // <urn:ex:s:006> <urn:ex:038> "o" <urn:ex:∞> .
      // <urn:ex:s:006> <urn:ex:039> "\t <>\"{}|^`\\" .
      // <urn:ex:s:007> <urn:ex:040> "\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\b\t\n\u000B\f\r\u000E\u000F" .
      final expectedQuads = await _loadTestFile('test060-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test061c: same literal value with multiple languages', () async {
      // Input File Contents:
      // <http://example.com> <http://example.com/label> "test"@en .
      // <http://example.com> <http://example.com/label> "test"@fr .
      final quads = await _loadTestFile('test061-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.com> <http://example.com/label> "test"@en .
      // <http://example.com> <http://example.com/label> "test"@fr .
      final expectedQuads = await _loadTestFile('test061-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test062c: same literal value with multiple datatypes', () async {
      // Input File Contents:
      // <http://example.com> <http://example.com/label> "test"^^<http://example.com/t1> .
      // <http://example.com> <http://example.com/label> "test"^^<http://example.com/t2> .
      final quads = await _loadTestFile('test062-in.nq');
      // Add the custom datatypes to the registry so they can be parsed correctly
      DatatypeRegistry().registerDatatype(
        IRI('http://example.com/t1'),
        String,
        (String lexicalForm) => lexicalForm,
        (Object value) => value.toString(),
      );
      DatatypeRegistry().registerDatatype(
        IRI('http://example.com/t2'),
        String,
        (String lexicalForm) => lexicalForm,
        (Object value) => value.toString(),
      );
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.com> <http://example.com/label> "test"^^<http://example.com/t1> .
      // <http://example.com> <http://example.com/label> "test"^^<http://example.com/t2> .
      final expectedQuads = await _loadTestFile('test062-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test063c: blank node - diamond (with _:b)', () async {
      // Input File Contents:
      // <http://example.org/vocab#test> <http://example.org/vocab#A> _:b0 .
      // <http://example.org/vocab#test> <http://example.org/vocab#B> _:b1 .
      // _:b0 <http://example.org/vocab#next> _:b2 .
      // _:b1 <http://example.org/vocab#next> _:b2 .
      final quads = await _loadTestFile('test063-in.nq');
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
      final expectedQuads = await _loadTestFile('test063-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test064c: blank node - double circle of 3 (0-1-2, reversed)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#next> _:e2 .
      // _:e0 <http://example.org/vocab#prev> _:e1 .
      // _:e1 <http://example.org/vocab#next> _:e0 .
      // _:e1 <http://example.org/vocab#prev> _:e2 .
      // _:e2 <http://example.org/vocab#next> _:e1 .
      // _:e2 <http://example.org/vocab#prev> _:e0 .
      final quads = await _loadTestFile('test064-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
        complexityLimits: ComplexityLimits.medium
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test064-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test065c: blank node - double circle of 3 (0-2-1, reversed)', () async {
      // Input File Contents:
      // _:e0 <http://example.org/vocab#next> _:e2 .
      // _:e0 <http://example.org/vocab#prev> _:e1 .
      // _:e2 <http://example.org/vocab#next> _:e1 .
      // _:e2 <http://example.org/vocab#prev> _:e0 .
      // _:e1 <http://example.org/vocab#next> _:e0 .
      // _:e1 <http://example.org/vocab#prev> _:e2 .
      final quads = await _loadTestFile('test065-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
        complexityLimits: ComplexityLimits.medium
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test065-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test066c: blank node - double circle of 3 (1-0-2, reversed)', () async {
      // Input File Contents:
      // _:e1 <http://example.org/vocab#next> _:e0 .
      // _:e1 <http://example.org/vocab#prev> _:e2 .
      // _:e0 <http://example.org/vocab#next> _:e2 .
      // _:e0 <http://example.org/vocab#prev> _:e1 .
      // _:e2 <http://example.org/vocab#next> _:e1 .
      // _:e2 <http://example.org/vocab#prev> _:e0 .
      final quads = await _loadTestFile('test066-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
        complexityLimits: ComplexityLimits.medium
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test066-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test067c: blank node - double circle of 3 (1-2-0, reversed)', () async {
      // Input File Contents:
      // _:e1 <http://example.org/vocab#next> _:e0 .
      // _:e1 <http://example.org/vocab#prev> _:e2 .
      // _:e2 <http://example.org/vocab#next> _:e1 .
      // _:e2 <http://example.org/vocab#prev> _:e0 .
      // _:e0 <http://example.org/vocab#next> _:e2 .
      // _:e0 <http://example.org/vocab#prev> _:e1 .
      final quads = await _loadTestFile('test067-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
        complexityLimits: ComplexityLimits.medium
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test067-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test068c: blank node - double circle of 3 (2-1-0, reversed)', () async {
      // Input File Contents:
      // _:e2 <http://example.org/vocab#next> _:e1 .
      // _:e2 <http://example.org/vocab#prev> _:e0 .
      // _:e1 <http://example.org/vocab#next> _:e0 .
      // _:e1 <http://example.org/vocab#prev> _:e2 .
      // _:e0 <http://example.org/vocab#next> _:e2 .
      // _:e0 <http://example.org/vocab#prev> _:e1 .
      final quads = await _loadTestFile('test068-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
        complexityLimits: ComplexityLimits.medium
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test068-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    test('test069c: blank node - double circle of 3 (2-0-1, reversed)', () async {
      // Input File Contents:
      // _:e2 <http://example.org/vocab#next> _:e1 .
      // _:e2 <http://example.org/vocab#prev> _:e0 .
      // _:e0 <http://example.org/vocab#next> _:e2 .
      // _:e0 <http://example.org/vocab#prev> _:e1 .
      // _:e1 <http://example.org/vocab#next> _:e0 .
      // _:e1 <http://example.org/vocab#prev> _:e2 .
      final quads = await _loadTestFile('test069-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
        complexityLimits: ComplexityLimits.medium
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // _:c14n0 <http://example.org/vocab#next> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#prev> _:c14n1 .
      // _:c14n1 <http://example.org/vocab#next> _:c14n0 .
      // _:c14n1 <http://example.org/vocab#prev> _:c14n2 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#prev> _:c14n0 .
      final expectedQuads = await _loadTestFile('test069-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    // Isomorphic graphs in default and IRI named graph
    test('test070c: dataset - isomorphic default and iri named', () async {
      // Input File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#A> _:e1 <http://example.org/g1> .
      // <http://example.org/test> <http://example.org/vocab#B> _:e1 <http://example.org/g1> .
      // <http://example.org/test> <http://example.org/vocab#embed> _:e1 <http://example.org/g1> .
      final quads = await _loadTestFile('test070-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#A> _:c14n1 <http://example.org/g1> .
      // <http://example.org/test> <http://example.org/vocab#B> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:c14n1 <http://example.org/g1> .
      // <http://example.org/test> <http://example.org/vocab#embed> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:c14n1 <http://example.org/g1> .
      final expectedQuads = await _loadTestFile('test070-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    // Isomorphic graphs in default and blank node named graph
    test('test071c: dataset - isomorphic default and node named', () async {
      // Input File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#A> _:e1 _:g1 .
      // <http://example.org/test> <http://example.org/vocab#B> _:e1 _:g1 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:e1 _:g1 .
      final quads = await _loadTestFile('test071-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#A> _:c14n2 _:c14n1 .
      // <http://example.org/test> <http://example.org/vocab#B> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:c14n2 _:c14n1 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:c14n2 _:c14n1 .
      final expectedQuads = await _loadTestFile('test071-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    // Blank nodes shared in default and named graph
    test('test072c: dataset - shared blank nodes', () async {
      // Input File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#A> _:e0 <http://example.org/g1> .
      // <http://example.org/test> <http://example.org/vocab#B> _:e0 <http://example.org/g1> .
      // <http://example.org/test> <http://example.org/vocab#embed> _:e0 <http://example.org/g1> .
      final quads = await _loadTestFile('test072-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#A> _:c14n0 <http://example.org/g1> .
      // <http://example.org/test> <http://example.org/vocab#B> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:c14n0 <http://example.org/g1> .
      // <http://example.org/test> <http://example.org/vocab#embed> _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:c14n0 <http://example.org/g1> .
      final expectedQuads = await _loadTestFile('test072-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    // Default graph with blank node shared with graph name
    test('test073c: dataset - referencing graph name', () async {
      // Input File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:e0 .
      // <http://example.org/test> <http://example.org/vocab#graph> _:g1 .
      // <http://example.org/test> <http://example.org/vocab#A> _:e0  _:g1 .
      // <http://example.org/test> <http://example.org/vocab#B> _:e0 _:g1 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:e0 _:g1 .
      final quads = await _loadTestFile('test073-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/test> <http://example.org/vocab#A> _:c14n1 .
      // <http://example.org/test> <http://example.org/vocab#A> _:c14n1 _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#B> _:c14n1 .
      // <http://example.org/test> <http://example.org/vocab#B> _:c14n1 _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:c14n1 .
      // <http://example.org/test> <http://example.org/vocab#embed> _:c14n1 _:c14n0 .
      // <http://example.org/test> <http://example.org/vocab#graph> _:c14n0 .
      final expectedQuads = await _loadTestFile('test073-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    // FIXME: We don't currently attempt to identify and bail out of poison datasets so this will run forever and fail
    // A 10-node Clique of blank node resources all inter-related.
    test('test074c: poison - Clique Graph (negative test)', () async {
      final quads = await _loadTestFile('test074-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
        complexityLimits: ComplexityLimits.low
      );
      expect(() => canonicalizer.canonicalize(inputDataset), throwsException);
    });

    test('test075c: blank node - diamond (uses SHA-384)', () async {
      // Input File Contents:
      // <http://example.org/vocab#test> <http://example.org/vocab#A> _:e0 .
      // <http://example.org/vocab#test> <http://example.org/vocab#B> _:e1 .
      // _:e0 <http://example.org/vocab#next> _:e2 .
      // _:e1 <http://example.org/vocab#next> _:e2 .
      final quads = await _loadTestFile('test075-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
        hashAlgorithm: sha384
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <http://example.org/vocab#test> <http://example.org/vocab#A> _:c14n0 .
      // <http://example.org/vocab#test> <http://example.org/vocab#B> _:c14n2 .
      // _:c14n0 <http://example.org/vocab#next> _:c14n1 .
      // _:c14n2 <http://example.org/vocab#next> _:c14n1 .
      final expectedQuads = await _loadTestFile('test075-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    // The duplicate triples must be removed
    test('test076c: duplicate ground triple in input', () async {
      // Input File Contents:
      // <https://www.example.org/s> <https://www.example.org/p> <https://www.example.org/o> .
      // <https://www.example.org/s> <https://www.example.org/p> <https://www.example.org/o> .
      final quads = await _loadTestFile('test076-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <https://www.example.org/s> <https://www.example.org/p> <https://www.example.org/o> .
      final expectedQuads = await _loadTestFile('test076-rdfc10.nq');
      expect(canonicalDataset, equals(expectedQuads));
    });

    // The duplicate triples must be removed
    test('test077c: duplicate triple with blank node in input', () async {
      // Input File Contents:
      // <https://www.example.org/s> <https://www.example.org/p> _:o .
      // <https://www.example.org/s> <https://www.example.org/p> _:o .
      final quads = await _loadTestFile('test077-in.nq');
      final inputDataset = nQuadsCodec.decode(quads);
      final canonicalizer = Canonicalizer.create(
        CanonicalizationAlgorithm.rdfc10,
      );
      final canonicalDataset = canonicalizer.canonicalize(inputDataset);
      // Expected Output File Contents:
      // <https://www.example.org/s> <https://www.example.org/p> _:c14n0 .
      final expectedQuads = await _loadTestFile('test077-rdfc10.nq');
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
