// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:rdf_dart/src/data_types/helper.dart';

/// The canonical instance of [DoubleCodec].
const doubleCodec = DoubleCodec._();

/// A [Codec] for working with XML Schema `double` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#double
class DoubleCodec extends Codec<String, double> {
  final Converter<String, double> _encoder;
  final Converter<double, String> _decoder;

  /// Values taken from the specification
  static final constraints = (whitespace: Whitespace.collapse);

  /// A helper function to check if the provided [String] matches the
  /// lexical space as defined in the specification
  static bool matchesLexicalSpace(String input) {
    final doubleRep =
        r'((\+|-)?([0-9]+(\.[0-9]*)?|\.[0-9]+)([Ee](\+|-)?[0-9]+)?|-?INF|NAN|NaN)';
    final pattern = '^$doubleRep\$';
    final regex = RegExp(pattern, unicode: true);
    return regex.hasMatch(input);
  }

  const DoubleCodec._()
    : _decoder = const DoubleDecoder._(),
      _encoder = const DoubleEncoder._();

  @override
  Converter<double, String> get decoder => _decoder;

  @override
  Converter<String, double> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `double` data
class DoubleEncoder extends Converter<String, double> {
  const DoubleEncoder._();

  @override
  double convert(String input) => _convert(input);

  double _convert(String input) {
    input = processWhiteSpace(input, DoubleCodec.constraints.whitespace);

    if (!DoubleCodec.matchesLexicalSpace(input.toUpperCase())) {
      throw FormatException('invalid xsd:double format');
    }

    if (input.toUpperCase() == 'INF') {
      return double.infinity;
    }

    if (input.toUpperCase() == '-INF') {
      return double.negativeInfinity;
    }

    if (input.toUpperCase() == 'NAN') {
      return double.nan;
    }

    final parsedValue = double.parse(input);

    return parsedValue;
  }
}

/// A [Converter] for translating from [double] data type back into a
/// [String] that represents a valid XML Schema `double` data type.
class DoubleDecoder extends Converter<double, String> {
  const DoubleDecoder._();

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
