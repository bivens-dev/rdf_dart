import 'package:intl/locale.dart';
import 'package:meta/meta.dart';
import 'package:rdf_dart/src/data_types.dart';
import 'package:rdf_dart/src/exceptions.dart';
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
/// final stringLiteral = Literal('Hello, world!', IRI(XMLDataType.string.iri));
///
/// // An integer literal (original lexical form "042" is preserved for equality)
/// final integerLiteral = Literal('042', IRI(XMLDataType.integer.iri));
/// print(integerLiteral.lexicalForm); // Output: 042
/// print(integerLiteral.value); // Output: 42 (as BigInt)
/// print(integerLiteral.getCanonicalLexicalForm()); // Output: 42
///
/// //A string literal with language tag
/// final frenchLiteral = Literal('Bonjour le monde!', IRI(XMLDataType.string.iri), 'fr');
/// ```
@immutable
class Literal extends RdfTerm {
  /// The original lexical form of the literal as provided during construction.
  ///
  /// This is the string representation used for term equality comparisons.
  final String lexicalForm;

  /// The datatype of the literal.
  ///
  /// This is an [IRI] that specifies the type of the literal's value.
  /// Common datatypes include `xsd:string`, `xsd:integer`, `xsd:dateTime`, etc.
  final IRI datatype;

  /// The language tag of the literal (optional).
  ///
  /// This is a [Locale] object representing the language of the literal's text,
  /// if applicable (typically for literals with datatype `rdf:langString`).
  /// If not specified, it's `null`. Comparison is case-insensitive.
  final Locale? language;

  /// The parsed value of the literal.
  ///
  /// This is an object of the type specified by the datatype.
  final Object value;

  /// Creates a new Literal with the given [lexicalForm], [datatype], and
  /// optional [languageTag].
  ///
  /// The [lexicalForm] is the original string representation. It is stored and
  /// used for term equality.
  /// The [datatype] is an [IRI] specifying the type.
  /// The optional [languageTag] (a BCP47 string) is parsed into a [Locale]
  /// for the [language] field.
  ///
  /// The constructor eagerly parses the [lexicalForm] based on the [datatype]
  /// and stores the result in [value]. It will throw an appropriate exception
  /// (e.g., `InvalidLexicalFormException`, `DatatypeNotFoundException`) if
  /// parsing fails or the inputs are invalid (e.g., language tag provided
  /// for non-langString datatype, invalid tag format).
  ///
  /// Example:
  /// ```dart
  /// final myLiteral = Literal('example', IRI(XMLDataType.string.iri));
  /// final langLiteral = Literal('chat', IRI('[http://www.w3.org/1999/02/22-rdf-syntax-ns#langString](http://www.w3.org/1999/02/22-rdf-syntax-ns#langString)'), 'fr');
  /// ```
  Literal(this.lexicalForm, this.datatype, [String? languageTag])
    // Eagerly parse the value
    : value = _parseValue(lexicalForm, datatype, languageTag),
      // Parse and validate the language tag based on datatype
      language = _parseLanguage(languageTag, datatype) {
    // Additional validation after fields are initialized (e.g., lang tag presence for rdf:langString)
    _validateLangStringConstraints(language, datatype);
  }

  /// Internal helper to parse the lexical form.
  static Object _parseValue(
    String lexicalForm,
    IRI datatype,
    String? languageTag,
  ) {
    try {
      // getDatatypeInfo now throws DatatypeNotFoundException
      final info = DatatypeRegistry().getDatatypeInfo(datatype);
      final parser = info.parser;
      // Wrap potential FormatException from parser
      return parser(lexicalForm);
    } on FormatException catch (e) {
      // Wrap FormatException in our custom exception
      throw InvalidLexicalFormException(
        lexicalForm,
        datatype.toString(),
        cause: e,
      );
    }
  }

  /// Internal helper to parse the language tag string into a Locale.
  static Locale? _parseLanguage(String? languageTag, IRI datatype) {
    if (languageTag == null) {
      return null;
    }
    final locale = Locale.tryParse(languageTag);
    if (locale == null) {
      throw InvalidLanguageTagException(languageTag);
    }
    return locale;
  }

  /// Validates constraints related to language tags and the rdf:langString datatype.
  /// Called after fields are initialized.
  static void _validateLangStringConstraints(Locale? language, IRI datatype) {
    final langStringDataType = IRI(
      'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
    );

    if (datatype == langStringDataType) {
      if (language == null) {
        throw LiteralConstraintException(
          'Language tag MUST be present for datatype rdf:langString.',
        );
      }
    } else {
      if (language != null) {
        throw LiteralConstraintException(
          'Language tag MUST NOT be present if datatype is not rdf:langString.',
        );
      }
    }
  }

  @override
  bool get isIRI => false;

  @override
  bool get isBlankNode => false;

  @override
  bool get isLiteral => true;

  @override
  bool get isTripleTerm => false;

  @override
  TermType get termType => TermType.literal;

  @override
  String toString() {
    // Use originalLexicalForm for display
    final escapedLexical = lexicalForm
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"');

    if (language != null) {
      // Language tag implies rdf:langString, use original form + tag
      return '"$escapedLexical"@${language!.toLanguageTag()}';
    } else if (datatype == IRI('http://www.w3.org/2001/XMLSchema#string')) {
      // Simple string, just the original form in quotes
      return '"$escapedLexical"';
    } else {
      // Other datatypes: original form in quotes + ^^<datatype>
      // (Note: N-Triples/Turtle might require different escaping here)
      return '"$escapedLexical"^^<$datatype>';
    }
  }

  /// Returns the canonical lexical form according to the datatype's rules.
  ///
  /// This uses the formatter associated with the datatype to generate a
  /// potentially normalized string representation from the parsed [value].
  String getCanonicalLexicalForm() {
    // TODO: Handle potential errors during formatting?
    final formatter = DatatypeRegistry().getDatatypeInfo(datatype).formatter;
    return formatter(value);
  }

  /// Computes the hash code based on term equality rules.
  /// Uses [lexicalForm], [datatype], and [language].
  /// Note: `language?.hashCode` handles null correctly. `Locale` hashCode
  /// should be case-insensitive appropriate for language tags.
  @override
  int get hashCode => Object.hash(termType, lexicalForm, datatype, language);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Literal &&
        lexicalForm == other.lexicalForm && // Case-sensitive
        datatype == other.datatype && // IRI equality
        language == other.language; // Locale equality (handles null & case)
  }
}
