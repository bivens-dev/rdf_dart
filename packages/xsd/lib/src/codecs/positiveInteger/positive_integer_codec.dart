import 'dart:convert';

import 'package:xsd/src/codecs/positiveInteger/positive_integer_decoder.dart';
import 'package:xsd/src/codecs/positiveInteger/positive_integer_encoder.dart';

/// The canonical instance of [PositiveIntegerCodec].
const positiveInteger = PositiveIntegerCodec._();

/// A [Codec] for working with XML Schema `positiveInteger` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#positiveInteger
class PositiveIntegerCodec extends Codec<String, int> {
  const PositiveIntegerCodec._();

  @override
  Converter<int, String> get decoder => const PositiveIntegerDecoder();

  @override
  Converter<String, int> get encoder => const PositiveIntegerEncoder();
}
