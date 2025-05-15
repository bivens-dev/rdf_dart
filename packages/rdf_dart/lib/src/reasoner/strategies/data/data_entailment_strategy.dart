import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:iri/iri.dart';
import 'package:rdf_dart/rdf_dart.dart';

class DEntailmentStrategy implements EntailmentStrategy {
  @override
  bool entails(Graph graph1, Graph graph2, {EntailmentOptions? options}) {
    final recognizedDatatypesD = options?.recognizedDatatypes ?? const <IRI>{};

    if (graph2.isGroundGraph && recognizedDatatypesD.isEmpty) {
      // If graph2 is ground and no datatypes are specially recognized by D,
      // this is equivalent to simple entailment's ground graph check.
      for (final tripleG2 in graph2.triples) {
        if (!graph1.contains(tripleG2)) {
          return false;
        }
      }
      return true;
    }
    // If graph2 is ground but recognizedDatatypesD is NOT empty, we still need the D-equivalence check.

    final bNodesInG2List = _collectUniqueBlankNodes(graph2).toList();

    if (bNodesInG2List.isEmpty) {
      // Graph2 is ground (no blank nodes to substitute)
      // We need to check if graph2 is a D-subgraph of graph1
      final g2Instance = graph2; // No substitution needed
      for (final tInstance in g2Instance.triples) {
        if (!_isTripleDSatisfied(tInstance, graph1, recognizedDatatypesD)) {
          return false;
        }
      }
      return true;
    }

    final potentialTargetsInG1 =
        _collectPotentialMappingTargets(graph1).toList();
    final initialMapping = <BlankNode, RdfTerm>{};

    return _findValidMappingAndCheckDSubgraph(
      graph1,
      graph2,
      bNodesInG2List,
      0,
      initialMapping,
      potentialTargetsInG1,
      recognizedDatatypesD,
    );
  }

  @override
  bool isConsistent(Graph graph, {EntailmentOptions? options}) {
    // Given that all datatypes MUST be registered", and given that
    // Literal constructor throws DatatypeNotFoundException for unknown types
    // and InvalidLexicalFormException for ill-typed known types,
    // any Literal object that exists in a successfully constructed Graph
    // is already well-typed with respect to DatatypeRegistry.instance.
    // D-inconsistency as per spec: "contains a literal lit whose datatype IRI is in D
    // and L2V_D(lit) is undefined".
    // If lit.datatype is in D, and lit exists, L2V_Registry(lit) was defined.
    // Assuming L2V_D implies use of the same parsing logic as L2V_Registry for types in D.
    return true;
  }

  @override
  Graph materialize(Graph graph, {EntailmentOptions? options}) {
    // D-entailment does not define additional axiomatic triples.
    // The D-closure is the graph itself if it's D-consistent.
    // Since isConsistent will return true (as per Option A discussion),
    // we return a copy of the graph.
    return Graph()..addAll(graph.triples);
  }

  bool _isTripleDSatisfied(
    Triple tripleToSatisfy,
    Graph satisfyingGraph,
    Set<IRI> recognizedDatatypesD,
  ) {
    if (satisfyingGraph.contains(tripleToSatisfy)) {
      return true;
    }

    final obj = tripleToSatisfy.object;
    if (obj is Literal) {
      final litToSatisfy = obj;
      // Check for D-equivalent literals in satisfyingGraph
      // Iterate over triples in satisfyingGraph that match subject, predicate
      for (final tGraph1 in satisfyingGraph.match(
        tripleToSatisfy.subject,
        tripleToSatisfy.predicate,
        null,
      )) {
        if (tGraph1.object is Literal) {
          final litGraph1 = tGraph1.object as Literal;
          if (_areLiteralsDEquivalent(
            litToSatisfy,
            litGraph1,
            recognizedDatatypesD,
          )) {
            return true; // Found a D-equivalent triple
          }
        }
      }
    }
    return false; // Not satisfied
  }

