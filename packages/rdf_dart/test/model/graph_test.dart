import 'package:iri/iri.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Graph', () {
    late Graph graph;
    late IRINode subject;
    late IRINode predicate;
    late IRINode object;
    late Triple triple;

    setUp(() {
      graph = Graph();
      subject = IRINode(IRI('http://example.com/subject'));
      predicate = IRINode(IRI('http://example.com/predicate'));
      object = IRINode(IRI('http://example.com/object'));
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

    group('Ground Graphs', () {
      test('Graphs with Unground Triples are Not Grounded', () {
        final ungroundTriple = Triple(
          BlankNode('subject'),
          IRINode(IRI('http://example.com/predicate')),
          IRINode(IRI('http://example.com/object')),
        );
        graph.add(ungroundTriple);
        expect(graph.triples, contains(ungroundTriple));
        expect(graph.isGroundGraph, isFalse);
        expect(ungroundTriple.isGroundTriple, isFalse);
      });

      test('Graphs with Grounded Triples are Grounded', () {
        final groundedTriple = Triple(
          IRINode(IRI('http://example.com/subject')),
          IRINode(IRI('http://example.com/predicate')),
          IRINode(IRI('http://example.com/object')),
        );
        graph.add(groundedTriple);
        expect(graph.triples, contains(groundedTriple));
        expect(graph.isGroundGraph, isTrue);
        expect(groundedTriple.isGroundTriple, isTrue);
      });
    });

    group('addAll', () {
      test('adds multiple triples to the graph', () {
        final triple2 = Triple(
          subject,
          predicate,
          IRINode(IRI('http://example.com/object2')),
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
            IRINode(IRI('http://example.com/object2')),
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
      test(
        'converts an RDF full graph to a RDF classic graph successfully',
        () {
          graph.addAll([
            Triple(BlankNode('r1'), IRINode(RDF.reifies), TripleTerm(triple)),
            Triple(
              BlankNode('r1'),
              IRINode(IRI('http://example.org/q')),
              Literal('some value', XSD.string),
            ),
          ]);
          final classicGraph = Graph.classicize(graph);

          // Find the triple in the classicgraph where the predicate
          // is http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies
          final reifierTriple = classicGraph.triples.firstWhere(
            (triple) => triple.predicate == IRINode(RDF.reifies),
          );
          final generatedBlankNode = reifierTriple.object as BlankNode;

          expect(
            classicGraph.triples.contains(
              Triple(
                BlankNode('r1'),
                IRINode(IRI('http://example.org/q')),
                Literal('some value', XSD.string),
              ),
            ),
            isTrue,
          );

          expect(
            classicGraph.triples.contains(
              Triple(BlankNode('r1'), IRINode(RDF.reifies), generatedBlankNode),
            ),
            isTrue,
          );

          expect(
            classicGraph.triples.contains(
              Triple(
                generatedBlankNode,
                IRINode(RDF.type),
                IRINode(RDF.tripleTerm),
              ),
            ),
            isTrue,
          );

          expect(
            classicGraph.triples.contains(
              Triple(generatedBlankNode, IRINode(RDF.ttSubject), subject),
            ),
            isTrue,
          );

          expect(
            classicGraph.triples.contains(
              Triple(generatedBlankNode, IRINode(RDF.ttPredicate), predicate),
            ),
            isTrue,
          );

          expect(
            classicGraph.triples.contains(
              Triple(generatedBlankNode, IRINode(RDF.ttObject), object),
            ),
            isTrue,
          );
        },
      );

      test(
        'does not change a graph that is already RDF classic conformant',
        () {
          final reclassicized = Graph.classicize(graph);

          expect(reclassicized.triples, equals(graph.triples));
        },
      );

      test(
        'Applying a transformation several times to a graph should have the same effect as applying it once',
        () {
          graph.addAll([
            Triple(BlankNode('r1'), IRINode(RDF.reifies), TripleTerm(triple)),
            Triple(
              BlankNode('r1'),
              IRINode(IRI('http://example.org/q')),
              Literal('some value', XSD.string),
            ),
          ]);
          final classicGraph = Graph.classicize(graph);
          final reclassicizedGraph = Graph.classicize(classicGraph);

          expect(reclassicizedGraph.triples, equals(classicGraph.triples));
        },
      );
    });

    group('match API', () {
      // More diverse test data
      final s1 = IRINode(IRI('http://example.com/s1'));
      final s2 = BlankNode('b1');
      final p1 = IRINode(IRI('http://example.com/p1'));
      final p2 = IRINode(IRI('http://example.com/p2'));
      final o1 = IRINode(IRI('http://example.com/o1'));
      final o2 = Literal('hello', XSD.string);
      final o3 = Literal('bonjour', RDF.langString, 'fr');
      final o4 = BlankNode('b2');

      final t1 = Triple(s1, p1, o1);
      final t2 = Triple(s1, p1, o2); // Same s, p; different o
      final t3 = Triple(s1, p2, o3); // Same s; different p, o
      final t4 = Triple(s2, p1, o1); // Different s; same p, o
      final t5 = Triple(s2, p2, o4); // Different s, p, o

      setUp(() {
        // Reset graph and add diverse triples for each test in this group
        graph = Graph();
        graph.addAll([t1, t2, t3, t4, t5]);
      });

      group('match', () {
        test('match(S, P, O) returns specific triple', () {
          final result = graph.match(s1, p1, o1).toSet();
          expect(result, equals({t1}));
        });

        test('match(S, P, O) returns empty set if triple not present', () {
          final nonExistentObject = Literal('goodbye', XSD.string);
          final result = graph.match(s1, p1, nonExistentObject).toSet();
          expect(result, isEmpty);
        });

        test('match(S, P, null) returns triples with specific S and P', () {
          final result = graph.match(s1, p1, null).toSet();
          expect(result, equals({t1, t2}));
        });

        test('match(S, null, O) returns triples with specific S and O', () {
          final result = graph.match(s1, null, o1).toSet();
          expect(result, equals({t1})); // Only t1 matches s1 and o1
        });

        test('match(null, P, O) returns triples with specific P and O', () {
          final result = graph.match(null, p1, o1).toSet();
          expect(result, equals({t1, t4}));
        });

        test('match(S, null, null) returns triples with specific S', () {
          final result = graph.match(s1, null, null).toSet();
          expect(result, equals({t1, t2, t3}));
        });

        test('match(null, P, null) returns triples with specific P', () {
          final result = graph.match(null, p1, null).toSet();
          expect(result, equals({t1, t2, t4}));
        });

        test('match(null, null, O) returns triples with specific O', () {
          final result = graph.match(null, null, o1).toSet();
          expect(result, equals({t1, t4}));
        });

        test(
          'match(null, null, O) returns triples with specific Literal O',
          () {
            final result = graph.match(null, null, o2).toSet();
            expect(result, equals({t2}));
          },
        );

        test('match(null, null, O) returns triples with specific BNode O', () {
          final result = graph.match(null, null, o4).toSet();
          expect(result, equals({t5}));
        });

        test('match(null, null, null) returns all triples', () {
          final result = graph.match(null, null, null).toSet();
          expect(result, equals({t1, t2, t3, t4, t5}));
        });

        test('match returns empty set for non-matching pattern', () {
          final nonExistentSubject = IRINode(IRI('http://example.com/s_none'));
          final result = graph.match(nonExistentSubject, null, null).toSet();
          expect(result, isEmpty);
        });
      });

      group('subjects', () {
        test('returns unique subjects matching P and O', () {
          final result = graph.subjects(predicate: p1, object: o1).toSet();
          expect(result, equals({s1, s2}));
        });

        test('returns unique subjects matching P', () {
          final result = graph.subjects(predicate: p1).toSet();
          expect(result, equals({s1, s2}));
        });

        test('returns unique subjects matching O', () {
          final result = graph.subjects(object: o1).toSet();
          expect(result, equals({s1, s2}));
        });

        test('returns empty set when no subjects match', () {
          final nonExistentPredicate = IRINode(
            IRI('http://example.com/p_none'),
          );
          final result =
              graph.subjects(predicate: nonExistentPredicate).toSet();
          expect(result, isEmpty);
        });
      });

      group('predicates', () {
        test('returns unique predicates matching S and O', () {
          final result = graph.predicates(subject: s1, object: o1).toSet();
          expect(result, equals({p1}));
        });

        test('returns unique predicates matching S', () {
          final result = graph.predicates(subject: s1).toSet();
          expect(result, equals({p1, p2}));
        });

        test('returns unique predicates matching O', () {
          final result = graph.predicates(object: o1).toSet();
          expect(result, equals({p1}));
        });

        test('returns empty set when no predicates match', () {
          final nonExistentSubject = IRINode(IRI('http://example.com/s_none'));
          final result = graph.predicates(subject: nonExistentSubject).toSet();
          expect(result, isEmpty);
        });
      });

      group('objects', () {
        test('returns unique objects matching S and P', () {
          final result = graph.objects(subject: s1, predicate: p1).toSet();
          expect(result, equals({o1, o2}));
        });

        test('returns unique objects matching S', () {
          final result = graph.objects(subject: s1).toSet();
          expect(result, equals({o1, o2, o3}));
        });

        test('returns unique objects matching P', () {
          final result = graph.objects(predicate: p1).toSet();
          expect(
            result,
            equals({o1, o2}),
          ); // o1 appears twice but result is unique
        });

        test('returns empty set when no objects match', () {
          final nonExistentSubject = IRINode(IRI('http://example.com/s_none'));
          final result = graph.objects(subject: nonExistentSubject).toSet();
          expect(result, isEmpty);
        });
      });

      group('object (singular)', () {
        test('returns the object when exactly one matches S and P', () {
          // Use s1, p2 which only maps to o3
          final result = graph.object(s1, p2);
          expect(result, equals(o3));
        });

        test('returns null when no object matches S and P', () {
          final nonExistentPredicate = IRINode(
            IRI('http://example.com/p_none'),
          );
          final result = graph.object(s1, nonExistentPredicate);
          expect(result, isNull);
        });

        test('throws StateError when multiple objects match S and P', () {
          // Use s1, p1 which maps to o1 and o2
          expect(() => graph.object(s1, p1), throwsStateError);
        });
      });
    });
  });
}
