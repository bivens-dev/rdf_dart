import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:iri/iri.dart';
import 'package:rdf_dart/src/exceptions/exceptions.dart';
import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/graph.dart';
import 'package:rdf_dart/src/model/literal.dart';
import 'package:rdf_dart/src/model/rdf_term.dart';
import 'package:rdf_dart/src/model/subject_type.dart';
import 'package:rdf_dart/src/model/term_type.dart';
import 'package:rdf_dart/src/model/triple.dart';
import 'package:rdf_dart/src/model/triple_term.dart';
import 'package:rdf_dart/src/reasoner/strategies/entailment_options.dart';
import 'package:rdf_dart/src/reasoner/strategies/entailment_strategy.dart';

/// Implements the D-entailment strategy for RDF graphs.
///
/// D-entailment extends simple entailment by considering D-equivalence of literals,
/// where D is a set of recognized datatypes.
class DEntailmentStrategy implements EntailmentStrategy {
  @override
  bool entails(Graph graph1, Graph graph2, {EntailmentOptions? options}) {
    // Get the set of datatypes specifically recognized by D-entailment from options.
    final recognizedDatatypesD = options?.recognizedDatatypes ?? const <IRI>{};

    // Optimization: If graph2 is ground (no blank nodes) and no datatypes are
    // specially recognized by D, this reduces to a simple subgraph check,
    // similar to simple entailment's ground graph case.
    if (graph2.isGroundGraph && recognizedDatatypesD.isEmpty) {
      for (final tripleG2 in graph2.triples) {
        // If any triple in graph2 is not present in graph1, graph1 does not entail graph2.
        if (!graph1.contains(tripleG2)) {
          return false;
        }
      }
      // If all triples in graph2 are in graph1, graph1 entails graph2.
      return true;
    }
    // If graph2 is ground but recognizedDatatypesD is NOT empty, we still
    // need to perform the D-equivalence check for literals.

    // Collect all unique blank nodes in graph2. These are the terms we need to map.
    final bNodesInG2List = _collectUniqueBlankNodes(graph2).toList();

    // If there are no blank nodes in graph2, it is a ground graph.
    // We just need to check if graph2 is a D-subgraph of graph1.
    if (bNodesInG2List.isEmpty) {
      final g2Instance = graph2; // No substitution needed for a ground graph.
      for (final tInstance in g2Instance.triples) {
        // Check if each triple in graph2 is D-satisfied by graph1.
        if (!_isTripleDSatisfied(tInstance, graph1, recognizedDatatypesD)) {
          return false; // If any triple is not D-satisfied, graph1 does not entail graph2.
        }
      }
      return true; // All triples are D-satisfied.
    }

    // If graph2 contains blank nodes, we need to find a mapping from the blank
    // nodes in graph2 to terms in graph1 such that the instantiated graph2 is
    // a D-subgraph of graph1.

    // Collect potential target terms in graph1 for the blank nodes in graph2.
    // These are all the terms (IRIs, BlankNodes, Literals, TripleTerms) in graph1.
    final potentialTargetsInG1 =
        _collectPotentialMappingTargets(graph1).toList();
    // Initialize an empty mapping.
    final initialMapping = <BlankNode, RdfTerm>{};

    // Start the recursive search for a valid mapping and check for D-subgraph.
    return _findValidMappingAndCheckDSubgraph(
      graph1, // The graph to check against (the entailing graph).
      graph2, // The graph to be entailed.
      bNodesInG2List, // List of blank nodes in graph2 to map.
      0, // Start mapping from the first blank node.
      initialMapping, // The current mapping being built.
      potentialTargetsInG1, // Possible terms in graph1 to map to.
      recognizedDatatypesD, // The set of datatypes recognized by D-entailment.
    );
  }

  @override
  bool isConsistent(Graph graph, {EntailmentOptions? options}) {
    // Based on the assumption that the Literal constructor enforces
    // datatype validity upon creation. If a Literal object exists
    // in a successfully constructed Graph, it is assumed to be
    // well-typed with respect to the DatatypeRegistry.
    // D-inconsistency is defined as containing a literal whose datatype is in D
    // and L2V_D(lit) is undefined. Since L2V_Registry would have been defined
    // for the literal to exist, and assuming L2V_D uses the same logic for types in D,
    // any existing literal with a datatype in D must have a defined value.
    // Therefore, any successfully constructed graph is D-consistent under this assumption.
    return true;
  }

  @override
  Graph materialize(Graph graph, {EntailmentOptions? options}) {
    // D-entailment, unlike RDFS or OWL entailment, does not define additional
    // axiomatic triples based on the rules of the entailment regime itself.
    // The D-closure of a graph G is G itself if G is D-consistent.
    // Since `isConsistent` always returns true under our assumption, the
    // materialized graph is simply a copy of the original graph.
    return Graph()..addAll(graph.triples);
  }

