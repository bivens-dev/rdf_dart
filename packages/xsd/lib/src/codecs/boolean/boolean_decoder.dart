import 'dart:convert';

/// A [Converter] for translating from Dart's [bool] data type back into a
/// [String] that represents a valid XML Schema `boolean` data type.
class BooleanDecoder extends Converter<bool, String> {
  const BooleanDecoder();

  @override
  String convert(bool input) => _convert(input);

  String _convert(bool input) {
    return input.toString();
  }
}