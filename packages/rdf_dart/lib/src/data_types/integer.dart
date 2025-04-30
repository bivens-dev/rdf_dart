// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:rdf_dart/src/data_types/helper.dart';

/// The canonical instance of [IntegerCodec].
const bigIntCodec = IntegerCodec._();

/// A [Codec] for working with XML Schema `integer` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#integer
class IntegerCodec extends Codec<String, BigInt> {
  final Converter<String, BigInt> _encoder;
  final Converter<BigInt, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    pattern: RegExp(r'[\-+]?[0-9]+'),
    whitespace: Whitespace.collapse,
  );

  const IntegerCodec._()
    : _decoder = const IntegerDecoder._(),
      _encoder = const IntegerEncoder._();

  @override
  Converter<BigInt, String> get decoder => _decoder;

  @override
  Converter<String, BigInt> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `integer` data
/// It uses Dart's built in [BigInt.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class IntegerEncoder extends Converter<String, BigInt> {
  const IntegerEncoder._();

  @override
  BigInt convert(String input) => _convert(input);

  BigInt _convert(String input) {
    input = processWhiteSpace(input, IntegerCodec.constraints.whitespace);
    if (!IntegerCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:integer format');
    }

    final parsedValue = BigInt.parse(input);

    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [BigInt] data type back into a
/// [String] that represents a valid XML Schema `integer` data type.
class IntegerDecoder extends Converter<BigInt, String> {
  const IntegerDecoder._();

  @override
  String convert(BigInt input) => _convert(input);

  String _convert(BigInt input) {
    return input.toString();
  }
}
