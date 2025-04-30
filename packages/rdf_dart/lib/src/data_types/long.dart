// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:rdf_dart/src/data_types/helper.dart';

/// The canonical instance of [LongCodec].
const longCodec = LongCodec._();

/// A [Codec] for working with XML Schema `long` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#long
class LongCodec extends Codec<String, BigInt> {
  final Converter<String, BigInt> _encoder;
  final Converter<BigInt, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    minInclusive: BigInt.parse('-9223372036854775808'),
    maxInclusive: BigInt.parse('9223372036854775807'),
    pattern: RegExp(r'[\-+]?[0-9]+'),
    whitespace: Whitespace.collapse,
  );

  const LongCodec._()
    : _decoder = const UnsignedLongDecoder._(),
      _encoder = const UnsignedLongEncoder._();

  @override
  Converter<BigInt, String> get decoder => _decoder;

  @override
  Converter<String, BigInt> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `long` data
/// It uses Dart's built in [BigInt.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class UnsignedLongEncoder extends Converter<String, BigInt> {
  const UnsignedLongEncoder._();

  @override
  BigInt convert(String input) => _convert(input);

  BigInt _convert(String input) {
    input = processWhiteSpace(input, LongCodec.constraints.whitespace);

    if (!LongCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:long format');
    }

    final parsedValue = BigInt.parse(input);

    if (parsedValue < LongCodec.constraints.minInclusive ||
        parsedValue > LongCodec.constraints.maxInclusive) {
      throw RangeError(
        'xsd:long values must be between ${LongCodec.constraints.minInclusive} and ${LongCodec.constraints.maxInclusive}',
      );
    }

    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [BigInt] data type back into a
/// [String] that represents a valid XML Schema `long` data type.
class UnsignedLongDecoder extends Converter<BigInt, String> {
  const UnsignedLongDecoder._();

  @override
  String convert(BigInt input) => _convert(input);

  String _convert(BigInt input) {
    if (input < LongCodec.constraints.minInclusive ||
        input > LongCodec.constraints.maxInclusive) {
      throw RangeError(
        'xsd:long values must be between ${LongCodec.constraints.minInclusive} and ${LongCodec.constraints.maxInclusive}',
      );
    }
    return input.toString();
  }
}
