// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:rdf_dart/src/data_types/helper.dart';

/// The canonical instance of [PositiveIntegerCodec].
const positiveInteger = PositiveIntegerCodec._();

/// A [Codec] for working with XML Schema `positiveInteger` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#positiveInteger
class PositiveIntegerCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    minInclusive: 1,
    pattern: RegExp(r'[\-+]?[0-9]+'),
    whitespace: Whitespace.collapse,
  );

  const PositiveIntegerCodec._()
    : _decoder = const PositiveIntegerDecoder._(),
      _encoder = const PositiveIntegerEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `positiveInteger` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class PositiveIntegerEncoder extends Converter<String, int> {
  const PositiveIntegerEncoder._();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(
      input,
      PositiveIntegerCodec.constraints.whitespace,
    );

    if (!PositiveIntegerCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:positiveInteger format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue < PositiveIntegerCodec.constraints.minInclusive) {
      throw RangeError.value(parsedValue, null, 'must be a positive number');
    }

    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `positiveInteger` data type.
class PositiveIntegerDecoder extends Converter<int, String> {
  const PositiveIntegerDecoder._();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < PositiveIntegerCodec.constraints.minInclusive) {
      throw RangeError.value(input, null, 'must be a positive number');
    }

    return input.toString();
  }
}
