import 'package:rdf_dart/src/exceptions/rdf_exception.dart';

/// Base class for exceptions related to invalid RDF terms.
///
/// This includes issues with IRIs, Blank Nodes, or Literals that violate
/// RDF constraints or syntax rules.
class InvalidTermException extends RDFException {
  /// Creates a new [InvalidTermException] with the given [message].
  InvalidTermException(super.message);

  @override
  String toString() => 'InvalidTermException: $message';
}
