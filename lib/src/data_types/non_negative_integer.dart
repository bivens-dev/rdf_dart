// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:rdf_dart/src/data_types/helper.dart';

/// The canonical instance of [NonNegativeIntegerCodec].
const nonNegativeInteger = NonNegativeIntegerCodec._();

/// A [Codec] for working with XML Schema `nonNegativeInteger` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#nonNegativeInteger
class NonNegativeIntegerCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    minInclusive: 0,
    pattern: RegExp(r'[\-+]?[0-9]+'),
    whitespace: Whitespace.collapse,
  );

  const NonNegativeIntegerCodec._()
    : _decoder = const NonNegativeIntegerDecoder._(),
      _encoder = const NonNegativeIntegerEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `nonNegativeInteger` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class NonNegativeIntegerEncoder extends Converter<String, int> {
  const NonNegativeIntegerEncoder._();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(
      input,
      NonNegativeIntegerCodec.constraints.whitespace,
    );

    if (!NonNegativeIntegerCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:nonNegativeInteger format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue < NonNegativeIntegerCodec.constraints.minInclusive) {
      throw RangeError.value(
        parsedValue,
        null,
        'must be greater than ${NonNegativeIntegerCodec.constraints.minInclusive}',
      );
    }

    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `nonNegativeInteger` data type.
class NonNegativeIntegerDecoder extends Converter<int, String> {
  const NonNegativeIntegerDecoder._();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input < NonNegativeIntegerCodec.constraints.minInclusive) {
      throw RangeError.value(
        input,
        null,
        'must be greater than ${NonNegativeIntegerCodec.constraints.minInclusive}',
      );
    }

    return input.toString();
  }
}
