import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/canonicalization/canonicalizer.dart';

/// Placeholder for the URGNA2012 canonicalization algorithm.
/// This algorithm is generally superseded and not planned for initial implementation.
final class Urgna2012Canonicalizer extends Canonicalizer {

  /// Creates an URDNA2012 canonicalizer instance using the specified 
  /// hash algorithm and complexity constraints.
  Urgna2012Canonicalizer(super.hashAlgorithm, super.complexityLimits);

  @override
  String canonicalize(Dataset dataset) {
    throw UnimplementedError(
        'URGNA2012 canonicalization is not implemented.');
  }
}