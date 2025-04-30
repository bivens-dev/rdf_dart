import 'dart:convert';

/// A [Converter] for translating from [double] data type back into a
/// [String] that represents a valid XML Schema `double` data type.
class DoubleDecoder extends Converter<double, String> {
  const DoubleDecoder();

  @override
  String convert(double input) => _doubleCanonicalMap(input);

  /// Return the canonical representation as per an adaptation to the
  /// algorithm defined in https://www.w3.org/TR/xmlschema11-2/#f-doubleCanmap
  String _doubleCanonicalMap(double input) {
    // Return `specialRepCanonicalMap` when `input` is one of
    // `positiveInfinity`, `negativeInfinity`, or `notANumber`
    if (input == double.infinity ||
        input == double.negativeInfinity ||
        input.isNaN) {
      return _specialRepCanonicalMap(input);
    }

    // return '0.0E0' when `input` is positiveZero
    if (input == 0 && !input.isNegative) {
      return '0.0E0';
    }

    // return '-0.0E0' when `input` is negativeZero;
    if (input == 0 && input.isNegative) {
      return '-0.0E0';
    }

    // otherwise `input` is numeric and non-zero:

    var canonical = input.toStringAsExponential();
    canonical = canonical.replaceAll('e', 'E');

    if (!canonical.contains('.')) {
      final exponentIndex = canonical.indexOf('E');
      canonical =
          '${canonical.substring(0, exponentIndex)}.0${canonical.substring(exponentIndex)}';
    }

    if (canonical.contains('.')) {
      // If we are left with just a decimal, add back a 0
      if (canonical.endsWith('.')) {
        canonical += '0';
      }
    }

    canonical = canonical.replaceAll(RegExp(r'E\+'), 'E');
    return canonical;
  }

  /// Maps the special values used with some numerical datatypes
  /// to their canonical representations. Using the algorithm found in the
  /// spec at https://www.w3.org/TR/xmlschema11-2/#f-specValCanMap
  String _specialRepCanonicalMap(double input) {
    if (input == double.infinity) {
      return 'INF';
    }

    if (input == double.negativeInfinity) {
      return '-INF';
    }

    if (input.isNaN) {
      return 'NaN';
    }

    throw ArgumentError(
      'Input must be double.infinity, double.negativeInfinity or isNaN',
    );
  }
}