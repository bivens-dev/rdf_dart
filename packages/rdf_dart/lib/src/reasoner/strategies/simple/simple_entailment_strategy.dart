import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/graph.dart';
import 'package:rdf_dart/src/model/rdf_term.dart';
import 'package:rdf_dart/src/model/subject_type.dart';
import 'package:rdf_dart/src/model/term_type.dart';
import 'package:rdf_dart/src/model/triple.dart';
import 'package:rdf_dart/src/model/triple_term.dart';
import 'package:rdf_dart/src/reasoner/strategies/entailment_options.dart';
import 'package:rdf_dart/src/reasoner/strategies/entailment_strategy.dart';

class SimpleEntailmentStrategy implements EntailmentStrategy {
  @override
  bool entails(Graph graph1, Graph graph2, {EntailmentOptions? options}) {
    // If there are no blank nodes in graph2 we just need to make 
    // sure graph1 has all the same triples in it.
    if (graph2.isGroundGraph) {
      return graph1.triples.containsAll(graph2.triples);
    }

    final bNodesInG2List = _collectUniqueBlankNodes(graph2).toList();

    // `graph2` has blank nodes, need to find a mapping
    final potentialTargetsInG1 = _collectPotentialMappingTargets(graph1).toList();
    
    // Optimization: if `graph2` has more distinct blank nodes than `graph1` has terms,
    // a valid injective mapping for some interpretations of entailment might be impossible.
    // However, simple entailment allows multiple bNodes in `graph2` to map to the same term in `graph1`.

    final initialMapping = <BlankNode, RdfTerm>{};

    return _findValidMappingAndCheckSubgraph(
        graph1, graph2, bNodesInG2List, 0, initialMapping, potentialTargetsInG1);
  }

  @override
  bool isConsistent(Graph graph, {EntailmentOptions? options}) {
    // According to RDF Semantics (Section 5.3), "Every graph is simply satisfiable."
    // This implies every graph is consistent under Simple Entailment.
    return true;
  }

  @override
  Graph materialize(Graph graph1, {EntailmentOptions? options}) {
    // Simple entailment, as per the Interpolation Lemma, does not add new triples
    // beyond what's already in `graph1` through blank node mappings.
    // No new axiomatic triples are part of simple entailment itself.
    // It's conventional to return the graph itself or an equivalent copy.
    return Graph()..addAll(graph1.triples); // Return a copy
  }

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

  Set<RdfTerm> _collectPotentialMappingTargets(Graph graph) {
    final terms = <RdfTerm>{};
    for (final triple in graph.triples) {
      terms.add(triple.subject);
      terms.add(triple.object); // Object can be IRI, BlankNode, Literal, or TripleTerm
    }
    return terms;
  }

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

          if (mappedInnerSubject is! SubjectTerm) return _RdfTermMarker.marker(); // Invalid
          return TripleTerm(Triple(mappedInnerSubject, tt.triple.predicate, mappedInnerObject));
        }
        return term;
      }

      final mappedSNode = mapTerm(triple.subject);
      final mappedONode = mapTerm(triple.object);

      if (mappedSNode is! SubjectTerm) return null; // Literals cannot be subjects
      if (mappedONode is _RdfTermMarker) return null; // Invalid recursive instantiation

      instantiatedTriples.add(Triple(mappedSNode, triple.predicate, mappedONode));
    }
    return Graph()..addAll(instantiatedTriples);
  }

  bool _findValidMappingAndCheckSubgraph(
    Graph graph1,
    Graph graph2, // The original graph to be entailed (contains bNodes from bNodesToMap)
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
        while(currentObject.isTripleTerm) {
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
          graph1, graph2, bNodesToMap, currentBNodeIndex + 1, currentMapping, potentialTargets)) {
        return true;
      }
      // Backtrack: Remove the mapping for the current bNode before trying the next targetTerm.
      currentMapping.remove(bNodeToMap); 
    }
    return false; 
  }
}

// Helper marker class for _instantiateGraph to signal invalid recursive mapping
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
  TermType get termType => throw UnimplementedError(); // Should not be needed
  
  // Private constructor
  _RdfTermMarker._();
  static _RdfTermMarker marker() => _RdfTermMarker._();
}
