// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:xsd/src/codecs/duration/duration_decoder.dart';
import 'package:xsd/src/codecs/duration/duration_encoder.dart';
import 'package:xsd/src/implementations/duration.dart';

/// The canonical instance of [DurationCodec].
const durationCodec = DurationCodec._();

/// A [Codec] for working with XML Schema `duration` data
/// as defined by https://www.w3.org/TR/xmlschema11-2/#byte
class DurationCodec extends Codec<String, XSDDuration> {
  /// A helper function to check if the provided [String] matches the
  /// lexical space as defined in the specification
  static bool matchesLexicalSpace(String input) {
    final durationRep =
        r'-?P((([0-9]+Y([0-9]+M)?([0-9]+D)?|([0-9]+M)([0-9]+D)?|([0-9]+D))(T(([0-9]+H)([0-9]+M)?([0-9]+(\.[0-9]+)?S)?|([0-9]+M)([0-9]+(\.[0-9]+)?S)?|([0-9]+(\.[0-9]+)?S)))?)|(T(([0-9]+H)([0-9]+M)?([0-9]+(\.[0-9]+)?S)?|([0-9]+M)([0-9]+(\.[0-9]+)?S)?|([0-9]+(\.[0-9]+)?S))))';
    final pattern = '^$durationRep\$';
    final regex = RegExp(pattern, unicode: true);
    return regex.hasMatch(input);
  }

  const DurationCodec._();
  @override
  Converter<XSDDuration, String> get decoder => const DurationDecoder();

  @override
  Converter<String, XSDDuration> get encoder => const DurationEncoder();
}
