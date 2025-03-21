// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

/// The canonical instance of [BooleanCodec].
const booleanCodec = BooleanCodec._();

/// A [Codec] for working with XML Schema `boolean` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#boolean
class BooleanCodec extends Codec<String, bool> {
  final Converter<String, bool> _encoder;
  final Converter<bool, String> _decoder;

  /// Values taken from the specification
  static final constraints = (pattern: RegExp(r'^(true|false|1|0)$'));

  const BooleanCodec._()
    : _decoder = const BooleanDecoder._(),
      _encoder = const BooleanEncoder._();

  @override
  Converter<bool, String> get decoder => _decoder;

  @override
  Converter<String, bool> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `boolean` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class BooleanEncoder extends Converter<String, bool> {
  const BooleanEncoder._();

  @override
  bool convert(String input) => _convert(input);

  bool _convert(String input) {
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

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `boolean` data type.
class BooleanDecoder extends Converter<bool, String> {
  const BooleanDecoder._();

  @override
  String convert(bool input) => _convert(input);

  String _convert(bool input) {
    return input.toString();
  }
}
