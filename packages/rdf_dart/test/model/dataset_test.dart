import 'package:iri/iri.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Dataset', () {
    late Dataset dataset;
    late IRINode graphName;
    late Graph graph;

    setUp(() {
      dataset = Dataset();
      graphName = IRINode(IRI('http://example.com/graph'));
      graph = Graph();
    });

    group('Creation', () {
      test('creates an empty dataset with an empty default graph', () {
        expect(dataset.defaultGraph.triples, isEmpty);
        expect(dataset.namedGraphs, isEmpty);
      });
    });

    group('addNamedGraph', () {
      test('adds a named graph to the dataset', () {
        dataset.addNamedGraph(graphName, graph);
        expect(dataset.namedGraphs, containsValue(graph));
        expect(dataset.namedGraphs.containsKey(graphName), true);
        expect(dataset.namedGraphs.length, 1);
      });

      test('replaces an existing named graph with the same name', () {
        final newGraph = Graph();
        dataset.addNamedGraph(graphName, graph);
        dataset.addNamedGraph(graphName, newGraph);
        expect(dataset.namedGraphs[graphName], newGraph);
        expect(dataset.namedGraphs.length, 1);
      });
    });

    group('removeNamedGraph', () {
      test('removes a named graph from the dataset', () {
        dataset.addNamedGraph(graphName, graph);
        dataset.removeNamedGraph(graphName);
        expect(dataset.namedGraphs, isNot(containsValue(graph)));
        expect(dataset.namedGraphs.containsKey(graphName), false);
        expect(dataset.namedGraphs, isEmpty);
      });

      test('does nothing if the named graph does not exist', () {
        dataset.removeNamedGraph(graphName);
        expect(dataset.namedGraphs, isEmpty);
      });
    });

    group('defaultGraph', () {
      test('can add triple to the default graph', () {
        final subject = IRINode(IRI('http://example.com/subject'));
        final predicate = IRINode(IRI('http://example.com/predicate'));
        final object = IRINode(IRI('http://example.com/object'));
        final triple = Triple(subject, predicate, object);
        dataset.defaultGraph.add(triple);
        expect(dataset.defaultGraph.triples, contains(triple));
      });
    });
  });
}
