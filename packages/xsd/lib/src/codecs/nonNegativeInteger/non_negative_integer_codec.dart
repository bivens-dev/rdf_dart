import 'dart:convert';

import 'package:xsd/src/codecs/nonNegativeInteger/non_negative_integer_decoder.dart';
import 'package:xsd/src/codecs/nonNegativeInteger/non_negative_integer_encoder.dart';

/// The canonical instance of [NonNegativeIntegerCodec].
const nonNegativeInteger = NonNegativeIntegerCodec._();

/// A [Codec] for working with XML Schema `nonNegativeInteger` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#nonNegativeInteger
class NonNegativeIntegerCodec extends Codec<String, int> {
  const NonNegativeIntegerCodec._();

  @override
  Converter<int, String> get decoder => const NonNegativeIntegerDecoder();

  @override
  Converter<String, int> get encoder => const NonNegativeIntegerEncoder();
}
