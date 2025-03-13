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
      final validatedUri = Uri.parse(unvalidatedIri);

      // Additional checks after Uri.parse
      if (!_isValidPercentEncoding(validatedUri, unvalidatedIri)) {
        throw InvalidIRIException(
          'Invalid IRI: $unvalidatedIri - Error: Invalid percent-encoding',
        );
      }
      // TODO: Use more robust IRI validation here in the future but this is sufficient for now.
      return validatedUri.toString();
    } on FormatException catch (e) {
      throw InvalidIRIException(
        'Invalid IRI: $unvalidatedIri - Error: ${e.message}',
      );
    }
  }

  /// Checks if the uri has valid percent-encoding.
  ///
  /// According to RFC 3987, each percent-encoded sequence must consist of a
  /// percent sign ("%") followed by two hexadecimal digits ([0-9A-Fa-f]).
  ///
  /// This function checks for this.
  static bool _isValidPercentEncoding(Uri uri, String iri) {
    final pattern = RegExp('%[0-9A-Fa-f]{2}');

    final allMatches = pattern.allMatches(iri);
    // check that the percent encoding matches a correct form.
    for (final match in allMatches) {
      if (match.group(0)!.length != 3) {
        return false;
      }
    }

    // Check that a percent is always followed by two hex digits
    // iterate over the string and check that every % is followed by two hex digits.
    for (var i = 0; i < iri.length; i++) {
      if (iri[i] == '%') {
        if (i + 2 >= iri.length) {
          return false;
        }
        if (!RegExp('[0-9A-Fa-f]{2}').hasMatch(iri.substring(i + 1, i + 3))) {
          return false;
        }
      }
    }
    return true;
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
