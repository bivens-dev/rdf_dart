import 'package:rdf_dart/src/canonicalization/identifier_issuer.dart';
import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/dataset.dart';
import 'package:rdf_dart/src/model/quad.dart';

/// Holds the state required during the RDF Dataset canonicalization process,
/// corresponding to Section 4.2 of the RDFC-1.0 specification.
class CanonicalizationState {
  /// Maps input blank node identifiers to the list of quads they appear in.
  /// Built during initialization from the input dataset.
  final Map<String, List<Quad>> blankNodeToQuadsMap;

  /// Maps hashes (generated during the algorithm) to lists of input blank
  /// node identifiers that produced that hash. Initially empty.
  final Map<String, List<String>> hashToBlankNodesMap;

  /// Issues canonical blank node identifiers (e.g., _:c14n0, _:c14n1, ...).
  final IdentifierIssuer canonicalIssuer;

  /// Initializes the canonicalization state for the given [inputDataset].
  ///
  /// Sets up the canonical issuer and populates the [blankNodeToQuadsMap]
  /// by iterating through all quads in the dataset.
  CanonicalizationState(Dataset inputDataset)
    : blankNodeToQuadsMap = {}, // Initialize empty, populate below
      hashToBlankNodesMap = {}, // Starts empty
      canonicalIssuer = IdentifierIssuer('c14n') // Use 'c14n' prefix
      {
    _initializeBlankNodeToQuadsMap(inputDataset);
  }

  /// Populates the blankNodeToQuadsMap by iterating through the input dataset.
  void _initializeBlankNodeToQuadsMap(Dataset dataset) {
    for (final quad in dataset.quads) {
      _addQuadToMapForBlankNodes(quad);
    }
  }

  /// Helper to add a quad to the map for each blank node it contains.
  void _addQuadToMapForBlankNodes(Quad quad) {
    final terms = [quad.subject, quad.predicate, quad.object, quad.graphLabel];

    for (final term in terms) {
      if (term != null && term.isBlankNode) {
        final bnodeId = (term as BlankNode).id;
        // Get the list for this bnode ID, or create it if it doesn't exist
        final quadsForBnode = blankNodeToQuadsMap.putIfAbsent(
          bnodeId,
          () => [],
        );
        // Add the current quad to the list
        quadsForBnode.add(quad);
      }
    }
  }
}