  bool _areLiteralsDEquivalent(
    Literal litA,
    Literal litB,
    Set<IRI> recognizedDatatypesD,
  ) {
    final dtA = litA.datatype;
    final dtB = litB.datatype;

    final isDtARecognizedInD = recognizedDatatypesD.contains(dtA);
    final isDtBRecognizedInD = recognizedDatatypesD.contains(dtB);

    if (isDtARecognizedInD && isDtBRecognizedInD) {
      // Both datatypes are in D. Values must be defined (which they are by
      // successful Literal construction) and equal.
      final valA = litA.value;
      final valB = litB.value;

      if (valA is Uint8List && valB is Uint8List) {
        return const DeepCollectionEquality().equals(valA, valB);
      }
      // Add other type-specific comparisons if needed, e.g. for custom objects not using == for value semantics
      return valA == valB;
    } else {
      // Condition 2: (datatype(litA) is not in D OR datatype(litB) is not in D)
      // AND litA and litB must be identical RDF literals.
      return litA == litB;
    }
  }

  // --- Helper methods (can be copied from SimpleEntailmentStrategy or refactored into a common utility) ---

  Set<BlankNode> _collectUniqueBlankNodes(Graph graph) {
    final bNodes = <BlankNode>{};
    final visitedTripleTerms = <TripleTerm>{};

    void collectFromTerm(RdfTerm term) {
      if (term.isBlankNode) {
        bNodes.add(term as BlankNode);
      } else if (term.isTripleTerm) {
        final tt = term as TripleTerm;
        if (visitedTripleTerms.contains(tt)) return;
        visitedTripleTerms.add(tt);
        collectFromTerm(tt.triple.subject);
        // Predicates are IRIs
        collectFromTerm(tt.triple.object);
        visitedTripleTerms.remove(
          tt,
        ); // Allow re-visiting through different paths
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
      terms.add(triple.object);
    }
    return terms;
  }

  Graph? _instantiateGraph(Graph graph, Map<BlankNode, RdfTerm> mapping) {
    final instantiatedTriples = <Triple>{};
    final visitedTripleTermsForInstantiation = <TripleTerm>{};

    RdfTerm mapTerm(RdfTerm term) {
      if (term.isBlankNode && mapping.containsKey(term as BlankNode)) {
        return mapping[term]!;
      }
      if (term.isTripleTerm) {
        final tt = term as TripleTerm;
        // Check for cycles during instantiation of nested terms.
        // This is a simple check; complex cycle structures might need more.
        if (visitedTripleTermsForInstantiation.contains(tt)) {
          // This indicates a mapping attempt that leads to a cycle within the same instantiation pass,
          // which likely means an unresolvable structure or a bnode mapping to its own container.
          // Depending on how RDF-star treats such, this could be an error or just a non-match.
          // For now, consider it an invalid path for instantiation.
          return _InvalidInstantiationMarker();
        }
        visitedTripleTermsForInstantiation.add(tt);

        final mappedInnerSubject = mapTerm(tt.triple.subject);
        // Predicate remains as is
        final mappedInnerObject = mapTerm(tt.triple.object);

        visitedTripleTermsForInstantiation.remove(tt); // Backtrack

        if (mappedInnerSubject is! SubjectTerm ||
            mappedInnerSubject is _InvalidInstantiationMarker) {
          return _InvalidInstantiationMarker();
        }
        if (mappedInnerObject is _InvalidInstantiationMarker) {
          return _InvalidInstantiationMarker();
        }

        try {
          return TripleTerm(
            Triple(mappedInnerSubject, tt.triple.predicate, mappedInnerObject),
          );
        } on InvalidTermException {
          // If Triple construction fails due to types
          return _InvalidInstantiationMarker();
        }
      }
      return term;
    }

    for (final triple in graph.triples) {
      final mappedSNode = mapTerm(triple.subject);
      final mappedONode = mapTerm(triple.object);

      if (mappedSNode is! SubjectTerm ||
          mappedSNode is _InvalidInstantiationMarker) {
        return null;
      }
      if (mappedONode is _InvalidInstantiationMarker) {
        return null;
      }
      try {
        instantiatedTriples.add(
          Triple(mappedSNode, triple.predicate, mappedONode),
        );
      } on InvalidTermException {
        // If Triple construction fails
        return null;
      }
    }
    return Graph()..addAll(instantiatedTriples);
  }

  bool _findValidMappingAndCheckDSubgraph(
    Graph graph1,
    Graph graph2,
    List<BlankNode> bNodesToMap,
    int currentBNodeIndex,
    Map<BlankNode, RdfTerm> currentMapping,
    List<RdfTerm> potentialTargets,
    Set<IRI> recognizedDatatypesD,
  ) {
    if (currentBNodeIndex == bNodesToMap.length) {
      final g2Instance = _instantiateGraph(graph2, currentMapping);
      if (g2Instance == null) {
        return false;
      }
      // Check if g2Instance is D-substitutable for graph1
      for (final tInstance in g2Instance.triples) {
        if (!_isTripleDSatisfied(tInstance, graph1, recognizedDatatypesD)) {
          return false;
        }
      }
      return true; // All triples in g2Instance are D-satisfied by graph1
    }

    final bNodeToMap = bNodesToMap[currentBNodeIndex];
    var bNodeUsedAsSubject = false;
    // Check if bNodeToMap is used as a subject (including nested)
    final visitedTripleTermsCheck = <TripleTerm>{};
    bool isBNodeSubject(RdfTerm term, BlankNode targetBNode) {
      if (term == targetBNode) return true; // Top-level subject
      if (term.isTripleTerm) {
        final tt = term as TripleTerm;
        if (visitedTripleTermsCheck.contains(tt)) return false;
        visitedTripleTermsCheck.add(tt);
        final result = isBNodeSubject(tt.triple.subject, targetBNode);
        visitedTripleTermsCheck.remove(tt);
        if (result) return true;
      }
      return false;
    }

    for (final t in graph2.triples) {
      if (isBNodeSubject(t.subject, bNodeToMap)) {
        bNodeUsedAsSubject = true;
        break;
      }
      // Check object position if it can contain subjects (i.e. TripleTerms)
      // This check might be overly complex if not needed but better safe.
      // Simplified: just checking direct subject usage here as per simple_entailment
      if (t.subject == bNodeToMap) {
        bNodeUsedAsSubject = true;
        break;
      }
    }
    // More robust check for subject usage (if blank node appears as subject anywhere)
    bNodeUsedAsSubject = false; // Reset for a cleaner check
    for (final tripleInG2 in graph2.triples) {
      void checkSubjectUsage(RdfTerm term) {
        if (term == bNodeToMap && tripleInG2.subject == term) {
          // Check if it IS the subject
          bNodeUsedAsSubject = true;
        }
        if (term.isTripleTerm) {
          if (bNodeUsedAsSubject) return; // Already found
          checkSubjectUsage((term as TripleTerm).triple.subject);
        }
      }

      checkSubjectUsage(tripleInG2.subject);
      if (bNodeUsedAsSubject) break;
      // A blank node can also be a subject *within* a triple term in object position
      void checkNestedSubjectUsage(RdfTerm term) {
        if (term.isTripleTerm) {
          if (bNodeUsedAsSubject) return;
          final innerTriple = (term as TripleTerm).triple;
          if (innerTriple.subject == bNodeToMap) {
            bNodeUsedAsSubject = true;
            return;
          }
          checkNestedSubjectUsage(innerTriple.object); // Recurse on object
        }
      }

      checkNestedSubjectUsage(tripleInG2.object);
      if (bNodeUsedAsSubject) break;
    }

    for (final targetTerm in potentialTargets) {
      if (bNodeUsedAsSubject && targetTerm.isLiteral) {
        continue;
      }

      currentMapping[bNodeToMap] = targetTerm;
      if (_findValidMappingAndCheckDSubgraph(
        graph1,
        graph2,
        bNodesToMap,
        currentBNodeIndex + 1,
        currentMapping,
        potentialTargets,
        recognizedDatatypesD,
      )) {
        return true;
      }
      currentMapping.remove(bNodeToMap); // Backtrack
    }
    return false;
  }
}

/// Helper marker for _instantiateGraph, similar to SimpleEntailmentStrategy
class _InvalidInstantiationMarker extends RdfTerm {
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
}
