import 'package:rdf_dart/src/iri.dart';
import 'package:rdf_dart/src/rdf_term.dart';
import 'package:rdf_dart/src/term_type.dart';

/// Represents a literal value in an RDF graph.
///
/// A literal is a data value, such as a string, number, or date. It has a
/// lexical form (the way it is written), a datatype IRI (specifying the type
/// of the data), and optionally a language tag (for text literals).
///
/// The [lexicalForm] represents the literal's value as a string.
/// The [datatype] specifies the type of the literal, and the [language] is
/// an optional language tag for text literals.
///
/// Example:
///
/// ```dart
/// // A string literal
/// final stringLiteral = Literal('Hello, world!', IRI('http://www.w3.org/2001/XMLSchema#string'));
///
/// // An integer literal
/// final integerLiteral = Literal('42', IRI('http://www.w3.org/2001/XMLSchema#integer'));
///
/// // A string literal with language tag
/// final frenchLiteral = Literal('Bonjour le monde!', IRI('http://www.w3.org/2001/XMLSchema#string'), 'fr');
/// ```
class Literal extends RdfTerm {
  /// The lexical form of the literal.
  ///
  /// This is the string representation of the literal's value.
  final String lexicalForm;

  /// The datatype of the literal.
  ///
  /// This is an [IRI] that specifies the type of the literal's value.
  /// Common datatypes include `xsd:string`, `xsd:integer`, `xsd:dateTime`, etc.
  final IRI datatype;

  /// The language tag of the literal (optional).
  ///
  /// This is a string representing the language of the literal's text, if
  /// applicable. For example, 'en' for English or 'fr' for French. If not
  /// specified, it's `null`.
  final String? language;

  /// Creates a new Literal with the given [lexicalForm], [datatype], and
  /// optional [language].
  ///
  /// The [lexicalForm] is the string representation of the literal's value.
  /// The [datatype] is an [IRI] that specifies the type of the literal's value.
  /// The optional [language] is a language tag for text literals.
  ///
  /// Example:
  /// ```dart
  /// final myLiteral = Literal('example', IRI('http://www.w3.org/2001/XMLSchema#string'));
  /// ```
  Literal(this.lexicalForm, this.datatype, [this.language]);

  @override
  bool get isIRI => false;

  @override
  bool get isBlankNode => false;

  @override
  bool get isLiteral => true;

  @override
  TermType get termType => TermType.literal;

  @override
  String toString() {
    String result = '"$lexicalForm"';
    if (language != null) {
      result += "@$language";
    }
    if (datatype.value != 'http://www.w3.org/2001/XMLSchema#string') {
      result += "^^<$datatype>";
    }
    return result;
  }

  @override
  int get hashCode => Object.hash(lexicalForm, datatype, language);

  @override
  bool operator ==(Object other) =>
      other is Literal &&
      lexicalForm == other.lexicalForm &&
      datatype == other.datatype &&
      language == other.language;
}
