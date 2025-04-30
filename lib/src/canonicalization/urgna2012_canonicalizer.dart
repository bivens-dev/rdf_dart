import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/canonicalization/canonicalizer.dart';

/// Placeholder for the URGNA2012 canonicalization algorithm.
/// This algorithm is generally superseded and not planned for initial implementation.
final class Urgna2012Canonicalizer extends Canonicalizer {

  Urgna2012Canonicalizer(super.hashAlgorithm);

  @override
  String canonicalize(Dataset dataset) {
    throw UnimplementedError(
        'URGNA2012 canonicalization is not implemented.');
  }
}