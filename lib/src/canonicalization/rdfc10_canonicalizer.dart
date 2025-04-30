import 'dart:convert';
import 'dart:math';

import 'package:rdf_dart/src/blank_node.dart';
import 'package:rdf_dart/src/canonicalization/canonicalization_state.dart';
import 'package:rdf_dart/src/canonicalization/canonicalizer.dart';
import 'package:rdf_dart/src/canonicalization/identifier_issuer.dart';
import 'package:rdf_dart/src/canonicalization/max_iterations_exception.dart';
import 'package:rdf_dart/src/canonicalization/permuter.dart';
import 'package:rdf_dart/src/codec/n_formats/n_formats_serializer_utils.dart';
import 'package:rdf_dart/src/dataset.dart';
import 'package:rdf_dart/src/iri_term.dart';
import 'package:rdf_dart/src/literal.dart';
import 'package:rdf_dart/src/quad.dart';
import 'package:rdf_dart/src/rdf_term.dart';

/// Implements the RDFC-1.0 canonicalization algorithm.
/// Spec: https://www.w3.org/TR/rdf-canon/
final class Rdfc10Canonicalizer extends Canonicalizer {

  /// The calculated maximum number of deep iterations allowed for this run.
  late num _effectiveMaxIterations;
  /// The remaining number of deep iterations allowed.
  late num _remainingIterations;

  /// Creates an RDFC-1.0 canonicalizer instance using the specified 
  /// hash algorithm and complexity constraints.
  Rdfc10Canonicalizer(super.hashAlgorithm, super.complexityLimits);

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

    // RDFC-1.0 Algorithm 4.4, Step ca.4: Process unique hashes
    final hashesToRemove = <String>[]; // Track unique hashes to remove later
    // Get hashes and sort them (code point ordered by hash)
    final sortedHashes = state.hashToBlankNodesMap.keys.toList()..sort();
    final nonUniqueLists = <List<String>>[]; // Store lists for Step ca.5
    var nonUniqueBNodeCount = 0; // Counter for limit calculation

    for (final hash in sortedHashes) {
      final identifierList = state.hashToBlankNodesMap[hash]!;
      // Step ca.4.1: Check if identifierList has only one entry
      if (identifierList.length == 1) {
        final bnodeId = identifierList.first;
        // Step ca.4.2: Issue canonical identifier using Algorithm 4.5
        // Only issue if not already issued (though unlikely at this stage)
        if (!state.canonicalIssuer.issued.containsKey(bnodeId)) {
           state.canonicalIssuer.getId(bnodeId);
        }
        // Step ca.4.3: Mark hash for removal
        hashesToRemove.add(hash);
      } else {
        // This hash group is non-unique
        nonUniqueLists.add(identifierList);
        nonUniqueBNodeCount += identifierList.length; // <-- Count nodes for limit
        // If list has more than one entry, continue (handled in Step ca.5)
      }
    }
    // Remove the entries for unique hashes
    for (final hash in hashesToRemove) {
      state.hashToBlankNodesMap.remove(hash);
    }

    _calculateComplexity(nonUniqueBNodeCount);

    // RDFC-1.0 Algorithm 4.4, Step ca.5: Process non-unique hashes
    // Create a copy of the keys to iterate over, as the map might be modified
    final nonUniqueHashes = state.hashToBlankNodesMap.keys.toList()..sort();

