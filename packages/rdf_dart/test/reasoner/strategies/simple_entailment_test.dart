import 'dart:io';

import 'package:rdf_dart/src/codec/ntriples/ntriples_codec.dart';
import 'package:rdf_dart/src/model/graph.dart';
import 'package:rdf_dart/src/reasoner/reasoner.dart';
import 'package:rdf_dart/src/reasoner/strategies/simple/simple_entailment_strategy.dart';
import 'package:test/test.dart';

void main() {
  group('RDF 1.1', () {
    group('Simple Entailment', () {
      group('Positive Entailment', () {
        test('datatypes-test008', () async {
          final reasoner = Reasoner(SimpleEntailmentStrategy());
          // <http://example.org/a> <http://example.org/b> "10" .
          // <http://example.org/c> <http://example.org/d> "10" .
          final graph = await _loadTestData('test008a.nt');
          // <http://example.org/a> <http://example.org/b> _:x .
          // <http://example.org/c> <http://example.org/d> _:x .
          final subgraph = await _loadTestData('test008b.nt');
          final isEntailed = reasoner.entails(graph, subgraph);
          expect(isEntailed, isTrue);
        });
      });

      group('Negative Entailment', () {
        test('datatypes-test009', () async {
          final reasoner = Reasoner(SimpleEntailmentStrategy());
          // <http://example.org/a> <http://example.org/b> "10" .
          // <http://example.org/c> <http://example.org/d> "10"^^<http://www.w3.org/2001/XMLSchema#integer> .
          final graph = await _loadTestData('test009a.nt');
          // <http://example.org/a> <http://example.org/b> _:x .
          // <http://example.org/c> <http://example.org/d> _:x .
          final subgraph = await _loadTestData('test009b.nt');
          final isEntailed = reasoner.entails(graph, subgraph);
          expect(isEntailed, isFalse);
        });

        test(
          'test007a - Plain literals are distinguishable on the basis of language tags.',
          () async {
            final reasoner = Reasoner(SimpleEntailmentStrategy());
            // <http://example.org/node> <http://example.org/property> "chat"@fr .
            final graph = await _loadTestData('test007a.nt');
            // <http://example.org/node> <http://example.org/property> "chat"@en .
            final subgraph = await _loadTestData('test007b.nt');
            final isEntailed = reasoner.entails(graph, subgraph);
            expect(isEntailed, isFalse);
          },
        );

        test(
          'test007b - Plain literals are distinguishable on the basis of language tags.',
          () async {
            final reasoner = Reasoner(SimpleEntailmentStrategy());
            // <http://example.org/node> <http://example.org/property> "chat"@en .
            final graph = await _loadTestData('test007b.nt');
            // <http://example.org/node> <http://example.org/property> "chat" .
            final subgraph = await _loadTestData('test007c.nt');
            final isEntailed = reasoner.entails(graph, subgraph);
            expect(isEntailed, isFalse);
          },
        );

        test(
          'test007c - Plain literals are distinguishable on the basis of language tags.',
          () async {
            final reasoner = Reasoner(SimpleEntailmentStrategy());
            // <http://example.org/node> <http://example.org/property> "chat" .
            final graph = await _loadTestData('test007c.nt');
            // <http://example.org/node> <http://example.org/property> "chat"@fr .
            final subgraph = await _loadTestData('test007a.nt');
            final isEntailed = reasoner.entails(graph, subgraph);
            expect(isEntailed, isFalse);
          },
        );
      });
    });
  });
}

/// Helper method that takes in a filename and loads the appropriate test file
/// and returns it as a Graph.
Future<Graph> _loadTestData(String fileName) async {
  // Make sure we load only from the `test/canonicalization/test_cases` path
  final bytes = await File('test/reasoner/test_cases/$fileName').readAsString();
  final triples = nTriplesCodec.decode(bytes);
  return Graph()..addAll(triples);
}
