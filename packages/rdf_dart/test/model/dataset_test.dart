import 'package:iri/iri.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Dataset', () {
    late Dataset dataset;
    late IRINode iriGraphName;
    late Graph graph;

    // New setup for blank node graph names
    late BlankNode blankNodeGraphName1;
    late BlankNode blankNodeGraphName2; // A distinct blank node
    late BlankNode sameIdAsblankNodeGraphName1; // A different instance but with same ID

    // Common RDF terms for various tests
    final s1 = IRINode(IRI('http://example.com/s1'));
    final p1 = IRINode(IRI('http://example.com/p1'));
    final o1 = IRINode(IRI('http://example.com/o1'));
    final p2 = IRINode(IRI('http://example.com/p2'));
    // An IRI for a second named graph, if needed for sharing tests
    final iriGraphName2 = IRINode(IRI('http://example.com/graph2'));

    setUp(() {
      dataset = Dataset();
      iriGraphName = IRINode(IRI('http://example.com/graph'));
      graph = Graph();
      blankNodeGraphName1 = BlankNode('bnode1');
      blankNodeGraphName2 = BlankNode('bnode2');
      sameIdAsblankNodeGraphName1 = BlankNode('bnode1'); // Different object, same ID
    });

    group('Creation', () {
      test('creates an empty dataset with an empty default graph', () {
        expect(dataset.defaultGraph.triples, isEmpty);
        expect(dataset.namedGraphs, isEmpty);
      });

      test('creates an empty dataset with an empty default graph', () {
        expect(dataset.defaultGraph.triples, isEmpty);
        expect(dataset.namedGraphs, isEmpty);
      });
    });

    group('addNamedGraph', () {
      test('adds a named graph to the dataset with an IRI graph name', () {
        dataset.addNamedGraph(iriGraphName, graph);
        expect(dataset.namedGraphs, containsValue(graph));
        expect(dataset.namedGraphs.containsKey(iriGraphName), true);
        expect(dataset.namedGraphs.length, 1);
      });

      test('replaces an existing named graph with the same IRI name', () {
        final newGraph = Graph();
        dataset.addNamedGraph(iriGraphName, graph);
        dataset.addNamedGraph(iriGraphName, newGraph);
        expect(dataset.namedGraphs[iriGraphName], newGraph);
        expect(dataset.namedGraphs.length, 1);
      });

      test('adds a named graph to the dataset with a BlankNode graph name', () {
        dataset.addNamedGraph(blankNodeGraphName1, graph);
        expect(dataset.namedGraphs, containsValue(graph));
        expect(dataset.namedGraphs.containsKey(blankNodeGraphName1), true);
        expect(dataset.namedGraphs.length, 1);
        expect(dataset.namedGraphs[blankNodeGraphName1], graph);
      });

      test('replaces an existing named graph with the same BlankNode instance as name',
          () {
        final newGraph = Graph();
        dataset.addNamedGraph(blankNodeGraphName1, graph); // Add initial graph
        dataset.addNamedGraph(blankNodeGraphName1, newGraph); // Add with same BlankNode instance
        expect(dataset.namedGraphs[blankNodeGraphName1], newGraph);
        expect(dataset.namedGraphs.length, 1);
      });

      test(
          'adds a new named graph if a BlankNode with the same ID but different instance is used as name',
          () {
        final graph1 = Graph()..add(Triple(BlankNode('s'), p1, o1)); // Make graphs distinct for clarity
        final graph2 = Graph()..add(Triple(BlankNode('s'), p2, o1));

        dataset.addNamedGraph(blankNodeGraphName1, graph1);
        // sameIdAsblankNodeGraphName1 has the same ID "bnode1" but is a different object
        dataset.addNamedGraph(sameIdAsblankNodeGraphName1, graph2);

        // Because BlankNode equality is by identity (or by identical ID in this implementation),
        // and the map uses the BlankNode object as key, these should be treated as identical keys.
        // The behavior here depends on how BlankNode equality is implemented and used in the Map.
        // If BlankNode('id1') == BlankNode('id1') is true, then it will replace.
        // If BlankNode equality is by object identity, then it will add a new one.
        // The current rdf_dart BlankNode equality IS based on ID.
        expect(dataset.namedGraphs.length, 1,
            reason:
                'BlankNodes with same ID should be treated as the same key');
        expect(dataset.namedGraphs[blankNodeGraphName1], graph2); // The last one added with that ID wins
        expect(dataset.namedGraphs[sameIdAsblankNodeGraphName1], graph2);
      });


      test('adds distinct named graphs for distinct BlankNode instances as names',
          () {
        final graph2 = Graph();
        dataset.addNamedGraph(blankNodeGraphName1, graph);
        dataset.addNamedGraph(blankNodeGraphName2, graph2); // Different BlankNode instance
        expect(dataset.namedGraphs.length, 2);
        expect(dataset.namedGraphs[blankNodeGraphName1], graph);
        expect(dataset.namedGraphs[blankNodeGraphName2], graph2);
      });
    });

    group('removeNamedGraph', () {
      test('removes a named graph (IRI name) from the dataset', () {
        dataset.addNamedGraph(iriGraphName, graph);
        dataset.removeNamedGraph(iriGraphName);
        expect(dataset.namedGraphs, isNot(containsValue(graph)));
        expect(dataset.namedGraphs.containsKey(iriGraphName), false);
        expect(dataset.namedGraphs, isEmpty);
      });

      test('does nothing if the IRI named graph does not exist', () {
        dataset.removeNamedGraph(iriGraphName);
        expect(dataset.namedGraphs, isEmpty);
      });

      test('removes a named graph (BlankNode name) from the dataset', () {
        dataset.addNamedGraph(blankNodeGraphName1, graph);
        expect(dataset.namedGraphs.containsKey(blankNodeGraphName1), true);
        dataset.removeNamedGraph(blankNodeGraphName1);
        expect(dataset.namedGraphs.containsKey(blankNodeGraphName1), false);
        expect(dataset.namedGraphs, isEmpty);
      });

       test('removeNamedGraph with a different BlankNode instance but same ID also removes the graph', () {
        dataset.addNamedGraph(blankNodeGraphName1, graph);
        expect(dataset.namedGraphs.containsKey(blankNodeGraphName1), true);
        // sameIdAsblankNodeGraphName1 has the same ID as blankNodeGraphName1
        dataset.removeNamedGraph(sameIdAsblankNodeGraphName1);
        expect(dataset.namedGraphs.containsKey(blankNodeGraphName1), false, reason: 'Removal should be by ID equality for BlankNodes');
        expect(dataset.namedGraphs, isEmpty);
      });

      test('does nothing if the BlankNode named graph does not exist', () {
        dataset.addNamedGraph(blankNodeGraphName1, graph); // Add one
        dataset.removeNamedGraph(blankNodeGraphName2); // Try to remove a different one
        expect(dataset.namedGraphs.length, 1);
        expect(dataset.namedGraphs.containsKey(blankNodeGraphName1), true);
      });
    });

    group('defaultGraph', () {
      test('can add triple to the default graph', () {
        final triple = Triple(s1, p1, o1);
        dataset.defaultGraph.add(triple);
        expect(dataset.defaultGraph.triples, contains(triple));
      });
    });

    group('Named Graph Access with Blank Nodes', () {
      test('retrieves correct graph using BlankNode name instance', () {
        dataset.addNamedGraph(blankNodeGraphName1, graph);
        expect(dataset.namedGraphs[blankNodeGraphName1], graph);
      });

      test('retrieves correct graph using a different BlankNode instance with the same ID', () {
        dataset.addNamedGraph(blankNodeGraphName1, graph);
        // sameIdAsblankNodeGraphName1 has ID 'bnode1'
        expect(dataset.namedGraphs[sameIdAsblankNodeGraphName1], graph,
            reason: 'Access should be by ID equality for BlankNodes');
      });

       test('does not retrieve graph using a BlankNode instance with a different ID', () {
        dataset.addNamedGraph(blankNodeGraphName1, graph);
        expect(dataset.namedGraphs[blankNodeGraphName2], isNull);
      });
    });

    group('Blank Node Sharing', () {
      test('BlankNode instance is shared between default graph and a named graph', () {
        final sharedBNode = BlankNode('bShared1');
        final tripleInDefault = Triple(sharedBNode, p1, o1);
        dataset.defaultGraph.add(tripleInDefault);

        final namedGraphContent = Graph();
        final tripleInNamed = Triple(s1, p2, sharedBNode);
        namedGraphContent.add(tripleInNamed);
        dataset.addNamedGraph(iriGraphName, namedGraphContent);

        // Retrieve the triples and check the BlankNode instances
        final retrievedTripleFromDefault = dataset.defaultGraph.triples.firstWhere(
          (t) => t.subject == sharedBNode,
        );
        final retrievedTripleFromNamed = dataset.namedGraphs[iriGraphName]!.triples.firstWhere(
          (t) => t.object == sharedBNode,
        );

        expect(identical(retrievedTripleFromDefault.subject, retrievedTripleFromNamed.object), isTrue,
            reason: 'The same BlankNode instance should be present in both graphs if the same object was used.');
        // Equality check will also pass due to BlankNode ID equality
        expect(retrievedTripleFromDefault.subject == retrievedTripleFromNamed.object, isTrue);
      });

      test('BlankNode instance is shared between two named graphs', () {
        final sharedBNode = BlankNode('bShared2');
        
        final graphA = Graph();
        final tripleInGraphA = Triple(sharedBNode, p1, o1);
        graphA.add(tripleInGraphA);
        dataset.addNamedGraph(iriGraphName, graphA); // Using iriGraphName for graphA

        final graphB = Graph();
        final tripleInGraphB = Triple(s1, p2, sharedBNode);
        graphB.add(tripleInGraphB);
        dataset.addNamedGraph(iriGraphName2, graphB); // Using distinct iriGraphName2 for graphB

        final retrievedTripleFromGraphA = dataset.namedGraphs[iriGraphName]!.triples.first;
        final retrievedTripleFromGraphB = dataset.namedGraphs[iriGraphName2]!.triples.first;
        
        expect(identical(retrievedTripleFromGraphA.subject, retrievedTripleFromGraphB.object), isTrue,
            reason: 'The same BlankNode instance should be present in both named graphs.');
        expect(retrievedTripleFromGraphA.subject == retrievedTripleFromGraphB.object, isTrue);
      });

      test('Different BlankNode instances (even with same ID) are not identical when added separately', () {
        // This test highlights that if you don't use the *same instance*, they aren't identical,
        // even if they are "==" due to ID. This is important for understanding instance sharing vs. value equality.
        final bnodeId = 'bNotSharedInstance';
        final bn1InDefault = BlankNode(bnodeId);
        final tripleInDefault = Triple(bn1InDefault, p1, o1);
        dataset.defaultGraph.add(tripleInDefault);

        final namedGraphContent = Graph();
        final bn2InNamed = BlankNode(bnodeId); // Different instance, same ID
        final tripleInNamed = Triple(s1, p2, bn2InNamed);
        namedGraphContent.add(tripleInNamed);
        dataset.addNamedGraph(iriGraphName, namedGraphContent);

        final retrievedTripleFromDefault = dataset.defaultGraph.triples.first;
        final retrievedTripleFromNamed = dataset.namedGraphs[iriGraphName]!.triples.first;

        expect(retrievedTripleFromDefault.subject == retrievedTripleFromNamed.object, isTrue, 
            reason: 'BlankNodes with same ID should be equal.');
        expect(identical(retrievedTripleFromDefault.subject, retrievedTripleFromNamed.object), isFalse,
            reason: 'Different BlankNode instances were used, so they should not be identical.');
      });
    });
  });
}
