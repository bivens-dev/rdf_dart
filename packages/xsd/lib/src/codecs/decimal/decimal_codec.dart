// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:xsd/src/codecs/decimal/decimal_decoder.dart';
import 'package:xsd/src/codecs/decimal/decimal_encoder.dart';

/// The canonical instance of [DecimalCodec].
const decimalCodec = DecimalCodec._();

/// A [Codec] for working with XML Schema `decimal` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#decimal
class DecimalCodec extends Codec<String, Decimal> {
  const DecimalCodec._();

  @override
  Converter<Decimal, String> get decoder => const DecimalDecoder();

  @override
  Converter<String, Decimal> get encoder => const DecimalEncoder();
}
