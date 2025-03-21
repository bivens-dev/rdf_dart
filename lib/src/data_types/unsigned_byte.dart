// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

/// The canonical instance of [UnsignedByteCodec].
const unsignedByte = UnsignedByteCodec._();

/// A [Codec] for working with XML Schema `unsignedByte` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#unsignedByte
class UnsignedByteCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    minInclusive: 0,
    maxInclusive: 255,
    pattern: RegExp(r'[\-+]?[0-9]+'),
  );

  const UnsignedByteCodec._()
    : _decoder = const UnsignedByteDecoder._(),
      _encoder = const UnsignedByteEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `unsignedByte` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class UnsignedByteEncoder extends Converter<String, int> {
  const UnsignedByteEncoder._();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    if (!UnsignedByteCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:unsignedByte format');
    }
    final parsedValue = int.parse(input);
    if (parsedValue < UnsignedByteCodec.constraints.minInclusive ||
        parsedValue > UnsignedByteCodec.constraints.maxInclusive) {
      throw RangeError.range(
        parsedValue,
        UnsignedByteCodec.constraints.minInclusive,
        UnsignedByteCodec.constraints.maxInclusive,
      );
    }
    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `unsignedByte` data type.
class UnsignedByteDecoder extends Converter<int, String> {
  const UnsignedByteDecoder._();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < UnsignedByteCodec.constraints.minInclusive ||
        input > UnsignedByteCodec.constraints.maxInclusive) {
      throw RangeError.range(
        input,
        UnsignedByteCodec.constraints.minInclusive,
        UnsignedByteCodec.constraints.maxInclusive,
      );
    }
    return input.toString();
  }
}
