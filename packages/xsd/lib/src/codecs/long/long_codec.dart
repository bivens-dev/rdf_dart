// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:xsd/src/codecs/long/long_decoder.dart';
import 'package:xsd/src/codecs/long/long_encoder.dart';

/// The canonical instance of [LongCodec].
const longCodec = LongCodec._();

/// A [Codec] for working with XML Schema `long` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#long
class LongCodec extends Codec<String, BigInt> {
  const LongCodec._();

  @override
  Converter<BigInt, String> get decoder => const LongDecoder();

  @override
  Converter<String, BigInt> get encoder => const LongEncoder();
}
