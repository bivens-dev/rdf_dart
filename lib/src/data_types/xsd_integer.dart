import 'data_type.dart';

/// Represents the `xsd:integer` datatype.
///
/// The `xsd:integer` datatype represents integer numbers (positive, negative,
/// or zero). It is derived from `xsd:decimal` by restricting the fractional
/// digits to zero and disallowing the trailing decimal point. It is defined
/// by the W3C XML Schema Definition Language (XSD) 1.1 Part 2: Datatypes
/// specification.
///
/// **Lexical Space:**
///
/// The lexical space consists of a finite-length sequence of one or more
/// decimal digits (`0` through `9`), optionally preceded by a plus (`+`) or
/// minus (`-`) sign.  If the sign is omitted, `+` is assumed.
///
/// Examples:
///
/// *   `-1`
/// *   `0`
/// *   `12678967543233`
/// *   `+100000`
///
/// **Value Space:**
///
/// The value space is the infinite set of integers: {..., -2, -1, 0, 1, 2, ...}.
///
/// **Lexical-to-Value Mapping:**
///
/// The lexical representation is mapped to its corresponding integer value.
///
/// **Canonical Representation:**
///
/// The canonical representation *prohibits* the optional leading `+` sign
/// and leading zeros.
///
/// Examples:
///
/// *   `-1` (canonical)
/// *   `0` (canonical)
/// *  `123` (canonical)
/// *  `+00123` is valid but not canonical, its canonical form is `123`
///
/// See also:
/// *   [XSD 1.1 Datatypes: integer](https://www.w3.org/TR/xmlschema11-2/#integer)
class XSDInteger extends RDFDataType<BigInt> {
  /// The IRI for the `xsd:integer` datatype.
  static const String _iri = 'http://www.w3.org/2001/XMLSchema#integer';

  /// Creates an `XSDInteger` instance.
  const XSDInteger() : super(XSDInteger._iri);

  /// Regular expression for validating the lexical form of an integer.
  /// Allows an optional leading '+' or '-' sign, followed by one or more digits.
  static final RegExp _lexicalRegex = RegExp(r'^[\+\-]?\d+$');

  /// Regular expression for validating the *canonical* lexical form
  ///  of an integer.
  /// It enforces no leading `+` and no leading zeros (except for the value 0).
  static final RegExp _canonicalRegex = RegExp(r'^(-0|0|-?[1-9]\d*)$');

  @override
  BigInt lexicalToValue(String lexicalForm) {
    if (!_lexicalRegex.hasMatch(lexicalForm)) {
      throw FormatException(
        'Invalid lexical form for xsd:integer: $lexicalForm',
      );
    }
    try {
      return BigInt.parse(lexicalForm);
    } on FormatException {
      // This should not happen if the regex is correct,
      // but we keep it for safety.
      throw FormatException(
        'Invalid lexical form for xsd:integer: $lexicalForm',
      );
    }
  }

  @override
  String valueToLexical(BigInt value) {
    final lexicalForm = value.toString();
    if (!_canonicalRegex.hasMatch(lexicalForm)) {
      throw ArgumentError(
        'The provided value $value has a non-canonical lexical form: $lexicalForm',
      );
    }
    return lexicalForm; // BigInt.toString() provides the canonical form
  }

  @override
  bool isValidLexicalForm(String lexicalForm) {
    return _lexicalRegex.hasMatch(lexicalForm);
  }
}
