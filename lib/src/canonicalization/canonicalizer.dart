import 'package:crypto/crypto.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/canonicalization/canonicalization_algorithm.dart';
import 'package:rdf_dart/src/canonicalization/rdfc10_canonicalizer.dart';
import 'package:rdf_dart/src/canonicalization/urdna2015_canonicalizer.dart';
import 'package:rdf_dart/src/canonicalization/urgna2012_canonicalizer.dart';

/// Abstract base class for RDF Dataset canonicalization algorithms (Strategy Pattern).
///
/// Provides a common interface for different canonicalization algorithms like
/// RDFC-1.0 and URDNA2015.
abstract class Canonicalizer {
  
  /// Canonicalizes the input RDF [dataset] according to the specific algorithm.
  ///
  /// Returns the canonical representation of the dataset as a single string,
  /// typically formatted as N-Quads.
  ///
  /// Throws exceptions if the canonicalization process fails (e.g., due to
  /// malformed input, algorithm constraints, or potential dataset poisoning
  /// issues if checks are implemented).
  String canonicalize(Dataset dataset);

  /// Factory constructor to get an instance of a specific canonicalizer.
  factory Canonicalizer.create(CanonicalizationAlgorithm algorithm, {
    Hash hashAlgorithm = sha256, 
  }) {
    switch (algorithm) {
      case CanonicalizationAlgorithm.rdfc10:
        return Rdfc10Canonicalizer(hashAlgorithm);
      case CanonicalizationAlgorithm.urdna2015:
        return Urdna2015Canonicalizer();
      case CanonicalizationAlgorithm.urgna2012:
        return Urgna2012Canonicalizer();
    }
  }
}
