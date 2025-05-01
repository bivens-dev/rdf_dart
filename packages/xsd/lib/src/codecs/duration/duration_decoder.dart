import 'dart:convert';

import 'package:xsd/src/implementations/duration.dart';

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `byte` data type.
class DurationDecoder extends Converter<XSDDuration, String> {
  const DurationDecoder();

  @override
  String convert(XSDDuration input) => _convert(input);

  String _convert(XSDDuration input) {
    return input.toString();
  }
}