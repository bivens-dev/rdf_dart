import 'data_type.dart';

/// Represents the `xsd:token` datatype.
///
/// The `xsd:token` datatype represents tokenized strings.  It is defined by
/// the W3C XML Schema Definition Language (XSD) 1.1 Part 2: Datatypes
/// specification.
///
/// **Lexical Space:**
///
/// The lexical space (and value space) of `xsd:token` consists of strings that:
///
/// *   Do not contain the carriage return (`\r`), line feed (`\n`), or tab (`\t`)
///     characters.
/// *   Have no leading or trailing spaces (` `).
/// *   Have no internal sequences of two or more spaces.
///
/// **Value Space:**
///
/// The value space of `xsd:token` is the same as its lexical space. The strings
/// are themselves the values.
///
/// **Lexical-to-Value Mapping:**
///
/// The lexical-to-value mapping is the identity mapping.  Each valid lexical
/// form maps to itself as the value.
///
/// **Canonical Representation:**
///
/// The canonical representation is the same as the lexical representation.
///
/// See also:
/// *   [XSD 1.1 Datatypes: token](https://www.w3.org/TR/xmlschema11-2/#token)
class XSDToken extends RDFDataType<String> {
  /// The IRI for the `xsd:token` datatype.
  static const String _iri = 'http://www.w3.org/2001/XMLSchema#token';

  /// Creates an `XSDToken` instance.
  const XSDToken() : super(XSDToken._iri);

  /// Regular expression for validating `xsd:token` lexical forms.  This
  /// regex ensures that the string:
  /// 1. Does not start with a space, tab, carriage return, or newline.
  /// 2. Does not end with a space, tab, carriage return, or newline.
  /// 3. Does not contain two or more consecutive spaces.
  /// 4. Does not contain tabs returns or new lines.
  static final RegExp _lexicalRegex = RegExp(
    r'^[^ \t\r\n](?:[^ \t\r\n]| (?! ))*[^ \t\r\n]$',
  );

  @override
  String lexicalToValue(String lexicalForm) {
    if (!_lexicalRegex.hasMatch(lexicalForm)) {
      throw FormatException('Invalid lexical form for xsd:token: $lexicalForm');
    }
    return lexicalForm; // Identity mapping
  }

  @override
  String valueToLexical(String value) {
    // The value *is* the lexical representation for xsd:token.  We
    // validate to ensure it conforms.
    if (!_lexicalRegex.hasMatch(value)) {
      throw ArgumentError(
        'The provided value does not conform to the xsd:token lexical format rules.',
      );
    }
    return value;
  }

  @override
  bool isValidLexicalForm(String lexicalForm) {
    return _lexicalRegex.hasMatch(lexicalForm);
  }
}