    for (final hash in nonUniqueHashes) {
      // Check if the hash still exists, as nested calls might have resolved some nodes
      if (!state.hashToBlankNodesMap.containsKey(hash)) {
        continue;
      }
      final identifierList = state.hashToBlankNodesMap[hash]!;

      // Step ca.5.1: Initialize hash path list (implicitly handled by loop)
      final hashPathList =
          <
            (String hash, IdentifierIssuer issuer, String originalBlankNodeId)
          >[];

      // Step ca.5.2: For each identifier `n` in the list for this hash
      for (final n in identifierList) {
        // Step ca.5.2.1: Skip if canonical ID already issued
        if (state.canonicalIssuer.issued.containsKey(n)) {
          continue;
        }

        // Step ca.5.2.2: Create temporary issuer with prefix 'b'
        final temporaryIssuer = IdentifierIssuer('b');

        // Step ca.5.2.3: Issue temporary ID for n (e.g., b0)
        // Note: getId also stores the mapping in temporaryIssuer
        temporaryIssuer.getId(n);

        // Step ca.5.2.4: Run Algorithm 4.8 (hndq)
        final hndqResult = _hashNDegreeQuads(state, n, temporaryIssuer);
        hashPathList.add((hndqResult.$1, hndqResult.$2, n));
      }

      // Step ca.5.3: Sort results by hash
      hashPathList.sort((a, b) => a.$1.compareTo(b.$1)); // Sort by hash

      // Step ca.5.3.1: Issue canonical IDs based on sorted results
      for (final result in hashPathList) {
        // Iterate through the identifiers issued by the temporary issuer *in order*
        // The result.issuer.issued map (LinkedHashMap) maintains insertion order.
        result.$2.issued.forEach((existingIdentifier, temporaryId) {
          // Ensure canonical ID hasn't been issued by a parallel path
          if (!state.canonicalIssuer.issued.containsKey(existingIdentifier)) {
            state.canonicalIssuer.getId(existingIdentifier);
          }
        });
      }
    }

    return _serializeCanonicalNQuads(dataset, state);
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
    final digest = hashAlgorithm.convert(bytesToHash);
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

  /// Performs Algorithm 4.7: Hash Related Blank Node (hrbn).
  ///
  /// Creates a hash representing the connection between a reference blank node
  /// (implicit from the calling context of Algorithm 4.8) and a related
  /// adjacent blank node.
  ///
  /// Takes the canonicalization state, the ID of the related blank node,
  /// the quad connecting them, the temporary issuer for the current path,
  /// and the position ('s', 'o', or 'g') of the related node in the quad.
  /// Returns the resulting hash string.
  /// Spec Section: 4.7
  String _hashRelatedBlankNode(
    CanonicalizationState state,
    String relatedBnodeId, // The ID of the adjacent blank node
    Quad quad, // The quad containing the relationship
    IdentifierIssuer
    temporaryIssuer, // The issuer for the current N-degree path
    String position, // 's', 'o', or 'g'
  ) {
    // Algorithm 4.7, Step hrbn.1: Initialize input string with position.
    final inputBuffer = StringBuffer(position);

    // Algorithm 4.7, Step hrbn.2: Append predicate if position is not 'g'.
    if (position != 'g') {
      // Spec: append '<', the value of the predicate, and '>'
      inputBuffer.write('<');
      // quad.predicate is IRITerm, its value is IRI
      inputBuffer.write(quad.predicate.value.toString());
      inputBuffer.write('>');
    }

    // Algorithm 4.7, Step hrbn.3: Check canonical and temporary issuers.
    String? issuedId;
    // Check canonical issuer first
    if (state.canonicalIssuer.issued.containsKey(relatedBnodeId)) {
      issuedId = state.canonicalIssuer.issued[relatedBnodeId]!;
    }
    // Otherwise check the temporary issuer for the current N-degree path
    else if (temporaryIssuer.issued.containsKey(relatedBnodeId)) {
      issuedId = temporaryIssuer.issued[relatedBnodeId]!;
    }

    if (issuedId != null) {
      // Append the N-Quads representation: _:identifier
      inputBuffer.write('_:');
      inputBuffer.write(issuedId);
    }
    // Algorithm 4.7, Step hrbn.4: Otherwise, append first degree hash.
    else {
      // Note: Spec says "append the result of the Hash First Degree Quads
      // algorithm". This means appending the hash string itself.
      // Call the h1dq implementation, passing the *related* node's ID.
      final h1dqHash = _hashFirstDegreeQuads(state, relatedBnodeId);
      inputBuffer.write(h1dqHash);
    }

    // Algorithm 4.7, Step hrbn.5: Hash the final input string.
    final inputString = inputBuffer.toString();
    final bytesToHash = utf8.encode(inputString);
    final digest = hashAlgorithm.convert(bytesToHash);
    return digest.toString(); // Return the hash string
  }

