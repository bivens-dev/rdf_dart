
import 'package:iri/iri.dart';
import 'package:rdf_dart/rdf_dart.dart';
// Assuming DEntailmentStrategy will be in a path like this:
import 'package:rdf_dart/src/reasoner/strategies/data/data_entailment_strategy.dart';
import 'package:test/test.dart';

// Helper to create IRIs easily
IRI ex(String localName) => IRI('http://example.org/$localName');
// IRI xsd(String localName) => IRI('http://www.w3.org/2001/XMLSchema#$localName');
// IRI rdf(String localName) =>
//     IRI('http://www.w3.org/1999/02/22-rdf-syntax-ns#$localName');

void main() {
  group('DEntailmentStrategy', () {
    final strategy = DEntailmentStrategy();
    late Graph graph1;
    late Graph graph2;

    final emptyDSet = const <IRI>{};

    group('entails - Ground Graphs (No Blank Nodes)', () {
      setUp(() {
        graph1 = Graph();
        graph2 = Graph();
      });

      test('exact literal match (type in D) should entail', () {
        graph1.add(
          Triple(IRINode(ex('s')), IRINode(ex('p')), Literal('1', XSD.integer)),
        );
        graph2.add(
          Triple(IRINode(ex('s')), IRINode(ex('p')), Literal('1', XSD.integer)),
        );
        final options = EntailmentOptions(recognizedDatatypes: {XSD.integer});
        expect(strategy.entails(graph1, graph2, options: options), isTrue);
      });

      test('exact literal match (type not in D) should entail', () {
        graph1.add(
          Triple(IRINode(ex('s')), IRINode(ex('p')), Literal('1', XSD.integer)),
        );
        graph2.add(
          Triple(IRINode(ex('s')), IRINode(ex('p')), Literal('1', XSD.integer)),
        );
        final options = EntailmentOptions(recognizedDatatypes: emptyDSet);
        expect(strategy.entails(graph1, graph2, options: options), isTrue);
      });

      test('D-equivalent integer literals (type in D) should entail', () {
        graph1.add(
          Triple(IRINode(ex('s')), IRINode(ex('p')), Literal('1', XSD.integer)),
        );
        graph2.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('01', XSD.integer),
          ),
        );
        final options = EntailmentOptions(recognizedDatatypes: {XSD.integer});
        expect(strategy.entails(graph1, graph2, options: options), isTrue);
      });

      test('D-equivalent decimal literals (type in D) should entail', () {
        graph1.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('1.0', XSD.decimal),
          ),
        );
        graph2.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('1.00', XSD.decimal),
          ),
        );
        final options = EntailmentOptions(recognizedDatatypes: {XSD.decimal});
        expect(strategy.entails(graph1, graph2, options: options), isTrue);
      });

      test('D-equivalent double literals (type in D) should entail', () {
        graph1.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('1.0E0', XSD.double),
          ),
        );
        graph2.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('1.0', XSD.double),
          ),
        );
        final options = EntailmentOptions(
          recognizedDatatypes: {XSD.double},
        );
        expect(strategy.entails(graph1, graph2, options: options), isTrue);
      });

      test('D-equivalent boolean literals (1/0, type in D) should entail', () {
        graph1.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('true', XSD.boolean),
          ),
        );
        graph2.add(
          Triple(IRINode(ex('s')), IRINode(ex('p')), Literal('1', XSD.boolean)),
        );
        final options = EntailmentOptions(recognizedDatatypes: {XSD.boolean});
        expect(strategy.entails(graph1, graph2, options: options), isTrue);
      });

      test(
        'D-equivalent boolean literals (0/false, type in D) should entail',
        () {
          graph1.add(
            Triple(
              IRINode(ex('s')),
              IRINode(ex('p')),
              Literal('0', XSD.boolean),
            ),
          );
          graph2.add(
            Triple(
              IRINode(ex('s')),
              IRINode(ex('p')),
              Literal('false', XSD.boolean),
            ),
          );
          final options = EntailmentOptions(recognizedDatatypes: {XSD.boolean});
          expect(strategy.entails(graph1, graph2, options: options), isTrue);
        },
      );

      test(
        'D-equivalent hexBinary literals (case diff, type in D) should entail',
        () {
          graph1.add(
            Triple(
              IRINode(ex('s')),
              IRINode(ex('p')),
              Literal('AABB', XSD.hexBinary),
            ),
          );
          graph2.add(
            Triple(
              IRINode(ex('s')),
              IRINode(ex('p')),
              Literal('aabb', XSD.hexBinary),
            ),
          );
          final options = EntailmentOptions(
            recognizedDatatypes: {XSD.hexBinary},
          );
          expect(strategy.entails(graph1, graph2, options: options), isTrue);
        },
      );

      test('Different hexBinary literals (type in D) should NOT entail', () {
        graph1.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('AABBCC', XSD.hexBinary),
          ),
        );
        graph2.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('aabbdd', XSD.hexBinary),
          ),
        );
        final options = EntailmentOptions(recognizedDatatypes: {XSD.hexBinary});
        expect(strategy.entails(graph1, graph2, options: options), isFalse);
      });

      test(
        'Syntactically different integers (type NOT in D) should NOT entail',
        () {
          graph1.add(
            Triple(
              IRINode(ex('s')),
              IRINode(ex('p')),
              Literal('1', XSD.integer),
            ),
          );
          graph2.add(
            Triple(
              IRINode(ex('s')),
              IRINode(ex('p')),
              Literal('01', XSD.integer),
            ),
          );
          final options = EntailmentOptions(
            recognizedDatatypes: emptyDSet,
          ); // XSD.integer not in D
          expect(strategy.entails(graph1, graph2, options: options), isFalse);
        },
      );

      test('Different value integers (type in D) should NOT entail', () {
        graph1.add(
          Triple(IRINode(ex('s')), IRINode(ex('p')), Literal('1', XSD.integer)),
        );
        graph2.add(
          Triple(IRINode(ex('s')), IRINode(ex('p')), Literal('2', XSD.integer)),
        );
        final options = EntailmentOptions(recognizedDatatypes: {XSD.integer});
        expect(strategy.entails(graph1, graph2, options: options), isFalse);
      });

      test(
        'Same value, different recognized types (both in D) should NOT entail by D-equivalence',
        () {
          // "1"^^xsd:integer vs "1.0"^^xsd:decimal
          // Their values might be numerically equal, but D-equivalence requires same datatype for value comparison.
          // The _areLiteralsDEquivalent first checks if dtA == dtB if both are in D.
          // Let's refine _areLiteralsDEquivalent for this:
          // if (isDtARecognizedInD && isDtBRecognizedInD) {
          //   if (dtA == dtB) { /* compare values */ } else { return false; } ... }
          // For now, assuming current _areLiteralsDEquivalent implicitly means dtA must == dtB
          // because you get litA.value and litB.value using their respective datatypes.
          // If dtA != dtB, then litA != litB syntactically, and they won't use the value comparison path *against each other*.
          // Test this understanding:
          graph1.add(
            Triple(
              IRINode(ex('s')),
              IRINode(ex('p')),
              Literal('1', XSD.integer),
            ),
          );
          graph2.add(
            Triple(
              IRINode(ex('s')),
              IRINode(ex('p')),
              Literal('1.0', XSD.decimal),
            ),
          ); // Different datatype
          final options = EntailmentOptions(
            recognizedDatatypes: {XSD.integer, XSD.decimal},
          );
          expect(strategy.entails(graph1, graph2, options: options), isFalse);
        },
      );

      test(
        'G1 has general, G2 has specific (both in D, values equal) - e.g. decimal vs integer',
        () {
          // This depends on how specific values are typed.
          // "1"^^xsd:decimal can entail "1"^^xsd:integer if both are in D,
          // and their values are equal and comparison is valid.
          // BigInt(1) == Decimal.parse('1') might be true depending on Decimal package.
          // Let's assume they compare well for this test.
          // RDF Semantics: "L2V_D(lit) = L2V_D(lit')" - it doesn't explicitly forbid dt(lit) != dt(lit') here.
          // But it implies values from their respective value spaces.
          // Example dt-val from spec: "1"^^xsd:integer D-entails "1.0"^^xsd:float if both in D.
          // Our current _areLiteralsDEquivalent requires dtA == dtB if both recognized. Let's assume that's a library design choice.
          // If so, this should be false. If we change _areLiteralsDEquivalent to allow value comparison across different D-recognized types, this might pass.
          // Based on current strategy draft (which implies dtA==dtB for value path):
          graph1.add(
            Triple(
              IRINode(ex('s')),
              IRINode(ex('p')),
              Literal('1', XSD.decimal),
            ),
          );
          graph2.add(
            Triple(
              IRINode(ex('s')),
              IRINode(ex('p')),
              Literal('1', XSD.integer),
            ),
          );
          final options = EntailmentOptions(
            recognizedDatatypes: {XSD.decimal, XSD.integer},
          );
          expect(
            strategy.entails(graph1, graph2, options: options),
            isFalse,
            reason:
                'Current _areLiteralsDEquivalent implies datatypes must be same for value comparison path',
          );

          // If _areLiteralsDEquivalent was changed to:
          // if (isDtARecognizedInD && isDtBRecognizedInD) { /* compare values */ }
          // Then this might be true if BigInt(1) compared equal to Decimal.parse("1") etc.
          // This is a point for clarification based on precise spec interpretation vs. impl. choice.
        },
      );

      test('G1 is missing a triple from G2, should NOT entail', () {
        graph1.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p1')),
            Literal('1', XSD.integer),
          ),
        );
        graph2.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p1')),
            Literal('1', XSD.integer),
          ),
        );
        graph2.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p2')),
            Literal('2', XSD.integer),
          ),
        ); // This one is missing in G1
        final options = EntailmentOptions(recognizedDatatypes: {XSD.integer});
        expect(strategy.entails(graph1, graph2, options: options), isFalse);
      });
    });

    group('entails - With Blank Nodes', () {
      setUp(() {
        graph1 = Graph();
        graph2 = Graph();
      });

      test('Simple bnode substitution leading to D-equivalent literal', () {
        graph1.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('10', XSD.integer),
          ),
        );
        graph1.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('20', XSD.integer),
          ),
        );

        final b1 = BlankNode();
        graph2.add(
          Triple(b1, IRINode(ex('p')), Literal('010', XSD.integer)),
        ); // Map b1 to s1

        final options = EntailmentOptions(recognizedDatatypes: {XSD.integer});
        expect(strategy.entails(graph1, graph2, options: options), isTrue);
      });

      test('Bnode substitution fails if no D-equivalent literal found', () {
        graph1.add(
          Triple(
            IRINode(ex('s1')),
            IRINode(ex('p')),
            Literal('10', XSD.integer),
          ),
        );
        final b1 = BlankNode();
        graph2.add(
          Triple(b1, IRINode(ex('p')), Literal('11', XSD.integer)),
        ); // No match for "11"

        final options = EntailmentOptions(recognizedDatatypes: {XSD.integer});
        expect(strategy.entails(graph1, graph2, options: options), isFalse);
      });

      test('Multiple bnodes, requiring specific D-equivalent mappings', () {
        graph1.add(
          Triple(
            IRINode(ex('s1')),
            IRINode(ex('p')),
            Literal('1', XSD.integer),
          ),
        );
        graph1.add(
          Triple(
            IRINode(ex('s1')),
            IRINode(ex('q')),
            Literal(' एप्पल ', XSD.string),
          ),
        ); // Note spaces
        graph1.add(
          Triple(
            IRINode(ex('s2')),
            IRINode(ex('p')),
            Literal('2', XSD.integer),
          ),
        );
        graph1.add(
          Triple(
            IRINode(ex('s2')),
            IRINode(ex('q')),
            Literal('orange', XSD.string),
          ),
        );

        final bA = BlankNode();
        final bB = BlankNode();
        graph2.add(
          Triple(bA, IRINode(ex('p')), Literal('01', XSD.integer)),
        ); // Needs s1
        graph2.add(
          Triple(bA, IRINode(ex('q')), Literal(' एप्पल ', XSD.string)),
        ); // Needs s1, exact string match
        graph2.add(
          Triple(bB, IRINode(ex('p')), Literal('002', XSD.integer)),
        ); // Needs s2
        graph2.add(
          Triple(bB, IRINode(ex('q')), Literal('orange', XSD.string)),
        ); // Needs s2

        final options = EntailmentOptions(
          recognizedDatatypes: {XSD.integer, XSD.string},
        );
        expect(strategy.entails(graph1, graph2, options: options), isTrue);
      });

      test('Multiple bnodes, one mapping path fails D-equivalence', () {
        graph1.add(
          Triple(
            IRINode(ex('s1')),
            IRINode(ex('p')),
            Literal('1', XSD.integer),
          ),
        );
        graph1.add(
          Triple(
            IRINode(ex('s1')),
            IRINode(ex('q')),
            Literal('apple', XSD.string),
          ),
        );
        graph1.add(
          Triple(
            IRINode(ex('s2')),
            IRINode(ex('p')),
            Literal('2', XSD.integer),
          ),
        );
        graph1.add(
          Triple(
            IRINode(ex('s2')),
            IRINode(ex('q')),
            Literal('orange', XSD.string),
          ),
        );

        final bA = BlankNode();
        final bB = BlankNode();
        graph2.add(Triple(bA, IRINode(ex('p')), Literal('01', XSD.integer)));
        graph2.add(Triple(bA, IRINode(ex('q')), Literal('apple', XSD.string)));
        graph2.add(Triple(bB, IRINode(ex('p')), Literal('002', XSD.integer)));
        graph2.add(
          Triple(bB, IRINode(ex('q')), Literal('banana', XSD.string)),
        ); // This will fail for s2

        final options = EntailmentOptions(
          recognizedDatatypes: {XSD.integer, XSD.string},
        );
        expect(strategy.entails(graph1, graph2, options: options), isFalse);
      });
    });

    group('isConsistent', () {
      test('should return true even with empty D set', () {
        graph1.add(
          Triple(IRINode(ex('s')), IRINode(ex('p')), Literal('1', XSD.integer)),
        );
        final options = EntailmentOptions(recognizedDatatypes: emptyDSet);
        expect(strategy.isConsistent(graph1, options: options), isTrue);
      });
    });

    group('materialize', () {
      test('should return a copy of the graph', () {
        graph1.add(
          Triple(
            IRINode(ex('s')),
            IRINode(ex('p')),
            Literal('val', XSD.string),
          ),
        );
        graph1.add(
          Triple(IRINode(ex('s')), IRINode(ex('q')), IRINode(ex('o'))),
        );

        final materializedGraph = strategy.materialize(graph1);
        expect(materializedGraph.triples, equals(graph1.triples));
        expect(identical(materializedGraph, graph1), isFalse); // Must be a copy
      });
    });
  });
}
