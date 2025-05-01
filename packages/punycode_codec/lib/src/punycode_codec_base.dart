// SPDX-License-Identifier: MIT
//
// This code is based on a port of the Punycode.js library by Mathias Bynens.
// Original library: https://github.com/mathiasbynens/punycode.js/
// Original library license: MIT

// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:punycode_codec/src/decoder.dart';
import 'package:punycode_codec/src/encoder.dart';

/// A codec for encoding and decoding strings using the Punycode algorithm.
///
/// Punycode is a character encoding scheme used to represent Unicode
/// characters in ASCII strings. It is commonly used for Internationalized
/// Domain Names (IDNs).
///
/// This codec provides methods to convert between Unicode strings and their
/// Punycode representations.
///
/// Example:
/// ```dart
/// import 'package:punycode_codec/punycode_codec.dart';
///
/// void main() {
///   const codec = PunycodeCodec();
///   final encoded = codec.encoder.convert('münchen');
///   print(encoded); // Output: mnchen-3ya
///   final decoded = codec.decoder.convert('mnchen-3ya');
///   print(decoded); // Output: münchen
/// }
/// ```
class PunycodeCodec extends Codec<String, String> {
  const PunycodeCodec();

  @override
  Converter<String, String> get decoder => punycodeDecoder;

  @override
  Converter<String, String> get encoder => punycodeEncoder;
}
