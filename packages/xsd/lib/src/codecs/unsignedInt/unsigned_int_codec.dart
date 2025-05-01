import 'dart:convert';

import 'package:xsd/src/codecs/unsignedInt/unsigned_int_decoder.dart';
import 'package:xsd/src/codecs/unsignedInt/unsigned_int_encoder.dart';

/// The canonical instance of [UnsignedIntCodec].
const unsignedInt = UnsignedIntCodec._();

/// A [Codec] for working with XML Schema `unsignedInt` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#unsignedInt
class UnsignedIntCodec extends Codec<String, int> {
  const UnsignedIntCodec._();

  @override
  Converter<int, String> get decoder => const UnsignedIntDecoder();

  @override
  Converter<String, int> get encoder => const UnsignedIntEncoder();
}
