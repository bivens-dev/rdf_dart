import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/canonicalization/canonicalizer.dart';

/// Implements the URDNA2015 canonicalization algorithm.
final class Urdna2015Canonicalizer extends Canonicalizer {

  Urdna2015Canonicalizer(super.hashAlgorithm);

  @override
  String canonicalize(Dataset dataset) {
    // --- Implementation of URDNA2015 Algorithm Steps ---
    // Very similar to RDFC-1.0, but with potential minor differences,
    // especially in the final N-Quads serialization format (e.g., blank node prefixes).
    // We will reuse much of the RDFC-1.0 logic.

    // Placeholder:
    throw UnimplementedError('URDNA2015 canonicalization not yet implemented.');
  }
}