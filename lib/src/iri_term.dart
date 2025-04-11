import 'package:meta/meta.dart';
import 'package:rdf_dart/src/iri.dart';
import 'package:rdf_dart/src/rdf_term.dart';
import 'package:rdf_dart/src/subject_type.dart';
import 'package:rdf_dart/src/term_type.dart';

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
class IRITerm extends RdfTerm implements SubjectTerm {
  /// The string value of this IRI.
  final IRI value;

  /// Creates a new IRI from the given [value] string.
  ///
  /// The [value] string is validated to ensure it conforms to basic IRI
  /// syntax rules. If the string is not a valid IRI, an
  /// [FormatException] is thrown.
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
  ///   print(e); // Output: FormatException
  /// }
  /// ```
  IRITerm(this.value);

  @override
  bool get isIRI => true;

  @override
  bool get isBlankNode => false;

  @override
  bool get isLiteral => false;

  @override
  bool get isTripleTerm => false;

  @override
  TermType get termType => TermType.iri;

  @override
  String toString() => value.toString();

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is IRITerm && value.hashCode == other.value.hashCode;
}
