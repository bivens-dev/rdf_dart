import 'dart:convert';

import 'package:xsd/src/codecs/nonPositiveInteger/non_positive_integer_decoder.dart';
import 'package:xsd/src/codecs/nonPositiveInteger/non_positive_integer_encoder.dart';

/// The canonical instance of [NonPositiveIntegerCodec].
const nonPositiveInteger = NonPositiveIntegerCodec._();

/// A [Codec] for working with XML Schema `nonPositiveInteger` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#nonPositiveInteger
class NonPositiveIntegerCodec extends Codec<String, int> {
  const NonPositiveIntegerCodec._();

  @override
  Converter<int, String> get decoder => const NonPositiveIntegerDecoder();

  @override
  Converter<String, int> get encoder => const NonPositiveIntegerEncoder();
}
