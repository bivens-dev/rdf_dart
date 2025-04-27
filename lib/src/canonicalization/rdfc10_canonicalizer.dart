import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/canonicalization/canonicalization_state.dart';
import 'package:rdf_dart/src/canonicalization/canonicalizer.dart';
import 'package:rdf_dart/src/canonicalization/quad.dart';
import 'package:rdf_dart/src/codec/n_formats/n_formats_serializer_utils.dart';

/// Implements the RDFC-1.0 canonicalization algorithm.
/// Spec: https://www.w3.org/TR/rdf-canon/
class Rdfc10Canonicalizer implements Canonicalizer {
  @override
  String canonicalize(Dataset dataset) {
    // RDFC-1.0 Algorithm 4.4, Step 1
    final state = CanonicalizationState(dataset);

    // RDFC-1.0 Algorithm 4.4, Step ca.3: For each bnode...
    state.blankNodeToQuadsMap.forEach((bnodeId, quads) {
      // RDFC-1.0 Algorithm 4.4, Step ca.3.1: Create hash hf(n) using Algorithm 4.6
      final hash = _hashFirstDegreeQuads(state, bnodeId);

      // RDFC-1.0 Algorithm 4.4, Step ca.3.2: Update hashToBlankNodesMap
      final bnodesForHash = state.hashToBlankNodesMap.putIfAbsent(
        hash,
        () => [],
      );
      bnodesForHash.add(bnodeId);
    });

    // RDFC-1.0 Algorithm 4.4, Step ca.5 calls Algorithm 4.8 (hndq)
    // _hashNDegreeQuads(state); // To be implemented

    // RDFC-1.0 Algorithm 4.4, Step ca.7
    // return _serializeCanonicalNQuads(state); // To be implemented

    throw UnimplementedError('RDFC-1.0 canonicalization steps pending.');
  }

  /// Performs Algorithm 4.6: Hash First Degree Quads (h1dq).
  ///
  /// Takes the canonicalization state and a reference blank node identifier.
  /// Returns the computed hash for that blank node based on its
  /// first-degree quads, following the steps h1dq.1 through h1dq.5.

  /// This algorithm calculates a hash for a given blank node across the quads
  /// in a dataset in which that blank node is a component. If the hash
  /// uniquely identifies that blank node, no further examination is necessary.
  /// Otherwise, a hash will be created for the blank node using the algorithm
  /// in 4.8 Hash N-Degree Quads invoked via 4.4 Canonicalization Algorithm.
  ///
  /// Spec Section: 4.6
  String _hashFirstDegreeQuads(
    CanonicalizationState state,
    String referenceBnodeId,
  ) {
    // Algorithm 4.6, Step h1dq.1: Initialize nquads list.
    final nquads = <String>[];

    // Algorithm 4.6, Step h1dq.2: Get the list of quads for referenceBnodeId.
    // Handle case where bnodeId might somehow not be in the map (shouldn't happen)
    final quads = state.blankNodeToQuadsMap[referenceBnodeId] ?? [];

    // Algorithm 4.6, Step h1dq.3: For each quad in quads.
    for (final quad in quads) {
      // Algorithm 4.6, Step h1dq.3.1: Serialize quad in canonical form
      // with _:a / _:z substitution relative to referenceBnodeId.
      final serializedQuad = _serializeQuadForFirstDegreeHashing(
        quad,
        referenceBnodeId,
      );
      // Implicitly add the result to the `nquads` list for sorting later.
      nquads.add(serializedQuad);
    }

    // Algorithm 4.6, Step h1dq.4: Sort nquads lexicographically.
    nquads.sort();

    // Prepare data for hashing by concatenating sorted strings.
    final dataToHash = nquads.join();

    // Algorithm 4.6, Step h1dq.5: Return the hash.
    final bytesToHash = utf8.encode(dataToHash);
    final digest = sha256.convert(bytesToHash);
    return digest.toString(); // Return the computed hash string
  }

  /// Serializes a quad into its canonical N-Quads string representation
  /// (ending in ` .\n`), applying the `_:a` / `_:z` substitutions required
  /// for Algorithm 4.6, Step h1dq.3.1.
  ///
  /// Returns the full quad string (e.g., `_:a <p> "o" .\n`).
  String _serializeQuadForFirstDegreeHashing(Quad quad, String relatedBnodeId) {
    // (Implementation remains the same as the previous correct version)
    final subjString = _serializeTermForHashing(quad.subject, relatedBnodeId);
    final predString = _serializeTermForHashing(quad.predicate, relatedBnodeId);
    final objString = _serializeTermForHashing(quad.object, relatedBnodeId);

    final buffer = StringBuffer();
    buffer.write(subjString);
    buffer.write(' ');
    buffer.write(predString);
    buffer.write(' ');
    buffer.write(objString);

    if (quad.graphLabel != null) {
      buffer.write(' ');
      final graphString = _serializeTermForHashing(
        quad.graphLabel!,
        relatedBnodeId,
      );
      buffer.write(graphString);
    }

    buffer.write(' .\n');

    return buffer.toString();
  }

  /// Helper to serialize a single term with `_:a` / `_:z` substitution
  /// for use in Algorithm 4.6 hashing.
  String _serializeTermForHashing(RdfTerm term, String relatedBnodeId) {
    // (Implementation remains the same as the previous correct version)
    if (term.isIRI) {
      return NFormatsSerializerUtils.formatIri((term as IRITerm).value);
    } else if (term.isLiteral) {
      return NFormatsSerializerUtils.formatLiteral(term as Literal);
    } else if (term.isBlankNode) {
      final bnode = term as BlankNode;
      // Algorithm 4.6, Step h1dq.3.1.1.1
      if (bnode.id == relatedBnodeId) {
        return '_:a'; // The reference node
      } else {
        return '_:z'; // Any other blank node
      }
    } else {
      throw ArgumentError(
        'Unsupported RDF term type for hashing: ${term.runtimeType}',
      );
    }
  }

  // --- Placeholders for subsequent algorithm steps ---
  // void _hashNDegreeQuads(CanonicalizationState state) { ... } // Algorithm 4.8
  // String _serializeCanonicalNQuads(CanonicalizationState state) { ... } // Section 5
}

// void main() {
//   final dataset = Dataset();
//   dataset.defaultGraph.addAll([
//     Triple(
//       IRITerm(IRI('http://example.com/#p')),
//       IRITerm(IRI('http://example.com/#q')),
//       BlankNode('e0'),
//     ),
//     Triple(
//       IRITerm(IRI('http://example.com/#p')),
//       IRITerm(IRI('http://example.com/#r')),
//       BlankNode('e1'),
//     ),
//     Triple(
//       BlankNode('e0'),
//       IRITerm(IRI('http://example.com/#s')),
//       IRITerm(IRI('http://example.com/#u')),
//     ),
//     Triple(
//       BlankNode('e1'),
//       IRITerm(IRI('http://example.com/#t')),
//       IRITerm(IRI('http://example.com/#u')),
//     ),
//   ]);
//   final canonicalizer = Canonicalizer.create(CanonicalizationAlgorithm.rdfc10);
//   canonicalizer.canonicalize(dataset);
// }
