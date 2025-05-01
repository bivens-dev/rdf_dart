// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:xsd/src/codecs/unsignedByte/unsigned_byte_decoder.dart';
import 'package:xsd/src/codecs/unsignedByte/unsigned_byte_encoder.dart';

/// The canonical instance of [UnsignedByteCodec].
const unsignedByte = UnsignedByteCodec._();

/// A [Codec] for working with XML Schema `unsignedByte` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#unsignedByte
class UnsignedByteCodec extends Codec<String, int> {
  const UnsignedByteCodec._();

  @override
  Converter<int, String> get decoder => const UnsignedByteDecoder();

  @override
  Converter<String, int> get encoder => const UnsignedByteEncoder();
}
