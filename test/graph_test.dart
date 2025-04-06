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
  });
}
