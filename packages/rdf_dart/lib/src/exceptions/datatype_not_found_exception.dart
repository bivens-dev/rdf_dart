import 'package:rdf_dart/src/exceptions/invalid_term_exception.dart';

/// Exception thrown when a required datatype IRI is not found in the registry
/// or is not supported by the library.
///
/// This typically occurs during literal validation or creation if the
/// specified datatype IRI does not correspond to a known XSD datatype
/// or a registered custom datatype.
class DatatypeNotFoundException extends InvalidTermException {
  /// The IRI of the datatype that was not found.
  final String datatypeIri;

  /// Creates a new [DatatypeNotFoundException] for the specified [datatypeIri].
  DatatypeNotFoundException(this.datatypeIri)
    : super('Datatype IRI <$datatypeIri> not found in registry.');

  @override
  String toString() => 'DatatypeNotFoundException: $message';
}
