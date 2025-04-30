import 'package:rdf_dart/src/exceptions/invalid_term_exception.dart';

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