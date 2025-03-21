// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:rdf_dart/src/data_types/helper.dart';

/// The canonical instance of [BooleanCodec].
const booleanCodec = BooleanCodec._();

/// A [Codec] for working with XML Schema `boolean` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#boolean
class BooleanCodec extends Codec<String, bool> {
  final Converter<String, bool> _encoder;
  final Converter<bool, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    pattern: RegExp(r'^(true|false|1|0)$'),
    whitespace: Whitespace.collapse,
  );

  const BooleanCodec._()
    : _decoder = const BooleanDecoder._(),
      _encoder = const BooleanEncoder._();

  @override
  Converter<bool, String> get decoder => _decoder;

  @override
  Converter<String, bool> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `boolean` data
class BooleanEncoder extends Converter<String, bool> {
  const BooleanEncoder._();

  @override
  bool convert(String input) => _convert(input);

  bool _convert(String input) {
    input = processWhiteSpace(input, BooleanCodec.constraints.whitespace);

    if (!BooleanCodec.constraints.pattern.hasMatch(input)) {
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

/// A [Converter] for translating from Dart's [bool] data type back into a
/// [String] that represents a valid XML Schema `boolean` data type.
class BooleanDecoder extends Converter<bool, String> {
  const BooleanDecoder._();

  @override
  String convert(bool input) => _convert(input);

  String _convert(bool input) {
    return input.toString();
  }
}
