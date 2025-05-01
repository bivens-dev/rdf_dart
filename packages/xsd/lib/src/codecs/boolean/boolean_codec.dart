import 'dart:convert';

import 'package:xsd/src/codecs/boolean/boolean_decoder.dart';
import 'package:xsd/src/codecs/boolean/boolean_encoder.dart';

/// The canonical instance of [BooleanCodec].
const booleanCodec = BooleanCodec._();

/// A [Codec] for working with XML Schema `boolean` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#boolean
class BooleanCodec extends Codec<String, bool> {
  const BooleanCodec._();

  @override
  Converter<bool, String> get decoder => const BooleanDecoder();

  @override
  Converter<String, bool> get encoder => const BooleanEncoder();
}
