// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

/// The canonical instance of [UnsignedIntCodec].
const unsignedInt = UnsignedIntCodec._();

/// A [Codec] for working with XML Schema `unsignedInt` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#unsignedInt
class UnsignedIntCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    minInclusive: 0,
    maxInclusive: 4294967295,
    pattern: RegExp(r'[\-+]?[0-9]+'),
  );

  const UnsignedIntCodec._()
    : _decoder = const UnsignedIntDecoder._(),
      _encoder = const UnsignedIntEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `unsignedInt` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class UnsignedIntEncoder extends Converter<String, int> {
  const UnsignedIntEncoder._();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    if (!UnsignedIntCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:unsignedInt format');
    }
    final parsedValue = int.parse(input);
    if (parsedValue < UnsignedIntCodec.constraints.minInclusive ||
        parsedValue > UnsignedIntCodec.constraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        UnsignedIntCodec.constraints.minInclusive,
        UnsignedIntCodec.constraints.maxInclusive,
      );
    }
    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `unsignedInt` data type.
class UnsignedIntDecoder extends Converter<int, String> {
  const UnsignedIntDecoder._();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < UnsignedIntCodec.constraints.minInclusive ||
        input > UnsignedIntCodec.constraints.maxInclusive) {
      throw RangeError.range(
        input,
        UnsignedIntCodec.constraints.minInclusive,
        UnsignedIntCodec.constraints.maxInclusive,
      );
    }
    return input.toString();
  }
}
