// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:rdf_dart/src/data_types/helper.dart';

/// The canonical instance of [DecimalCodec].
const decimalCodec = DecimalCodec._();

/// A [Codec] for working with XML Schema `decimal` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#decimal
class DecimalCodec extends Codec<String, Decimal> {
  final Converter<String, Decimal> _encoder;
  final Converter<Decimal, String> _decoder;

  /// Values taken from the specification
  static final constraints = (
    pattern: RegExp(r'(\+|-)?([0-9]+(\.[0-9]*)?|\.[0-9]+)'),
    whitespace: Whitespace.collapse,
  );

  const DecimalCodec._()
    : _decoder = const DecimalDecoder._(),
      _encoder = const DecimalEncoder._();

  @override
  Converter<Decimal, String> get decoder => _decoder;

  @override
  Converter<String, Decimal> get encoder => _encoder;
}

/// A [Converter] for working with XML Schema `decimal` data
class DecimalEncoder extends Converter<String, Decimal> {
  const DecimalEncoder._();

  @override
  Decimal convert(String input) => _convert(input);

  Decimal _convert(String input) {
    input = processWhiteSpace(input, DecimalCodec.constraints.whitespace);

    if (!DecimalCodec.constraints.pattern.hasMatch(input)) {
      throw FormatException('invalid xsd:decimal format');
    }

    final parsedValue = Decimal.parse(input);

    return parsedValue;
  }
}

/// A [Converter] for translating from [Decimal] data type back into a
/// [String] that represents a valid XML Schema `decimal` data type.
class DecimalDecoder extends Converter<Decimal, String> {
  const DecimalDecoder._();

  @override
  String convert(Decimal input) => _convert(input);

  String _convert(Decimal input) {
    return input.toString();
  }
}
