import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/graph.dart';
import 'package:rdf_dart/src/model/rdf_term.dart';
import 'package:rdf_dart/src/model/subject_type.dart';
import 'package:rdf_dart/src/model/term_type.dart';
import 'package:rdf_dart/src/model/triple.dart';
import 'package:rdf_dart/src/model/triple_term.dart';
import 'package:rdf_dart/src/reasoner/strategies/entailment_options.dart';
import 'package:rdf_dart/src/reasoner/strategies/entailment_strategy.dart';

/// Implements the Simple Entailment strategy as defined in the RDF 1.1 Semantics.
///
/// Simple entailment is a basic form of entailment that primarily considers
/// the structural matching of triples after mapping blank nodes in the entailed
/// graph (graph2) to terms in the entailing graph (graph1).
class SimpleEntailmentStrategy implements EntailmentStrategy {
  /// Determines if [graph1] simply entails [graph2].
  ///
  /// Simple entailment holds if there is a mapping from blank nodes in [graph2]
  /// to terms in [graph1] such that every triple in the instantiated [graph2]
  /// is also present in [graph1].
  ///
  /// The [options] parameter is not used in simple entailment but is included
  /// for interface consistency.
  @override
  bool entails(Graph graph1, Graph graph2, {EntailmentOptions? options}) {
    // If there are no blank nodes in graph2 we just need to make
    // sure graph1 has all the same triples in it.
    if (graph2.isGroundGraph) {
      return graph1.triples.containsAll(graph2.triples);
    }

    final bNodesInG2List = _collectUniqueBlankNodes(graph2).toList();

    // `graph2` has blank nodes, need to find a mapping
    final potentialTargetsInG1 =
        _collectPotentialMappingTargets(graph1).toList();

    // Optimization: if `graph2` has more distinct blank nodes than `graph1` has terms,
    // a valid injective mapping for some interpretations of entailment might be impossible.
    // However, simple entailment allows multiple bNodes in `graph2` to map to the same term in `graph1`.

    final initialMapping = <BlankNode, RdfTerm>{};

    return _findValidMappingAndCheckSubgraph(
      graph1,
      graph2,
      bNodesInG2List,
      0,
      initialMapping,
      potentialTargetsInG1,
    );
  }

  /// Checks if a [graph] is consistent under Simple Entailment.
  ///
  /// According to RDF Semantics (Section 5.3), "Every graph is simply satisfiable."
  /// This implies every graph is consistent under Simple Entailment.
  /// The [options] parameter is not used.
  @override
  bool isConsistent(Graph graph, {EntailmentOptions? options}) {
    // According to RDF Semantics (Section 5.3), "Every graph is simply satisfiable."
    // This implies every graph is consistent under Simple Entailment.
    return true;
  }

  /// Materializes the simple entailments of [graph1].
  ///
  /// Simple entailment, as per the Interpolation Lemma, does not add new triples
  /// beyond what's already in `graph1` through blank node mappings.
  /// No new axiomatic triples are part of simple entailment itself.
  /// It's conventional to return the graph itself or an equivalent copy.
  /// The [options] parameter is not used.
  @override
  Graph materialize(Graph graph1, {EntailmentOptions? options}) {
    // Simple entailment, as per the Interpolation Lemma, does not add new triples
    // beyond what's already in `graph1` through blank node mappings.
    // No new axiomatic triples are part of simple entailment itself.
    // It's conventional to return the graph itself or an equivalent copy.
    return Graph()..addAll(graph1.triples); // Return a copy
  }

  /// Collects all unique blank nodes present in the subject or object positions
  /// of triples within the given [graph], including those nested within triple terms.
  Set<BlankNode> _collectUniqueBlankNodes(Graph graph) {
    final bNodes = <BlankNode>{};

    void collectFromTerm(RdfTerm term) {
      if (term.isBlankNode) {
        bNodes.add(term as BlankNode);
      } else if (term.isTripleTerm) {
        final tt = term as TripleTerm;
        collectFromTerm(tt.triple.subject);
        // Predicates are IRIs, not blank nodes.
        collectFromTerm(tt.triple.object);
      }
    }

    for (final triple in graph.triples) {
      collectFromTerm(triple.subject);
      collectFromTerm(triple.object);
    }
    return bNodes;
  }

  /// Collects all unique RDF terms that appear as subjects or objects in the
  /// triples of the given [graph]. These terms are potential targets for
  /// mapping blank nodes from another graph.
  Set<RdfTerm> _collectPotentialMappingTargets(Graph graph) {
    final terms = <RdfTerm>{};
    for (final triple in graph.triples) {
      terms.add(triple.subject);
      terms.add(
        triple.object,
      ); // Object can be IRI, BlankNode, Literal, or TripleTerm
    }
    return terms;
  }

