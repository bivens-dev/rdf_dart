import 'package:intl/locale.dart';
import 'package:meta/meta.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/data_types.dart';
import 'package:rdf_dart/src/exceptions.dart';
import 'package:rdf_dart/src/iri.dart';
import 'package:rdf_dart/src/rdf_term.dart';
import 'package:rdf_dart/src/term_type.dart';

/// Represents a literal value in an RDF graph.
///
/// A literal consists of:
/// - A [lexicalForm]: The string representation.
/// - A [datatype]: An [IRI] specifying the data type (e.g., `xsd:string`, `xsd:integer`).
/// - Optionally, a [language] tag: A [Locale] for language-tagged strings (datatype `rdf:langString`).
/// - Optionally, a [baseDirection]: A [TextDirection] (`ltr` or `rtl`) for
///   language-tagged strings, indicating the base text direction (RDF 1.2 feature).
///
/// Literals are immutable. Equality is based on the lexical form, datatype,
/// language tag (case-insensitive), and direction.
///
/// Example:
///
/// ```dart
/// // A string literal
/// final stringLiteral = Literal('Hello, world!', XSD.string);
///
/// // An integer literal (original lexical form "042" is preserved for equality)
/// final integerLiteral = Literal('042', XSD.integer);
/// print(integerLiteral.lexicalForm); // Output: 042
/// print(integerLiteral.value); // Output: 42 (as BigInt)
/// print(integerLiteral.getCanonicalLexicalForm()); // Output: 42
///
/// //A string literal with language tag
/// final frenchLiteral = Literal('Bonjour le monde!', RDF.langString, 'fr');
///
/// // Literal with language and direction (RDF 1.2)
/// final arabicLiteral = Literal(
///   'مرحبا بالعالم',
///   RDF.langString,
///   'ar',
///   direction: TextDirection.rtl,
/// );
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

  /// The base text direction (optional, RDF 1.2).
  ///
  /// This indicates the base direction (`ltr` or `rtl`) for the literal's text.
  /// It MUST only be present if the [language] tag is also present, and the
  /// [datatype] MUST be `rdf:langString`.
  final TextDirection? baseDirection;

  /// The parsed value of the literal.
  ///
  /// This is an object of the type specified by the datatype.
  final Object value;

  /// Creates a new Literal.
  ///
  /// - [lexicalForm]: The original string representation. Used for equality.
  /// - [datatype]: The [IRI] specifying the type (e.g., `XSD.string`, `RDF.langString`).
  /// - [languageTag]: Optional BCP47 string, parsed into [language]. MUST be
  ///   present if `datatype` is `RDF.langString`, and absent otherwise.
  /// - [baseDirection]: Optional [TextDirection]. MUST be absent if [languageTag]
  ///   is absent. If present, [datatype] MUST be `RDF.langString`.
  ///
  /// Throws:
  /// - [InvalidLexicalFormException] if the [lexicalForm] is invalid for the [datatype].
  /// - [DatatypeNotFoundException] if the [datatype] is not recognized.
  /// - [InvalidLanguageTagException] if the [languageTag] format is invalid.
  /// - [LiteralConstraintException] if constraints regarding language, direction,
  ///   and `rdf:langString` are violated.
  ///
  /// Example:
  /// ```dart
  /// final myLiteral = Literal('example', XSD.string);
  /// final langLiteral = Literal('chat', RDF.langString, 'fr');
  /// final directedLiteral = Literal('שָׁלוֹם', RDF.langString, 'he', direction: TextDirection.rtl);
  /// try {
  ///   // Invalid: direction without language
  ///   final invalid1 = Literal('test', XSD.string, null, direction: TextDirection.ltr);
  /// } on LiteralConstraintException catch (e) { print(e); }
  /// try {
  ///   // Invalid: direction with wrong datatype
  ///   final invalid2 = Literal('test', XSD.string, 'en', direction: TextDirection.ltr);
  /// } on LiteralConstraintException catch (e) { print(e); }
  /// try {
  ///   // Invalid: langString without language
  ///   final invalid3 = Literal('test', RDF.langString);
  /// } on LiteralConstraintException catch (e) { print(e); }
  /// ```
  Literal(
    this.lexicalForm,
    this.datatype, [
    String? languageTag,
    this.baseDirection,
  ])
    // Eagerly parse the value
    : value = _parseValue(lexicalForm, datatype, languageTag),
       // Parse and validate the language tag based on datatype
       language = _parseLanguage(languageTag, datatype) {
    // Additional validation after fields are initialized (e.g., lang tag presence for rdf:langString)
    _validateConstraints(language, datatype, baseDirection);
  }

  /// Internal helper to parse the lexical form.
  static Object _parseValue(
    String lexicalForm,
    IRI datatype,
    String? languageTag,
  ) {
    try {
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

  /// Validates constraints related to language tags, direction, and the datatype.
  /// Called after fields are initialized (implicitly via constructor order).
  static void _validateConstraints(
    Locale? language,
    IRI datatype,
    TextDirection? direction,
  ) {
    if (datatype == RDF.langString) {
      // Datatype is rdf:langString
      if (language == null) {
        throw LiteralConstraintException(
          'Language tag MUST be present for datatype rdf:langString.',
        );
      }
      // Direction is allowed only with langString, but not required
    } else {
      // Datatype is NOT rdf:langString
      if (language != null) {
        throw LiteralConstraintException(
          //
          'Language tag MUST NOT be present if datatype is not rdf:langString.',
        );
      }
      if (direction != null) {
        // This also covers the case where language is null but direction is not
        throw LiteralConstraintException(
          //
          'Direction MUST NOT be present if datatype is not rdf:langString.',
        );
      }
    }

    // Additional constraint: Direction requires Language
    if (direction != null && language == null) {
      // This situation should ideally be caught by the logic above,
      // but an explicit check adds clarity and robustness.
      throw LiteralConstraintException(
        //
        'Direction MUST NOT be present if the language tag is absent.',
      );
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
    } else if (datatype == XSD.string) {
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
  /// Throws a [LiteralConstraintException] if formatting fails.
  String getCanonicalLexicalForm() {
    try {
      final formatter = DatatypeRegistry().getDatatypeInfo(datatype).formatter;
      return formatter(value);
    } on Exception catch (e) {
      throw LiteralConstraintException(
        'Unable to format literal value $value with datatype $datatype.\n$e',
      );
    }
  }

  /// Computes the hash code based on term equality rules.
  /// Uses [lexicalForm], [datatype], [language] adn [baseDirection].
  /// Note: `language?.hashCode` handles null correctly. `Locale` hashCode
  /// should be case-insensitive appropriate for language tags.
  @override
  int get hashCode =>
      Object.hash(termType, lexicalForm, datatype, language, baseDirection);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Literal &&
        lexicalForm == other.lexicalForm && // Case-sensitive
        datatype == other.datatype && // IRI equality
        language == other.language && // Locale equality (handles null & case)
        baseDirection == other.baseDirection;
  }
}

/// Represents the base direction of text as defined in RDF 1.2 Concepts.
///
/// Used with language-tagged literals (datatype `rdf:langString`).
/// See: https://www.w3.org/TR/rdf12-concepts/#section-Graph-Literal
enum TextDirection {
  /// Left-to-right text direction.
  ltr,

  /// Right-to-left text direction.
  rtl,
}
