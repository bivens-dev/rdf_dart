// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:xsd/src/codecs/double/double_decoder.dart';
import 'package:xsd/src/codecs/double/double_encoder.dart';

/// The canonical instance of [DoubleCodec].
const doubleCodec = DoubleCodec._();

/// A [Codec] for working with XML Schema `double` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#double
class DoubleCodec extends Codec<String, double> {
  /// A helper function to check if the provided [String] matches the
  /// lexical space as defined in the specification
  static bool matchesLexicalSpace(String input) {
    final doubleRep =
        r'((\+|-)?([0-9]+(\.[0-9]*)?|\.[0-9]+)([Ee](\+|-)?[0-9]+)?|-?INF|NAN|NaN)';
    final pattern = '^$doubleRep\$';
    final regex = RegExp(pattern, unicode: true);
    return regex.hasMatch(input);
  }

  const DoubleCodec._();

  @override
  Converter<double, String> get decoder => const DoubleDecoder();

  @override
  Converter<String, double> get encoder => const DoubleEncoder();
}