  /// Performs Algorithm 4.8: Hash N-Degree Quads (hndq).
  ///
  /// Calculates a hash for a blank node by recursively exploring its connected
  /// quads and blank nodes. Uses a temporary issuer to track visited nodes
  /// within the current exploration path.
  /// Returns the calculated hash and the final state of the temporary issuer.
  /// Spec Section: 4.8
  (String hash, IdentifierIssuer issuer) _hashNDegreeQuads(
    CanonicalizationState state,
    String identifier, // The blank node ID we are calculating the hash for
    IdentifierIssuer issuer, // The temporary issuer for this path
  ) {
    _enforceComplexityLimitations();
    // Step hndq.1: Initialize Hn map.
    final hnMap = <String, List<String>>{};
    // Step hndq.2: Get quads for the identifier.
    final quads = state.blankNodeToQuadsMap[identifier] ?? [];
    // Step hndq.3: Calculate related hashes.
    for (final quad in quads) {
      final components = <(RdfTerm?, String)>[
        (quad.subject, 's'),
        (quad.object, 'o'),
        if (quad.graphLabel != null) (quad.graphLabel, 'g'),
      ];
      for (final entry in components) {
        final term = entry.$1;
        final position = entry.$2;
        if (term != null &&
            term.isBlankNode &&
            (term as BlankNode).id != identifier) {
          final relatedBnodeId = term.id;
          // Step hndq.3.1.1: Calculate hash using Algorithm 4.7 (hrbn)
          final relatedHash = _hashRelatedBlankNode(
            state,
            relatedBnodeId,
            quad,
            issuer,
            position,
          );
          // Step hndq.3.1.2: Add mapping to Hn
          hnMap.putIfAbsent(relatedHash, () => []).add(relatedBnodeId);
        }
      }
    }
    // Step hndq.4: Initialize dataToHash.
    final dataToHash = StringBuffer();
    // Step hndq.5: Process Hn sorted by related hash.
    final sortedRelatedHashes = hnMap.keys.toList()..sort();

    for (final relatedHash in sortedRelatedHashes) {
      final blankNodeList = hnMap[relatedHash]!;
      blankNodeList.sort(); // Sort list for deterministic permutation start

      // Step hndq.5.1: Append related hash to dataToHash.
      dataToHash.write(relatedHash);
      // Step hndq.5.2 & 5.3: Initialize chosenPath & chosenIssuer.
      var chosenPath = '';
      IdentifierIssuer? chosenIssuer;

      // --- Step hndq.5.4: Iterate through permutations ---
      final permuter = Permuter(blankNodeList); // Use the Permuter
      while (permuter.moveNext()) {
        final p = permuter.current; // Get next permutation

        // Step hndq.5.4.1: Create issuer copy using the implemented deepCopy
        var issuerCopy = issuer.deepCopy();

        // Step hndq.5.4.2 & 5.4.3: Initialize path & recursionList
        final path = StringBuffer();
        final recursionList = <String>[];

        // Step hndq.5.4.4: Process each related node in permutation p.
        var skipPermutation = false;
        for (final related in p) {
          // Step hndq.5.4.4.1: Check canonical issuer
          if (state.canonicalIssuer.issued.containsKey(related)) {
            path.write('_:');
            path.write(state.canonicalIssuer.issued[related]!);
          }
          // Step hndq.5.4.4.2: Check temporary/issue if needed
          else {
            if (!issuerCopy.issued.containsKey(related)) {
              // hndq.5.4.4.2.1
              recursionList.add(related);
            }
            final tempIssuedId = issuerCopy.getId(related); // hndq.5.4.4.2.2
            path.write('_:');
            path.write(tempIssuedId);
          }
          // Step hndq.5.4.4.3: Optimization check
          if (chosenPath.isNotEmpty &&
              path.length >= chosenPath.length &&
              path.toString().compareTo(chosenPath) > 0) {
            skipPermutation = true;
            break;
          }
        }
        if (skipPermutation) continue;

        // Step hndq.5.4.5: Recurse on nodes in recursionList
        for (final related in recursionList) {
          // Step hndq.5.4.5.1: Recursive call
          final result = _hashNDegreeQuads(state, related, issuerCopy);
          // Step hndq.5.4.5.2: Append temporary ID
          path.write('_:');
          path.write(issuerCopy.getId(related));
          // Step hndq.5.4.5.3: Append <hash> from result
          path.write('<');
          path.write(result.$1);
          path.write('>');
          // Step hndq.5.4.5.4: Update issuerCopy with returned issuer state
          issuerCopy = result.$2.deepCopy(); // Use deepCopy from result
          // Step hndq.5.4.5.5: Optimization check
          if (chosenPath.isNotEmpty &&
              path.length >= chosenPath.length &&
              path.toString().compareTo(chosenPath) > 0) {
            skipPermutation = true;
            break;
          }
        }
        if (skipPermutation) continue;

        // Step hndq.5.4.6: Update chosenPath and chosenIssuer if current path is better
        final currentPath = path.toString();
        if (chosenPath.isEmpty || currentPath.compareTo(chosenPath) < 0) {
          chosenPath = currentPath;
          chosenIssuer = issuerCopy;
        }
      } // End of permutation loop (while permuter.hasNext())

      // Step hndq.5.5: Append chosenPath to dataToHash.
      dataToHash.write(chosenPath);
      // Step hndq.5.6: Update the main issuer reference if a best path was found.
      if (chosenIssuer != null) {
        issuer =
            chosenIssuer; // Update issuer state with the one from the best path
      }
    } // End of loop through sortedRelatedHashes

    // Step hndq.6: Hash final dataToHash and return hash + issuer.
    final finalHash =
        hashAlgorithm.convert(utf8.encode(dataToHash.toString())).toString();
    return (finalHash, issuer); // Return using positional fields
  }