  /// Instantiates a [graph] by replacing its blank nodes according to the
  /// provided [mapping].
  ///
  /// Returns a new [Graph] with the mapped triples, or `null` if the mapping
  /// results in an invalid triple structure (e.g., a literal as a subject).
  Graph? _instantiateGraph(Graph graph, Map<BlankNode, RdfTerm> mapping) {
    final instantiatedTriples = <Triple>{};
    for (final triple in graph.triples) {
      RdfTerm mapTerm(RdfTerm term) {
        if (term.isBlankNode && mapping.containsKey(term as BlankNode)) {
          return mapping[term]!;
        }
        if (term.isTripleTerm) {
          final tt = term as TripleTerm;
          final mappedInnerSubject = mapTerm(tt.triple.subject);
          // Predicate remains as is (must be IRI)
          final mappedInnerObject = mapTerm(tt.triple.object);

          if (mappedInnerSubject is! SubjectTerm) {
            return _RdfTermMarker(); // Invalid
          }
          return TripleTerm(
            Triple(mappedInnerSubject, tt.triple.predicate, mappedInnerObject),
          );
        }
        return term;
      }

      final mappedSNode = mapTerm(triple.subject);
      final mappedONode = mapTerm(triple.object);

      if (mappedSNode is! SubjectTerm) {
        return null; // Literals cannot be subjects
      }
      if (mappedONode is _RdfTermMarker) {
        return null; // Invalid recursive instantiation
      }

      instantiatedTriples.add(
        Triple(mappedSNode, triple.predicate, mappedONode),
      );
    }
    return Graph()..addAll(instantiatedTriples);
  }

  /// Recursively searches for a valid mapping of blank nodes from [bNodesToMap]
  /// (originating from [graph2]) to terms in [potentialTargets] (originating from [graph1])
  /// such that the instantiated [graph2] is a subgraph of [graph1].
  ///
  /// - [graph1]: The graph that potentially entails [graph2].
  /// - [graph2]: The graph being checked for entailment (contains blank nodes).
  /// - [bNodesToMap]: A list of unique blank nodes from [graph2] that need mapping.
  /// - [currentBNodeIndex]: The index of the current blank node in [bNodesToMap] to map.
  /// - [currentMapping]: The current mapping of blank nodes to RDF terms.
  /// - [potentialTargets]: A list of RDF terms from [graph1] that can be targets for mapping.
  ///
  /// Returns `true` if a valid mapping is found and the subgraph condition is met,
  /// `false` otherwise.
  bool _findValidMappingAndCheckSubgraph(
    Graph graph1,
    Graph
    graph2, // The original graph to be entailed (contains bNodes from bNodesToMap)
    List<BlankNode> bNodesToMap,
    int currentBNodeIndex,
    Map<BlankNode, RdfTerm> currentMapping,
    List<RdfTerm> potentialTargets,
  ) {
    if (currentBNodeIndex == bNodesToMap.length) {
      final g2Instance = _instantiateGraph(graph2, currentMapping);
      if (g2Instance == null) {
        return false; // Mapping led to an invalid triple structure
      }
      // Check if G2Instance is a subgraph of `graph1`
      for (final tInstance in g2Instance.triples) {
        if (!graph1.contains(tInstance)) {
          return false;
        }
      }
      return true; // All triples in G2Instance found in `graph1``
    }

    final bNodeToMap = bNodesToMap[currentBNodeIndex];

    // Optimization: Check if this bNode is used as a subject anywhere in `graph2`.
    // If so, it cannot be mapped to a Literal.
    var bNodeUsedAsSubject = false;
    for (final t in graph2.triples) {
      if (t.subject == bNodeToMap) {
        bNodeUsedAsSubject = true;
        break;
      }
      // Also check if it's a subject in a nested TripleTerm
      var currentObject = t.object;
      while (currentObject.isTripleTerm) {
        final inner = (currentObject as TripleTerm).triple;
        if (inner.subject == bNodeToMap) {
          bNodeUsedAsSubject = true;
          break;
        }
        currentObject = inner.object;
      }
      if (bNodeUsedAsSubject) break;
    }

    for (final targetTerm in potentialTargets) {
      if (bNodeUsedAsSubject && targetTerm.isLiteral) {
        continue; // Skip mapping this bNode to a Literal if it's used as a subject
      }

      currentMapping[bNodeToMap] = targetTerm;
      if (_findValidMappingAndCheckSubgraph(
        graph1,
        graph2,
        bNodesToMap,
        currentBNodeIndex + 1,
        currentMapping,
        potentialTargets,
      )) {
        return true;
      }
      // Backtrack: Remove the mapping for the current bNode before trying the next targetTerm.
      currentMapping.remove(bNodeToMap);
    }
    return false;
  }
}

/// A helper marker class used within [SimpleEntailmentStrategy._instantiateGraph] to signal an invalid
/// recursive mapping that would lead to an ill-typed RDF term (e.g., a literal
/// as a subject within a nested triple term).
class _RdfTermMarker extends RdfTerm {
  @override
  bool get isBlankNode => false;
  @override
  bool get isIRI => false;
  @override
  bool get isLiteral => false;
  @override
  bool get isTripleTerm => false;
  @override
  TermType get termType =>
      throw UnimplementedError('Marker term should not expose TermType');

  _RdfTermMarker();
}
