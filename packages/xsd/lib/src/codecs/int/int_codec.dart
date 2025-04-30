// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:xsd/src/codecs/int/int_decoder.dart';
import 'package:xsd/src/codecs/int/int_encoder.dart';

/// The canonical instance of [IntCodec].
const intCodec = IntCodec._();

/// A [Codec] for working with XML Schema `int` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#int
class IntCodec extends Codec<String, int> {
  const IntCodec._();

  @override
  Converter<int, String> get decoder => const IntDecoder();

  @override
  Converter<String, int> get encoder => const IntEncoder();
}
