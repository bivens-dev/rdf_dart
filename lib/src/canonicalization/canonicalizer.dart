import 'package:crypto/crypto.dart';
import 'package:rdf_dart/src/canonicalization/canonicalization_algorithm.dart';
import 'package:rdf_dart/src/canonicalization/complexity_limits.dart';
import 'package:rdf_dart/src/canonicalization/max_iterations_exception.dart' show MaxIterationsExceededException;
import 'package:rdf_dart/src/canonicalization/rdfc10_canonicalizer.dart';
import 'package:rdf_dart/src/model/dataset.dart';

/// Defines a standard way to create a unique, textual representation
/// (canonical form) of an RDF dataset.
///
/// Think of it as a blueprint (or interface) for different algorithms
/// that achieve the same goal: making sure the same dataset always produces
/// the exact same text output, regardless of how its internal structure might vary.
/// This is useful for comparing datasets or generating consistent signatures.
///
/// This class uses the Strategy Pattern, allowing different canonicalization
/// algorithms like RDFC-1.0 or URDNA2015 to be used interchangeably.
///
/// Use the [Canonicalizer.create] factory to easily get an instance of a
/// specific algorithm implementation.
abstract base class Canonicalizer {
  /// The hashing algorithm (e.g., SHA-256) used internally by the
  /// canonicalization process, particularly for assigning identifiers to
  /// blank nodes.
  final Hash hashAlgorithm;

  /// Defines limits on computational complexity during canonicalization.
  ///
  /// This helps prevent excessive resource usage (CPU time, memory) when
  /// processing very complex datasets, which can sometimes indicate an attempt
  /// to exploit the canonicalization process (dataset poisoning).
  final ComplexityLimits complexityLimits;

  /// Base constructor for canonicalizer implementations.
  ///
  /// Subclasses must provide the [hashAlgorithm] and [complexityLimits]
  /// they will use.
  Canonicalizer(this.hashAlgorithm, this.complexityLimits);

  /// Transforms the input RDF [dataset] into its canonical string representation
  /// based on the specific algorithm implemented by the subclass.
  ///
  /// Returns the canonical form, usually as a string formatted according
  /// to the N-Quads specification. This output is guaranteed to be identical
  /// for any two datasets that are logically equivalent according to the chosen
  /// algorithm.
  ///
  /// Throws:
  ///   - [ArgumentError] or similar if the input [dataset] is invalid.
  ///   - [MaxIterationsExceededException] or other algorithm-specific exceptions
  ///     if complexity limits are breached or other canonicalization errors occur.
  String canonicalize(Dataset dataset);

  /// Creates an instance of a specific canonicalization algorithm implementation.
  ///
  /// This factory provides a convenient way to select and instantiate the
  /// desired canonicalizer without needing to know the specific class names.
  ///
  /// Parameters:
  ///   - [algorithm]: The desired canonicalization algorithm (e.g.,
  ///     [CanonicalizationAlgorithm.rdfc10]).
  ///   - [hashAlgorithm]: (Optional) The hash function to use internally.
  ///     Defaults to SHA-256 ([sha256]).
  ///   - [complexityLimits]: (Optional) The complexity constraints to apply.
  ///     Defaults to [ComplexityLimits.high].
  ///
  /// Returns: An instance of the requested [Canonicalizer] subclass.
  factory Canonicalizer.create(CanonicalizationAlgorithm algorithm, {
    Hash hashAlgorithm = sha256,
    ComplexityLimits complexityLimits = ComplexityLimits.high
  }) {
    switch (algorithm) {
      case CanonicalizationAlgorithm.rdfc10:
        return Rdfc10Canonicalizer(hashAlgorithm, complexityLimits);
      case CanonicalizationAlgorithm.urdna2015:
        throw UnimplementedError('URGNA2015 canonicalization is not implemented.');
      case CanonicalizationAlgorithm.urgna2012:
        throw UnimplementedError('URGNA2012 canonicalization is not implemented.');
    }
  }
}
