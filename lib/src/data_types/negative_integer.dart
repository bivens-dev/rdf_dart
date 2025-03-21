// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

/// The canonical instance of [NegativeIntegerCodec].
const negativeInteger = NegativeIntegerCodec._();

/// A [Codec] for working with XML Schema `negativeInteger` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#negativeInteger
class NegativeIntegerCodec extends Codec<String, int> {
  final Converter<String, int> _encoder;
  final Converter<int, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    maxInclusive: -1,
    pattern: RegExp(r'[\-+]?[0-9]+'),
  );

  const NegativeIntegerCodec._()
    : _decoder = const NegativeIntegerDecoder._(),
      _encoder = const NegativeIntegerEncoder._();

  @override
  Converter<int, String> get decoder => _decoder;

  @override
  Converter<String, int> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `negativeInteger` data
/// It uses Dart's built in [int.parse] and applies additional checks
/// to ensure that the value is within the specified range requirements.
class NegativeIntegerEncoder extends Converter<String, int> {
  const NegativeIntegerEncoder._();

  @override
  int convert(String input) => _convert(input);

  int _convert(String input) {
    if (!NegativeIntegerCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:negativeInteger format');
    }
    final parsedValue = int.parse(input);
    if (parsedValue > NegativeIntegerCodec.constraints.maxInclusive) {
      throw RangeError.value(parsedValue, null, 'must be a negative number');
    }
    return parsedValue;
  }
}

/// A [Converter] for translating from Dart's [int] data type back into a
/// [String] that represents a valid XML Schema `negativeInteger` data type.
class NegativeIntegerDecoder extends Converter<int, String> {
  const NegativeIntegerDecoder._();

  @override
  String convert(int input) => _convert(input);

  String _convert(int input) {
    if (input > NegativeIntegerCodec.constraints.maxInclusive) {
      throw RangeError.value(input, null, 'must be a negative number');
    }
    return input.toString();
  }
}
