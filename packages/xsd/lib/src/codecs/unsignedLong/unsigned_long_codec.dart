// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:xsd/src/codecs/unsignedLong/unsigned_long_decoder.dart';
import 'package:xsd/src/codecs/unsignedLong/unsigned_long_encoder.dart';

/// The canonical instance of [UnsignedLongCodec].
const unsignedLong = UnsignedLongCodec._();

/// A [Codec] for working with XML Schema `unsignedLong` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#unsignedLong
class UnsignedLongCodec extends Codec<String, BigInt> {
  const UnsignedLongCodec._();

  @override
  Converter<BigInt, String> get decoder => const UnsignedLongDecoder();

  @override
  Converter<String, BigInt> get encoder => const UnsignedLongEncoder();
}
