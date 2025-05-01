// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:xsd/src/codecs/short/short_decoder.dart';
import 'package:xsd/src/codecs/short/short_encoder.dart';

/// The canonical instance of [ShortCodec].
const shortCodec = ShortCodec._();

/// A [Codec] for working with XML Schema `short` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#short
class ShortCodec extends Codec<String, int> {
  const ShortCodec._();

  @override
  Converter<int, String> get decoder => const ShortDecoder();

  @override
  Converter<String, int> get encoder => const ShortEncoder();
}
