// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:rdf_dart/src/data_types/helper.dart';

/// The canonical instance of [NonPositiveIntegerCodec].
const nonPositiveInteger = NonPositiveIntegerCodec._();

/// A [Codec] for working with XML Schema `nonPositiveInteger` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#nonPositiveInteger
class NonPositiveIntegerCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    maxInclusive: 0,
    pattern: RegExp(r'[\-+]?[0-9]+'),
    whitespace: Whitespace.collapse,
  );

  const NonPositiveIntegerCodec._()
    : _decoder = const NonPositiveIntegerDecoder._(),
      _encoder = const NonPositiveIntegerEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `nonPositiveInteger` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class NonPositiveIntegerEncoder extends Converter<String, int> {
  const NonPositiveIntegerEncoder._();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    input = processWhiteSpace(
      input,
      NonPositiveIntegerCodec.constraints.whitespace,
    );

    if (!NonPositiveIntegerCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:nonPositiveInteger format');
    }

    final parsedValue = int.parse(input);

    if (parsedValue > NonPositiveIntegerCodec.constraints.maxInclusive) {
      throw RangeError.value(
        parsedValue,
        null,
        'must be less than ${NonPositiveIntegerCodec.constraints.maxInclusive}',
      );
    }

    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `nonPositiveInteger` data type.
class NonPositiveIntegerDecoder extends Converter<int, String> {
  const NonPositiveIntegerDecoder._();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input > NonPositiveIntegerCodec.constraints.maxInclusive) {
      throw RangeError.value(
        input,
        null,
        'must be less than ${NonPositiveIntegerCodec.constraints.maxInclusive}',
      );
    }

    return input.toString();
  }
}
