import 'dart:convert';

/// A [Converter] for translating from Dart's [BigInt] data type back into a
/// [String] that represents a valid XML Schema `integer` data type.
class IntegerDecoder extends Converter<BigInt, String> {
  const IntegerDecoder();

  @override
  String convert(BigInt input) => _convert(input);

  String _convert(BigInt input) {
    return input.toString();
  }
}