// SPDX-License-Identifier: MIT
//
// This code is based on a port of the Punycode.js library by Mathias Bynens.
// Original library: https://github.com/mathiasbynens/punycode.js/
// Original library license: MIT
//
// The original library was written by Mathias Bynens and is covered under the
// MIT license. This Dart port is also covered under the MIT license.
// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:convert';

import 'package:rdf_dart/src/punycode/decoder.dart';
import 'package:rdf_dart/src/punycode/encoder.dart';

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
/// import 'package:rdf_dart/src/punycode/punycode_codec.dart';
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
  final Converter<String, String> _encoder;
  final Converter<String, String> _decoder;

  const PunycodeCodec()
    : _decoder = punycodeDecoder,
      _encoder = punycodeEncoder;

  @override
  Converter<String, String> get decoder => _decoder;

  @override
  Converter<String, String> get encoder => _encoder;
}
