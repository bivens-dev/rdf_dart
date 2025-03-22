// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:rdf_dart/src/data_types/helper.dart';

/// The canonical instance of [UnsignedLongCodec].
const unsignedLong = UnsignedLongCodec._();

/// A [Codec] for working with XML Schema `unsignedLong` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#unsignedLong
class UnsignedLongCodec extends Codec<String, BigInt> {
  final Converter<String, BigInt> _encoder;
  final Converter<BigInt, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    minInclusive: BigInt.from(0),
    maxInclusive: BigInt.parse('18446744073709551615'),
    pattern: RegExp(r'[\-+]?[0-9]+'),
    whitespace: Whitespace.collapse,
  );

  const UnsignedLongCodec._()
    : _decoder = const UnsignedLongDecoder._(),
      _encoder = const UnsignedLongEncoder._();

  @override
  Converter<BigInt, String> get decoder => _decoder;

  @override
  Converter<String, BigInt> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `unsignedLong` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class UnsignedLongEncoder extends Converter<String, BigInt> {
  const UnsignedLongEncoder._();

  @override
  BigInt convert(String input) => _convert(input);

  BigInt _convert(String input) {
    input = processWhiteSpace(input, UnsignedLongCodec.constraints.whitespace);

    if (!UnsignedLongCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:unsignedLong format');
    }

    final parsedValue = BigInt.parse(input);

    if (parsedValue < UnsignedLongCodec.constraints.minInclusive ||
        parsedValue > UnsignedLongCodec.constraints.maxInclusive) {
      throw RangeError(
        'xsd:unsignedLong values must be between ${UnsignedLongCodec.constraints.minInclusive} and ${UnsignedLongCodec.constraints.maxInclusive}',
      );
    }

    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `unsignedLong` data type.
class UnsignedLongDecoder extends Converter<BigInt, String> {
  const UnsignedLongDecoder._();

  @override
  String convert(BigInt input) => _convert(input);

  String _convert(BigInt input) {
    if (input < UnsignedLongCodec.constraints.minInclusive ||
        input > UnsignedLongCodec.constraints.maxInclusive) {
      throw RangeError(
        'xsd:unsignedLong values must be between ${UnsignedLongCodec.constraints.minInclusive} and ${UnsignedLongCodec.constraints.maxInclusive}',
      );
    }
    return input.toString();
  }
}
