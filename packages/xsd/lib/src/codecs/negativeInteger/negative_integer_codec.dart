// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:xsd/src/codecs/negativeInteger/negative_integer_decoder.dart';
import 'package:xsd/src/codecs/negativeInteger/negative_integer_encoder.dart';

/// The canonical instance of [NegativeIntegerCodec].
const negativeInteger = NegativeIntegerCodec._();

/// A [Codec] for working with XML Schema `negativeInteger` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#negativeInteger
class NegativeIntegerCodec extends Codec<String, int> {
  const NegativeIntegerCodec._();

  @override
  Converter<int, String> get decoder => const NegativeIntegerDecoder();

  @override
  Converter<String, int> get encoder => const NegativeIntegerEncoder();
}
