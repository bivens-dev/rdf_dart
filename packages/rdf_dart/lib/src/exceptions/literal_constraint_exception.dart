import 'package:rdf_dart/src/exceptions/invalid_term_exception.dart';

/// Exception thrown for violations of RDF literal constraints.
///
/// This includes specific rules defined in the RDF Concepts specification, such as:
///   - Literals with a language tag must have the datatype `rdf:langString`.
///   - Literals with datatype `rdf:langString` must have a language tag.
///
/// See: https://www.w3.org/TR/rdf12-concepts/#section-Graph-Literal
class LiteralConstraintException extends InvalidTermException {
  /// Creates a new [LiteralConstraintException] with the given [message]
  /// detailing the violated constraint.
  LiteralConstraintException(super.message);

  @override
  String toString() => 'LiteralConstraintException: $message';
}
