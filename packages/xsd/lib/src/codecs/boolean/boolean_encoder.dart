import 'dart:convert';

import 'package:xsd/src/codecs/boolean/config.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// A [Converter] for working with XML Schema `boolean` data
class BooleanEncoder extends Converter<String, bool> {
  const BooleanEncoder();

  @override
  bool convert(String input) => _convert(input);

  bool _convert(String input) {
    input = processWhiteSpace(input, booleanConstraints.whitespace);

    if (!booleanConstraints.pattern.hasMatch(input)) {
      throw FormatException('invalid format xsd:bool format');
    }

    switch (input) {
      case 'true':
      case '1':
        return true;
      case 'false':
      case '0':
        return false;
      default: // Should never happen due to regex, but for completeness
        throw FormatException('Invalid format for xsd:boolean: $input');
    }
  }
}