import 'dart:convert';

import 'package:xsd/src/codecs/double/config.dart';
import 'package:xsd/src/codecs/double/double_codec.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `double` data
class DoubleEncoder extends Converter<String, double> {
  const DoubleEncoder();

  @override
  double convert(String input) => _convert(input);

  double _convert(String input) {
    input = processWhiteSpace(input, doubleConstraints.whitespace);

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