  /// Serializes the canonicalized dataset into the final N-Quads string.
  /// Needs access to the final canonical issuer mapping.
  /// Spec Section: 5
  String _serializeCanonicalNQuads(Dataset originalDataset, CanonicalizationState state) {
    final canonicalQuads = <String>[];
    final canonicalIdMap = state.canonicalIssuer.issued;

    // Helper to get canonical ID or format other terms
    String formatTermCanonical(RdfTerm term) {
      if (term.isIRI) {
        return NFormatsSerializerUtils.formatIri((term as IRITerm).value);
      } else if (term.isLiteral) {
        return NFormatsSerializerUtils.formatLiteral(term as Literal);
      } else if (term.isBlankNode) {
        final originalId = (term as BlankNode).id;
        // Lookup in canonical map; should always be present if algorithm is correct
        final canonicalId =
            canonicalIdMap[originalId] ??
            (throw StateError(
              'Canonical ID not found for blank node: $originalId',
            ));
        // Format using the canonical ID (e.g., _:c14n0)
        // We need a BlankNode instance with the canonical ID to format correctly
        return NFormatsSerializerUtils.formatBlankNode(BlankNode(canonicalId));
      } else {
        throw ArgumentError(
          'Unsupported RDF term type for final serialization: ${term.runtimeType}',
        );
      }
    }

    // Iterate through original dataset quads (order doesn't matter here, will sort later)
    for (final quad in originalDataset.quads) {
      final s = formatTermCanonical(quad.subject);
      final p = formatTermCanonical(quad.predicate);
      final o = formatTermCanonical(quad.object);

      final buffer = StringBuffer();
      buffer.write('$s $p $o');

      if (quad.graphLabel != null) {
        buffer.write(' ');
        final g = formatTermCanonical(quad.graphLabel!);
        buffer.write(g);
      }
      buffer.write(' .\n');
      canonicalQuads.add(buffer.toString());
    }

    // Sort the final list of canonical N-Quad strings
    canonicalQuads.sort();

    // Join them into the final document
    return canonicalQuads.join();
  }

  void _calculateComplexity(int nonUniqueBNodeCount){
    final factor = super.complexityLimits.maxWorkFactor;

    if (factor == 0) {
      _effectiveMaxIterations = 0;
    } else if (factor == double.infinity) {
      _effectiveMaxIterations = double.infinity;
    } else {
      // Calculate based on work factor: n ^ factor
      _effectiveMaxIterations = pow(nonUniqueBNodeCount, factor);
      // Handle potential overflow to infinity
      if (!_effectiveMaxIterations.isFinite) {
         _effectiveMaxIterations = double.infinity;
      }
    }
    // Ensure it's not negative (e.g., pow(0, 3) is 0)
    _effectiveMaxIterations = max(0, _effectiveMaxIterations);
    _remainingIterations = _effectiveMaxIterations; // Initialize counter
  }
  
  void _enforceComplexityLimitations() {
    if (_remainingIterations == 0) {
      // Throw the specific exception
      throw MaxIterationsExceededException(_effectiveMaxIterations);
    }
    if (_remainingIterations != double.infinity) {
       // Decrement only if it's a finite limit
       _remainingIterations--;
    }
  }
}
