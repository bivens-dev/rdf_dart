import 'package:rdf_dart/src/exceptions/invalid_term_exception.dart';

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
