import 'package:decimal/decimal.dart';

import 'package:rdf_dart/src/data_types/data_type.dart';

/// Represents the `xsd:decimal` datatype.
///
/// The `xsd:decimal` datatype represents a subset of the real numbers that
/// can be represented by decimal numerals.  It is defined by the W3C XML
/// Schema Definition Language (XSD) 1.1 Part 2: Datatypes specification.
///
/// **Lexical Space:**
///
/// The lexical space allows for:
///
/// *   An optional leading plus (`+`) or minus (`-`) sign.
/// *   A sequence of decimal digits (`0` through `9`).
/// *   An optional decimal point (`.`).
///
/// Leading and trailing zeros are allowed but are not significant (except for
/// determining the precision, which is not relevant for this implementation
/// since we are targeting RDF, which does not support the XSD `precisionDecimal`
/// type).
///
/// **Value Space:**
///
/// The value space includes all numbers that can be expressed as *i* / 10<sup>*n*</sup>,
/// where *i* is an integer and *n* is a non-negative integer.  This
/// includes all finite-length decimal numbers.  Precision is *not* reflected
/// in the value space (e.g., 2.0 and 2.00 are the same value).
///
/// **Lexical-to-Value Mapping:**
///
/// The lexical representation is mapped to its corresponding decimal value
/// using standard decimal arithmetic.
///
/// **Canonical Representation:**
///
/// The canonical representation:
///
/// *   Prohibits the optional leading `+` sign.
/// *   Prohibits leading zeros in the integer part, except for a single zero
///     when the value is between -1 and 1.
/// *   Prohibits trailing zeros in the fractional part.
/// *   Requires at least one digit to the left and to the right of the decimal
///     point.
///
/// See also:
/// *   [XSD 1.1 Datatypes: decimal](https://www.w3.org/TR/xmlschema11-2/#decimal)
class XSDDecimal extends RDFDataType<Decimal> {
  /// The IRI for the `xsd:decimal` datatype.
  static const String _iri = 'http://www.w3.org/2001/XMLSchema#decimal';

  /// Creates an `XSDDecimal` instance.
  const XSDDecimal() : super(XSDDecimal._iri);

  /// Regular expression for validating the lexical form of a decimal.
  static final RegExp _lexicalRegex = RegExp(r'^[\+\-]?(\d+(\.\d*)?|\.\d+)$');

  /// Regular expression for validating the *canonical* lexical form
  /// of an decimal. It enforces no leading `+` and
  /// no leading zeros (except for the value 0).
  static final RegExp _canonicalRegex = RegExp(
    r'^(-?(?:0|[1-9]\d*)(?:\.\d+)?)$',
  );

  @override
  Decimal lexicalToValue(String lexicalForm) {
    if (!_lexicalRegex.hasMatch(lexicalForm)) {
      throw FormatException(
        'Invalid lexical form for xsd:decimal: $lexicalForm',
      );
    }
    try {
      // Add a leading '0' if it starts with '.', to be valid for Decimal.parse
      if (lexicalForm.startsWith('.')) {
        lexicalForm = '0$lexicalForm';
      }
      // Add a trailing '0' if it ends with '.', to be valid for Decimal.parse
      if (lexicalForm.endsWith('.')) {
        lexicalForm += '0';
      }

      final parsedValue = Decimal.parse(lexicalForm);
      // Check for canonical form *after* parsing.
      if (!_isCanonical(valueToLexical(parsedValue))) {
        throw FormatException(
          'Lexical form is not canonical for xsd:decimal: $lexicalForm',
        );
      }

      return parsedValue;
    } on FormatException {
      throw FormatException(
        'Invalid lexical form for xsd:decimal: $lexicalForm',
      );
    }
  }

  @override
  String valueToLexical(Decimal value) {
    // Use toStringAsFixed to get a decimal representation, then remove
    // trailing zeros and the decimal point if possible.
    var canonical = value.toStringAsFixed(
      value.scale,
    ); // Keep all original fractional digits
    canonical = canonical.replaceAll(
      RegExp(r'0+$'),
      '',
    ); // Remove trailing zeros
    if (canonical.endsWith('.')) {
      canonical = canonical.substring(
        0,
        canonical.length - 1,
      ); // Remove trailing .
    }
    if (canonical.startsWith('+')) {
      canonical = canonical.substring(1); //Remove leading +
    }
    // Ensure that if a decimal point exists, there is a 0 before,
    // and after the decimal, if not add a 0
    if (canonical.startsWith('.')) {
      canonical = '0$canonical';
    }

    if (canonical.contains('.') && !canonical.contains(RegExp('[1-9]'))) {
      // Contains only 0 and .
      canonical = '0';
    }

    if (canonical.isEmpty) {
      return '0';
    }

    return canonical;
  }

  @override
  bool isValidLexicalForm(String lexicalForm) {
    return _lexicalRegex.hasMatch(lexicalForm);
  }

  /// Checks if the given [lexicalForm] is in canonical form.
  bool _isCanonical(String lexicalForm) {
    return _canonicalRegex.hasMatch(lexicalForm);
  }
}
