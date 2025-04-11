/// Base class for exceptions specific to the RDF Dart library.
///
/// This class serves as the root for all custom exceptions thrown by this
/// library, allowing users to catch all RDF-related issues with a single
/// `catch (RDFException)`.
class RDFException implements Exception {
  /// A message describing the specific exception that occurred.
  final String message;

  /// Creates a new [RDFException] with the given [message].
  RDFException(this.message);

  @override
  String toString() => 'RDFException: $message';
}

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

/// Exception thrown when a literal's lexical form is invalid according to the
/// rules of its specified datatype.
///
/// For example, throwing this if "abc" is provided as the lexical form for
/// the datatype `xsd:integer`.
class InvalidLexicalFormException extends InvalidTermException {
  /// The invalid lexical form encountered.
  final String lexicalForm;
  /// The IRI of the datatype for which the [lexicalForm] is invalid.
  final String datatypeIri;
  /// Optional underlying exception that caused this validation failure,
  /// such as a [FormatException] during parsing.
  final Object? cause;

  /// Creates a new [InvalidLexicalFormException].
  ///
  /// Takes the invalid [lexicalForm], the associated [datatypeIri], and an
  /// optional [cause] for the underlying error.
  InvalidLexicalFormException(this.lexicalForm, this.datatypeIri, {this.cause})
      : super('Invalid lexical form "$lexicalForm" for datatype <$datatypeIri>.');

  @override
  String toString() {
    var msg = 'InvalidLexicalFormException: $message';
    if (cause != null) {
      msg += '\nCaused by: $cause';
    }
    return msg;
  }
}

/// Exception thrown when a language tag string is not well-formed according
/// to BCP 47 syntax.
///
/// See: https://www.w3.org/TR/rdf12-concepts/#section-Graph-Literal
class InvalidLanguageTagException extends InvalidTermException {
  /// The invalid language tag string.
  final String languageTag;

  /// Creates a new [InvalidLanguageTagException] for the invalid [languageTag].
  InvalidLanguageTagException(this.languageTag)
      : super('Invalid BCP47 language tag: "$languageTag".');

  @override
  String toString() => 'InvalidLanguageTagException: $message';
}

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
