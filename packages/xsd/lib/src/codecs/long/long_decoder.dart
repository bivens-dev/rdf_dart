import 'dart:convert';

import 'package:xsd/src/codecs/long/config.dart';

/// A [Converter] for translating from Dart's [BigInt] data type back into a
/// [String] that represents a valid XML Schema `long` data type.
class LongDecoder extends Converter<BigInt, String> {
  const LongDecoder();

  @override
  String convert(BigInt input) => _convert(input);

  String _convert(BigInt input) {
    if (input < longConstraints.minInclusive ||
        input > longConstraints.maxInclusive) {
      throw RangeError(
        'xsd:long values must be between ${longConstraints.minInclusive} and ${longConstraints.maxInclusive}',
      );
    }
    return input.toString();
  }
}