  /// Checks if a single triple `tripleToSatisfy` is D-satisfied by `satisfyingGraph`.
  ///
  /// A triple is D-satisfied if it is present in the satisfying graph, OR if
  /// its object is a literal that is D-equivalent to a literal in a triple
  /// with the same subject and predicate in the satisfying graph.
  bool _isTripleDSatisfied(
    Triple tripleToSatisfy,
    Graph satisfyingGraph,
    Set<IRI> recognizedDatatypesD,
  ) {
    // First, check for an exact match of the triple in the satisfying graph.
    if (satisfyingGraph.contains(tripleToSatisfy)) {
      return true;
    }

    final obj = tripleToSatisfy.object;
    // If the object of the triple to satisfy is a Literal, check for D-equivalence.
    if (obj is Literal) {
      final litToSatisfy = obj;
      // Iterate over triples in the satisfying graph that have the same subject and predicate.
      for (final tGraph1 in satisfyingGraph.match(
        tripleToSatisfy.subject,
        tripleToSatisfy.predicate,
        null, // We are only interested in matching subject and predicate.
      )) {
        // Check if the object of the matched triple in graph1 is also a Literal.
        if (tGraph1.object is Literal) {
          final litGraph1 = tGraph1.object as Literal;
          // Check if the literal from the triple to satisfy is D-equivalent
          // to the literal from the matched triple in graph1.
          if (_areLiteralsDEquivalent(
            litToSatisfy,
            litGraph1,
            recognizedDatatypesD,
          )) {
            return true; // Found a D-equivalent triple, so the original triple is D-satisfied.
          }
        }
      }
    }
    // If no exact match was found and no D-equivalent literal triple was found, the triple is not D-satisfied.
    return false;
  }

  /// Checks if two literals are D-equivalent based on the set of recognized datatypes D.
  ///
  /// Two literals `litA` and `litB` are D-equivalent if:
  /// 1. Their datatypes are both in D, AND their values (as per L2V_D) are equal.
  /// 2. OR, at least one of their datatypes is NOT in D, AND the literals are
  ///    identical RDF literals (same lexical form and datatype/language).
  bool _areLiteralsDEquivalent(
    Literal litA,
    Literal litB,
    Set<IRI> recognizedDatatypesD,
  ) {
    final dtA = litA.datatype;
    final dtB = litB.datatype;

    final isDtARecognizedInD = recognizedDatatypesD.contains(dtA);
    final isDtBRecognizedInD = recognizedDatatypesD.contains(dtB);

    // Condition 1: Both datatypes are in D.
    if (isDtARecognizedInD && isDtBRecognizedInD) {
      // Their values must be defined (guaranteed by Literal constructor) and equal.
      final valA = litA.value;
      final valB = litB.value;

      // Special handling for Uint8List for deep comparison, if necessary.
      if (valA is Uint8List && valB is Uint8List) {
        return const DeepCollectionEquality().equals(valA, valB);
      }
      // For other types, rely on the default equality operator (==).
      return valA == valB;
    } else {
      // Condition 2: At least one datatype is not in D.
      // Literals must be identical RDF literals.
      return litA == litB;
    }
  }

  /// Collects all unique blank nodes present in a graph, including those within TripleTerms.
  Set<BlankNode> _collectUniqueBlankNodes(Graph graph) {
    final bNodes = <BlankNode>{};
    // Keep track of visited TripleTerms to prevent infinite recursion in case of cycles.
    final visitedTripleTerms = <TripleTerm>{};

    /// Recursively collects blank nodes from a given term.
    void collectFromTerm(RdfTerm term) {
      // If the term is a blank node, add it to the set.
      if (term.isBlankNode) {
        bNodes.add(term as BlankNode);
      } else if (term.isTripleTerm) {
        // If the term is a TripleTerm, collect blank nodes from its components.
        final tt = term as TripleTerm;
        // Avoid processing the same TripleTerm multiple times.
        if (visitedTripleTerms.contains(tt)) return;
        visitedTripleTerms.add(tt);

        // Collect from the subject and object of the inner triple.
        collectFromTerm(tt.triple.subject);
        // Predicates are always IRIs, so no blank nodes there.
        collectFromTerm(tt.triple.object);

        // Remove the TripleTerm from the visited set to allow revisiting if reached via a different path.
        visitedTripleTerms.remove(tt);
      }
    }

    // Iterate through all triples in the graph and collect blank nodes from their subject and object.
    for (final triple in graph.triples) {
      collectFromTerm(triple.subject);
      collectFromTerm(triple.object);
    }
    return bNodes;
  }

