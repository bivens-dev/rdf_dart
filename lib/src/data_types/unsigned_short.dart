// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

/// The canonical instance of [UnsignedShortCodec].
const unsignedShort = UnsignedShortCodec._();

// Values taken from the specification
final _constraints = (
  minInclusive: 0,
  maxInclusive: 65535,
  pattern: RegExp(r'[\-+]?[0-9]+'),
);

/// A [Codec] for working with XML Schema Unsigned Short data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#unsignedShort
class UnsignedShortCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  const UnsignedShortCodec._()
    : _decoder = const UnsignedShortDecoder._(),
      _encoder = const UnsignedShortEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema Unsigned Short data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class UnsignedShortEncoder extends Converter<String, int> {
  const UnsignedShortEncoder._();

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
/// [String] that represents a valid XML Schema Unsigned Short data type.
class UnsignedShortDecoder extends Converter<int, String> {
  const UnsignedShortDecoder._();

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
