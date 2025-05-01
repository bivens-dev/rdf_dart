// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:xsd/src/codecs/integer/integer_decoder.dart';
import 'package:xsd/src/codecs/integer/integer_encoder.dart';

/// The canonical instance of [IntegerCodec].
const bigIntCodec = IntegerCodec._();

/// A [Codec] for working with XML Schema `integer` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#integer
class IntegerCodec extends Codec<String, BigInt> {
  const IntegerCodec._();

  @override
  Converter<BigInt, String> get decoder => const IntegerDecoder();

  @override
  Converter<String, BigInt> get encoder => const IntegerEncoder();
}