  /// Collects all unique terms that can be potential mapping targets for blank nodes in another graph.
  ///
  /// These are all the terms (IRIs, BlankNodes, Literals, TripleTerms) present in the graph.
  Set<RdfTerm> _collectPotentialMappingTargets(Graph graph) {
    final terms = <RdfTerm>{};
    // Iterate through all triples and add their subject and object to the set of terms.
    for (final triple in graph.triples) {
      terms.add(triple.subject);
      terms.add(triple.object);
    }
    return terms;
  }

  /// Instantiates a graph by applying a given mapping from blank nodes to RDF terms.
  ///
  /// Returns a new graph with blank nodes replaced according to the mapping,
  /// or `null` if the instantiation results in an invalid graph (e.g., a blank
  /// node is mapped to a literal in a subject position, or cycles are detected
  /// during instantiation of nested TripleTerms).
  Graph? _instantiateGraph(Graph graph, Map<BlankNode, RdfTerm> mapping) {
    final instantiatedTriples = <Triple>{};
    // Keep track of visited TripleTerms during instantiation to detect cycles.
    final visitedTripleTermsForInstantiation = <TripleTerm>{};

    /// Recursively maps a term based on the provided mapping.
    RdfTerm mapTerm(RdfTerm term) {
      // If the term is a blank node and is in the mapping, return its mapped value.
      if (term.isBlankNode && mapping.containsKey(term as BlankNode)) {
        return mapping[term]!;
      }
      // If the term is a TripleTerm, recursively map its subject and object.
      if (term.isTripleTerm) {
        final tt = term as TripleTerm;
        // Check for cycles: If we encounter a TripleTerm we are currently processing, it's a cycle.
        if (visitedTripleTermsForInstantiation.contains(tt)) {
          // This indicates an attempt to map a blank node in a way that creates a cycle
          // within the instantiation process (e.g., a blank node in a TripleTerm's subject
          // is mapped to a TripleTerm that contains the original blank node).
          // This is considered an invalid instantiation path in this context.
          return _InvalidInstantiationMarker();
        }
        visitedTripleTermsForInstantiation.add(tt);

        // Recursively map the inner subject and object of the TripleTerm.
        final mappedInnerSubject = mapTerm(tt.triple.subject);
        // Predicate remains unchanged as it's always an IRI.
        final mappedInnerObject = mapTerm(tt.triple.object);

        // Backtrack: Remove the TripleTerm from the visited set after processing its children.
        visitedTripleTermsForInstantiation.remove(tt);

        // If the recursive mapping resulted in an invalid marker for subject or object,
        // propagate the invalid marker.
        if (mappedInnerSubject is! SubjectTerm ||
            mappedInnerSubject is _InvalidInstantiationMarker) {
          return _InvalidInstantiationMarker();
        }
        if (mappedInnerObject is _InvalidInstantiationMarker) {
          return _InvalidInstantiationMarker();
        }

        try {
          // Attempt to create a new TripleTerm with the mapped subject and object.
          return TripleTerm(
            Triple(mappedInnerSubject, tt.triple.predicate, mappedInnerObject),
          );
        } on InvalidTermException {
          // If creating the inner Triple fails (e.g., invalid term types for subject/predicate/object),
          // return the invalid marker.
          return _InvalidInstantiationMarker();
        }
      }
      // If the term is not a blank node or TripleTerm, return the term itself (it's already ground).
      return term;
    }

    // Iterate through all triples in the original graph and instantiate them.
    for (final triple in graph.triples) {
      final mappedSNode = mapTerm(triple.subject);
      final mappedONode = mapTerm(triple.object);

      // If mapping the subject or object resulted in an invalid marker, the entire graph instantiation is invalid.
      if (mappedSNode is! SubjectTerm ||
          mappedSNode is _InvalidInstantiationMarker) {
        return null;
      }
      if (mappedONode is _InvalidInstantiationMarker) {
        return null;
      }
      try {
        // Add the instantiated triple to the set of instantiated triples.
        instantiatedTriples.add(
          Triple(mappedSNode, triple.predicate, mappedONode),
        );
      } on InvalidTermException {
        // If creating the instantiated Triple fails, the entire graph instantiation is invalid.
        return null;
      }
    }
    // Return a new Graph containing all the successfully instantiated triples.
    return Graph()..addAll(instantiatedTriples);
  }

