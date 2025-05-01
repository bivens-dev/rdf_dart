import 'dart:convert';

import 'package:xsd/src/codecs/unsignedShort/unsigned_short_decoder.dart';
import 'package:xsd/src/codecs/unsignedShort/unsigned_short_encoder.dart';

/// The canonical instance of [UnsignedShortCodec].
const unsignedShort = UnsignedShortCodec._();

/// A [Codec] for working with XML Schema `unsignedShort` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#unsignedShort
class UnsignedShortCodec extends Codec<String, int> {
  const UnsignedShortCodec._();

  @override
  Converter<int, String> get decoder => const UnsignedShortDecoder();

  @override
  Converter<String, int> get encoder => const UnsignedShortEncoder();
}
