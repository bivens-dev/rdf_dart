import 'data_type.dart';

/// Represents the `xsd:double` datatype.
///
/// The `xsd:double` datatype is based on the IEEE double-precision 64-bit
/// floating-point type.  It is defined by the W3C XML Schema Definition
/// Language (XSD) 1.1 Part 2: Datatypes specification.
///
/// **Lexical Space:**
///
/// The lexical space allows decimal and scientific notation, as well as the
/// special values "INF", "+INF", "-INF", and "NaN".  The lexical
/// representation is a subset of the following:
///
/// *   Optional sign (`+` or `-`).
/// *   A sequence of digits, optionally containing a decimal point.
/// *   An optional exponent part, consisting of `e` or `E`, an optional
///     sign, and a sequence of digits.
/// *   The special literals "INF", "+INF", "-INF", "NaN" (case-insensitive).
///
/// **Value Space:**
///
/// The value space includes:
///
/// *   Finite numbers representable as *m* × 2<sup>*e*</sup>, where *m* is an
///     integer with an absolute value less than 2<sup>53</sup>, and *e* is an
///     integer between -1074 and 971, inclusive.
/// *   Positive and negative zero (`0` and `-0`).  These are distinct values,
///     but are considered equal by the `==` operator.
/// *   Positive infinity (`INF`).
/// *   Negative infinity (`-INF`).
/// *   Not a Number (`NaN`).  `NaN` is not equal to itself.
///
/// **Lexical-to-Value Mapping:**
///
/// The lexical forms are mapped to `double` values as follows:
/// *   Valid numerical representations are parsed to their corresponding
///     `double` value.
/// *    `"INF"` (or `"+INF"`) is mapped to positive infinity (`double.infinity`).
/// *   `"-INF"` is mapped to negative infinity (`double.negativeInfinity`).
/// *    `"NaN"` is mapped to `double.nan`.  Note that `double.nan != double.nan`.
/// *   `"-0"` is mapped to negative zero and `"0"` to positive zero.
///
/// **Canonical Representation:**
///
///   * `NaN`  is the canonical form for not-a-number.
///   * `INF`  is the canonical form for positive infinity.
///   * `-INF` is the canonical form for negative infinity.
///   * `"0.0E0"` is the canonical form for zero
///   * For other values, the canonical form is a normalized scientific
///     notation, removing trailing zeros after the decimal point, adding
///     `0` after the decimal point if no non-zero digit follows, and expressing
///     the value with an explicit exponent. The exponent is adjusted and the leading
///     digit is omitted if `0`.
///
/// See also:
/// *   [XSD 1.1 Datatypes: double](https://www.w3.org/TR/xmlschema11-2/#double)
class XSDDouble extends RDFDataType<double> {
  /// The IRI for the `xsd:double` datatype.
  static const String _iri = 'http://www.w3.org/2001/XMLSchema#double';

  /// Creates an `XSDDouble` instance.
  const XSDDouble() : super(XSDDouble._iri);

  /// Regular expression for validating `xsd:double` lexical forms.  This
  /// regex matches the lexical space defined in the XSD specification.
  static final RegExp _lexicalRegex = RegExp(
    r'^(?:NaN|-?INF|\+?INF|(?:[\+\-]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[Ee][\+\-]?[0-9]+)?))$',
  );

  @override
  double lexicalToValue(String lexicalForm) {
    final upperCaseLexical = lexicalForm.toUpperCase();
    if (upperCaseLexical == 'NAN') {
      return double.nan;
    } else if (upperCaseLexical == 'INF' || upperCaseLexical == '+INF') {
      return double.infinity;
    } else if (upperCaseLexical == '-INF') {
      return double.negativeInfinity;
    }

    if (!_lexicalRegex.hasMatch(lexicalForm)) {
      throw FormatException(
        'Invalid lexical form for xsd:double: $lexicalForm',
      );
    }

    // Use Dart's built-in double.parse for all other valid forms.
    try {
      return double.parse(lexicalForm);
    } on FormatException {
      // This should not happen if the regex is correct, but keep for safety
      throw FormatException(
        'Invalid lexical form for xsd:double: $lexicalForm',
      );
    }
  }

  @override
  String valueToLexical(double value) {
    if (value.isNaN) {
      return 'NaN';
    } else if (value.isInfinite) {
      return value.isNegative ? '-INF' : 'INF';
    } else if (value == 0.0) {
      return value.isNegative ? '-0.0E0' : '0.0E0';
    } else {
      var canonical = value.toStringAsExponential();
      canonical = canonical.replaceAll('e', 'E');

      if (!canonical.contains('.')) {
        final exponentIndex = canonical.indexOf('E');
        canonical =
            '${canonical.substring(0, exponentIndex)}.0${canonical.substring(exponentIndex)}';
      }

      if (canonical.contains('.')) {
        // Remove trailing zeros *before* the 'E'
        // canonical = canonical.replaceFirstMapped(RegExp('0+E'), (match) => 'E');
        // If we are left with just a decimal, add back a 0
        if (canonical.endsWith('.')) {
          canonical += '0';
        }
      }

      canonical = canonical.replaceAll(RegExp(r'E\+'), 'E');
      return canonical;
    }
  }

  @override
  bool isValidLexicalForm(String lexicalForm) {
    return _lexicalRegex.hasMatch(lexicalForm);
  }
}