  /// Recursively attempts to find a valid mapping for blank nodes in `graph2`
  /// to terms in `graph1` such that the instantiated `graph2` is a D-subgraph of `graph1`.
  ///
  /// This is a backtracking search algorithm.
  bool _findValidMappingAndCheckDSubgraph(
    Graph graph1, // The entailing graph.
    Graph graph2, // The graph to be entailed.
    List<BlankNode> bNodesToMap, // List of blank nodes in graph2 to map.
    int
    currentBNodeIndex, // The index of the blank node currently being mapped.
    Map<BlankNode, RdfTerm> currentMapping, // The current partial mapping.
    List<RdfTerm>
    potentialTargets, // Possible terms in graph1 to map blank nodes to.
    Set<IRI>
    recognizedDatatypesD, // The set of datatypes recognized by D-entailment.
  ) {
    // Base Case: If all blank nodes in bNodesToMap have been mapped.
    if (currentBNodeIndex == bNodesToMap.length) {
      // Instantiate graph2 with the current complete mapping.
      final g2Instance = _instantiateGraph(graph2, currentMapping);
      // If instantiation failed (e.g., due to invalid mapping creating an invalid triple structure), this mapping is invalid.
      if (g2Instance == null) {
        return false;
      }
      // Check if the instantiated graph2 is a D-subgraph of graph1.
      // This means every triple in the instantiated graph2 must be D-satisfied by graph1.
      for (final tInstance in g2Instance.triples) {
        if (!_isTripleDSatisfied(tInstance, graph1, recognizedDatatypesD)) {
          return false; // If any triple is not D-satisfied, this mapping is invalid.
        }
      }
      return true; // All triples in g2Instance are D-satisfied, so this is a valid mapping.
    }

    // Recursive Step: Map the blank node at currentBNodeIndex.
    final bNodeToMap = bNodesToMap[currentBNodeIndex];
    var bNodeUsedAsSubject = false;

    // Determine if the current blank node (`bNodeToMap`) is used as a subject in graph2.
    // This is needed because blank nodes used as subjects cannot be mapped to literals in D-entailment.

    // Helper function to recursively check if the target blank node is the subject of any triple,
    // including nested triples within TripleTerms.
    final visitedTripleTermsCheck = <TripleTerm>{};
    bool isBNodeSubject(RdfTerm term, BlankNode targetBNode) {
      // If the current term is the target blank node and it's in a subject position (checked by caller), return true.
      // If the term is a TripleTerm, recursively check its subject.
      if (term.isTripleTerm) {
        final tt = term as TripleTerm;
        // Prevent infinite recursion for cycles in TripleTerms.
        if (visitedTripleTermsCheck.contains(tt)) return false;
        visitedTripleTermsCheck.add(tt);

        // Check the inner subject.
        final result = isBNodeSubject(tt.triple.subject, targetBNode);
        // Check the inner object, as it might contain nested TripleTerms with the blank node as subject.
        final resultInObject = isBNodeSubject(tt.triple.object, targetBNode);

        visitedTripleTermsCheck.remove(tt); // Backtrack.

        return result ||
            resultInObject; // Return true if found in subject or object (nested).
      }
      // If the term is the target blank node, indicate it can be a subject if its container is a subject position.
      return term == targetBNode;
    }

    // Iterate through all triples in graph2 to see if the blank node is used as a subject.
    for (final tripleInG2 in graph2.triples) {
      if (isBNodeSubject(tripleInG2.subject, bNodeToMap)) {
        bNodeUsedAsSubject = true;
        break; // Found usage as subject, no need to check further.
      }
      if (isBNodeSubject(tripleInG2.object, bNodeToMap)) {
        // If the blank node is the subject of a triple term which is the object
        // of the current triple.
        bNodeUsedAsSubject = true;
        break; // Found usage as subject within a nested triple, no need to check further.
      }
    }

    // Iterate through all potential target terms in graph1.
    for (final targetTerm in potentialTargets) {
      // Constraint: If the blank node is used as a subject in graph2, it cannot
      // be mapped to a literal in graph1.
      if (bNodeUsedAsSubject && targetTerm.isLiteral) {
        continue; // Skip this target as it's invalid for this blank node.
      }

      // Apply the current mapping for the blank node to this target term.
      currentMapping[bNodeToMap] = targetTerm;

      // Recursively call the function to find mappings for the remaining blank nodes.
      if (_findValidMappingAndCheckDSubgraph(
        graph1,
        graph2,
        bNodesToMap,
        currentBNodeIndex + 1, // Move to the next blank node.
        currentMapping, // Pass the updated mapping.
        potentialTargets,
        recognizedDatatypesD,
      )) {
        return true; // If the recursive call found a valid mapping, return true immediately.
      }

      // Backtrack: If the recursive call did not find a valid mapping with the current target,
      // remove the mapping for the current blank node and try the next target.
      currentMapping.remove(bNodeToMap);
    }

    // If no target term in graph1 resulted in a valid mapping for the current blank node,
    // then no valid mapping exists starting from this point.
    return false;
  }
}

/// Helper marker used internally by _instantiateGraph to indicate an invalid instantiation result.
///
/// This is similar in concept to how SimpleEntailmentStrategy might use null or
/// a specific indicator to signal an unresolvable mapping path during instantiation.
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
