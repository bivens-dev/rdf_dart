// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

/// The canonical instance of [UnsignedByteCodec].
const unsignedByte = UnsignedByteCodec._();

// Values taken from the specification
final _constraints = (
  minInclusive: 0,
  maxInclusive: 255,
  pattern: RegExp(r'[\-+]?[0-9]+'),
);

/// A [Codec] for working with XML Schema Unsigned Byte data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#unsignedByte
class UnsignedByteCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  const UnsignedByteCodec._()
    : _decoder = const UnsignedByteDecoder._(),
      _encoder = const UnsignedByteEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema Unsigned Byte data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class UnsignedByteEncoder extends Converter<String, int> {
  const UnsignedByteEncoder._();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    if (!_constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid format');
    }
    final parsedValue = int.parse(input);
    if (parsedValue < _constraints.minInclusive ||
        parsedValue > _constraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        _constraints.minInclusive,
        _constraints.maxInclusive,
      );
    }
    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema Unsigned byte data type.
class UnsignedByteDecoder extends Converter<int, String> {
  const UnsignedByteDecoder._();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < _constraints.minInclusive ||
        input > _constraints.maxInclusive) {
      throw RangeError.range(
        input,
        _constraints.minInclusive,
        _constraints.maxInclusive,
      );
    }
    return input.toString();
  }
}
