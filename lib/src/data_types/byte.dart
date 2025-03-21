// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

/// The canonical instance of [ByteCodec].
const byte = ByteCodec._();

/// A [Codec] for working with XML Schema Byte data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#byte
class ByteCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    minInclusive: -128,
    maxInclusive: 127,
    pattern: RegExp(r'[\-+]?[0-9]+'),
  );

  const ByteCodec._()
    : _decoder = const ByteDecoder._(),
      _encoder = const ByteEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema Byte data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class ByteEncoder extends Converter<String, int> {
  const ByteEncoder._();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    if (!ByteCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid format');
    }
    final parsedValue = int.parse(input);
    if (parsedValue < ByteCodec.constraints.minInclusive ||
        parsedValue > ByteCodec.constraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        ByteCodec.constraints.minInclusive,
        ByteCodec.constraints.maxInclusive,
      );
    }
    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema Byte data type.
class ByteDecoder extends Converter<int, String> {
  const ByteDecoder._();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < ByteCodec.constraints.minInclusive ||
        input > ByteCodec.constraints.maxInclusive) {
      throw RangeError.range(
        input,
        ByteCodec.constraints.minInclusive,
        ByteCodec.constraints.maxInclusive,
      );
    }
    return input.toString();
  }
}
