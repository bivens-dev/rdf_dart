// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

/// The canonical instance of [ShortCodec].
const shortCodec = ShortCodec._();

/// A [Codec] for working with XML Schema Short data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#short
class ShortCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    minInclusive: -32768,
    maxInclusive: 32767,
    pattern: RegExp(r'[\-+]?[0-9]+'),
  );

  const ShortCodec._()
    : _decoder = const ShortDecoder._(),
      _encoder = const ShortEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema Short data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class ShortEncoder extends Converter<String, int> {
  const ShortEncoder._();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    if (!ShortCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:short format');
    }
    final parsedValue = int.parse(input);
    if (parsedValue < ShortCodec.constraints.minInclusive ||
        parsedValue > ShortCodec.constraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        ShortCodec.constraints.minInclusive,
        ShortCodec.constraints.maxInclusive,
      );
    }
    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema Short data type.
class ShortDecoder extends Converter<int, String> {
  const ShortDecoder._();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < ShortCodec.constraints.minInclusive ||
        input > ShortCodec.constraints.maxInclusive) {
      throw RangeError.range(
        input,
        ShortCodec.constraints.minInclusive,
        ShortCodec.constraints.maxInclusive,
      );
    }
    return input.toString();
  }
}
