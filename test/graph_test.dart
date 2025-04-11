import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Graph', () {
    late Graph graph;
    late IRITerm subject;
    late IRITerm predicate;
    late IRITerm object;
    late Triple triple;

    setUp(() {
      graph = Graph();
      subject = IRITerm('http://example.com/subject');
      predicate = IRITerm('http://example.com/predicate');
      object = IRITerm('http://example.com/object');
      triple = Triple(subject, predicate, object);
    });

    group('add', () {
      test('adds a triple to the graph', () {
        graph.add(triple);
        expect(graph.triples, contains(triple));
      });

      test('does not add the same triple twice', () {
        graph.add(triple);
        graph.add(triple);
        expect(graph.triples.length, 1);
      });
    });

    group('addAll', () {
      test('adds multiple triples to the graph', () {
        final triple2 = Triple(
          subject,
          predicate,
          IRITerm('http://example.com/object2'),
        );
        graph.addAll([triple, triple2]);
        expect(graph.triples, containsAll([triple, triple2]));
        expect(graph.triples.length, 2);
      });

      test(
        'does not add the same triple twice when adding multiple triples',
        () {
          final triple2 = Triple(
            subject,
            predicate,
            IRITerm('http://example.com/object2'),
          );
          graph.addAll([triple, triple, triple2, triple2]);
          expect(graph.triples.length, 2);
        },
      );
    });

    group('remove', () {
      test('removes a triple from the graph', () {
        graph.add(triple);
        graph.remove(triple);
        expect(graph.triples, isNot(contains(triple)));
      });

      test('does nothing if the triple is not in the graph', () {
        graph.remove(triple);
        expect(graph.triples, isEmpty);
      });
    });

    group('contains', () {
      test('returns true if the graph contains the triple', () {
        graph.add(triple);
        expect(graph.contains(triple), true);
      });

      test('returns false if the graph does not contain the triple', () {
        expect(graph.contains(triple), false);
      });
    });
    group('triples', () {
      test('returns an unmodifiable set', () {
        expect(() => graph.triples.add(triple), throwsUnsupportedError);
      });
    });

    group('classicize', () {
      test('converts an RDF full graph to a RDF classic graph successfully', () {
        graph.addAll([
          Triple(
            BlankNode('r1'),
            IRITerm(RDF.reifies.toString()),
            TripleTerm(triple),
          ),
          Triple(
            BlankNode('r1'),
            IRITerm('http://example.org/q'),
            Literal(
              'some value',
              XSD.string,
            ),
          ),
        ]);
        final classicGraph = Graph.classicize(graph);

        // Find the triple in the classicgraph where the predicate 
        // is http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies
        final reifierTriple = classicGraph.triples.firstWhere(
          (triple) =>
              triple.predicate ==
              IRITerm(RDF.reifies.toString()),
        );
        final generatedBlankNode = reifierTriple.object as BlankNode;

        expect(
          classicGraph.triples.contains(
            Triple(
              BlankNode('r1'),
              IRITerm('http://example.org/q'),
              Literal(
                'some value',
                XSD.string,
              ),
            ),
          ),
          isTrue,
        );

        expect(
          classicGraph.triples.contains(
            Triple(
              BlankNode('r1'),
              IRITerm(RDF.reifies.toString()),
              generatedBlankNode,
            ),
          ),
          isTrue,
        );

        expect(
          classicGraph.triples.contains(
            Triple(
              generatedBlankNode,
              IRITerm(RDF.type.toString()),
              IRITerm(RDF.tripleTerm.toString()),
            ),
          ),
          isTrue,
        );

        expect(
          classicGraph.triples.contains(
            Triple(
              generatedBlankNode,
              IRITerm(RDF.ttSubject.toString()),
              subject,
            ),
          ),
          isTrue,
        );

        expect(
          classicGraph.triples.contains(
            Triple(
              generatedBlankNode,
              IRITerm(RDF.ttPredicate.toString()),
              predicate,
            ),
          ),
          isTrue,
        );

        expect(
          classicGraph.triples.contains(
            Triple(
              generatedBlankNode,
              IRITerm(RDF.ttObject.toString()),
              object,
            ),
          ),
          isTrue,
        );
      });

      test('does not change a graph that is already RDF classic conformant', () {
        final reclassicized = Graph.classicize(graph);

        expect(reclassicized.triples, equals(graph.triples));
      });

      test('Applying a transformation several times to a graph should have the same effect as applying it once', () {
        graph.addAll([
          Triple(
            BlankNode('r1'),
            IRITerm(RDF.reifies.toString()),
            TripleTerm(triple),
          ),
          Triple(
            BlankNode('r1'),
            IRITerm('http://example.org/q'),
            Literal(
              'some value',
              XSD.string,
            ),
          ),
        ]);
        final classicGraph = Graph.classicize(graph);
        final reclassicizedGraph = Graph.classicize(classicGraph);

        expect(reclassicizedGraph.triples, equals(classicGraph.triples));
      });
    });
  });
}
