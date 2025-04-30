import 'dart:convert';

import 'package:xsd/src/codecs/byte/byte_decoder.dart';
import 'package:xsd/src/codecs/byte/byte_encoder.dart';

/// The canonical instance of [ByteCodec].
const byte = ByteCodec._();

/// A [Codec] for working with XML Schema `byte` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#byte
class ByteCodec extends Codec<String, int> {
  const ByteCodec._();

  @override
  Converter<int, String> get decoder => const ByteDecoder();

  @override
  Converter<String, int> get encoder => const ByteEncoder();
}
