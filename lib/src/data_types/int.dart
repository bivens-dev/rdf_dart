// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

/// The canonical instance of [IntCodec].
const intCodec = IntCodec._();

/// A [Codec] for working with XML Schema `int` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#int
class IntCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    minInclusive: -2147483648,
    maxInclusive: 2147483647,
    pattern: RegExp(r'[\-+]?[0-9]+'),
  );

  const IntCodec._()
    : _decoder = const IntDecoder._(),
      _encoder = const IntEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `int` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class IntEncoder extends Converter<String, int> {
  const IntEncoder._();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    if (!IntCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:int format');
    }
    final parsedValue = int.parse(input);
    if (parsedValue < IntCodec.constraints.minInclusive ||
        parsedValue > IntCodec.constraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        IntCodec.constraints.minInclusive,
        IntCodec.constraints.maxInclusive,
      );
    }
    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `int` data type.
class IntDecoder extends Converter<int, String> {
  const IntDecoder._();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < IntCodec.constraints.minInclusive ||
        input > IntCodec.constraints.maxInclusive) {
      throw RangeError.range(
        input,
        IntCodec.constraints.minInclusive,
        IntCodec.constraints.maxInclusive,
      );
    }
    return input.toString();
  }
}
