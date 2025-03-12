import 'package:meta/meta.dart';
import 'package:rdf_dart/src/rdf_term.dart';
import 'package:rdf_dart/src/term_type.dart';

/// Exception thrown when an invalid IRI string is encountered.
///
/// This exception is thrown by the [IRI] class when attempting to
/// create an IRI from a string that does not conform to the IRI syntax
/// rules. The [message] property contains a detailed error message
/// describing the nature of the invalid IRI.
class InvalidIRIException implements Exception {
  /// A message describing the error.
  final String message;

  /// Creates a new [InvalidIRIException] with the given [message].
  InvalidIRIException(this.message);

  @override
  String toString() => 'InvalidIRIException: $message';
}

/// Represents an Internationalized Resource Identifier (IRI).
///
/// An IRI is a string that identifies a resource. This class ensures that the
/// provided IRI string conforms to the basic IRI syntax rules. While this class
/// performs basic validation, it doesn't check whether the resource referred to
/// by the IRI actually exists.
///
/// This class is immutable. Once an IRI object is created, its value cannot
/// be changed.
@immutable
class IRI extends RdfTerm {
  /// The string value of this IRI.
  final String value;

  /// Creates a new IRI from the given [value] string.
  ///
  /// The [value] string is validated to ensure it conforms to basic IRI
  /// syntax rules. If the string is not a valid IRI, an
  /// [InvalidIRIException] is thrown.
  ///
  /// If the IRI is valid, the string is parsed and any necessary percent-encoding
  /// is applied to create a normalized IRI string.
  ///
  /// Example:
  /// ```dart
  /// final validIri = IRI('http://example.com/resource');
  /// print(validIri.value); // Output: http://example.com/resource
  ///
  /// try {
  ///   final invalidIri = IRI('http://example.com /resource');
  /// } on InvalidIRIException catch (e) {
  ///   print(e); // Output: InvalidIRIException: Invalid IRI: http://example.com /resource - Error: ...
  /// }
  /// ```
  IRI(String value) : value = _validateIri(value);

  /// Validates the given [unvalidatedIri] string and returns a valid IRI string.
  ///
  /// If the [unvalidatedIri] string is a valid IRI, it is parsed using
  /// [Uri.parse] and any necessary percent-encoding is applied. The resulting
  /// normalized IRI string is then returned.
  ///
  /// If the [unvalidatedIri] string is not a valid IRI, an
  /// [InvalidIRIException] is thrown.
  ///
  /// For now this uses [Uri.parse] to validate the IRI. In the future, more
  /// robust validation could be implemented.
  static String _validateIri(String unvalidatedIri) {
    try {
      // TODO: Use more robust IRI validation here in the future but URI.parse is sufficient for now.
      final validatedUri = Uri.parse(unvalidatedIri);
      return validatedUri.toString();
    } on FormatException catch (e) {
      throw InvalidIRIException(
        'Invalid IRI: $unvalidatedIri - Error: ${e.message}',
      );
    }
  }

  @override
  bool get isIRI => true;

  @override
  bool get isBlankNode => false;

  @override
  bool get isLiteral => false;

  @override
  TermType get termType => TermType.iri;

  @override
  String toString() => value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is IRI && value == other.value;
}
