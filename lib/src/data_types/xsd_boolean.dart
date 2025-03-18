import 'data_type.dart';

/// Represents the `xsd:boolean` datatype.
///
/// The `xsd:boolean` datatype represents the values of two-valued logic,
/// namely `true` and `false`.  It is defined by the W3C XML Schema Definition
/// Language (XSD) 1.1 Part 2: Datatypes specification.
///
/// **Lexical Space:**
///
/// The lexical space (valid string representations) for `xsd:boolean` consists
/// of the following four strings:
///
/// *   `"true"`
/// *   `"false"`
/// *   `"1"`
/// *   `"0"`
///
/// **Value Space:**
///
/// The value space for `xsd:boolean` consists of the two boolean values:
///
/// *   `true`
/// *   `false`
///
/// **Lexical-to-Value Mapping:**
///
/// *   `"true"` and `"1"` map to the value `true`.
/// *   `"false"` and `"0"` map to the value `false`.
///
/// **Canonical Representation:**
///
/// The canonical representations are `"true"` for `true` and `"false"` for `false`.
///
/// See also:
/// *   [XSD 1.1 Datatypes: boolean](https://www.w3.org/TR/xmlschema11-2/#boolean)
class XSDBoolean extends RDFDataType<bool> {
  /// The IRI for the `xsd:boolean` datatype.
  static const String _iri = 'http://www.w3.org/2001/XMLSchema#boolean';

  /// Creates an `XSDBoolean` instance.
  const XSDBoolean() : super(XSDBoolean._iri);

  /// Regular expression for validating and parsing `xsd:boolean` lexical forms.
  static final RegExp _lexicalRegex = RegExp(r'^(true|false|1|0)$');

  @override
  bool lexicalToValue(String lexicalForm) {
    if (!_lexicalRegex.hasMatch(lexicalForm)) {
      throw FormatException(
        'Invalid lexical form for xsd:boolean: $lexicalForm',
      );
    }
    switch (lexicalForm) {
      case 'true':
      case '1':
        return true;
      case 'false':
      case '0':
        return false;
      default: // Should never happen due to regex, but for completeness
        throw FormatException(
          'Invalid lexical form for xsd:boolean: $lexicalForm',
        );
    }
  }

  @override
  String valueToLexical(bool value) {
    return value.toString(); // Canonical form: "true" or "false"
  }

  @override
  bool isValidLexicalForm(String lexicalForm) {
    return _lexicalRegex.hasMatch(lexicalForm);
  }
}
