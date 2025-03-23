// SPDX-License-Identifier: MIT
//
// This code is based on a port of the Punycode.js library by Mathias Bynens.
// Original library: https://github.com/mathiasbynens/punycode.js/
// Original library license: MIT
//
// The original library was written by Mathias Bynens and is covered under the
// MIT license. This Dart port is also covered under the MIT license.

import 'dart:convert';

import 'package:rdf_dart/src/punycode/shared.dart';

/// The canonical version of the Punycode Decoder
const punycodeDecoder = PunycodeDecoder._();

/// Converts a Punycode string of ASCII-only symbols to a string of
/// Unicode symbols.
class PunycodeDecoder extends Converter<String, String> {
  const PunycodeDecoder._();

  @override
  String convert(String input) {
    final output = <int>[];
    final inputLength = input.length;
    var i = 0;
    var n = bootstrapValues.initialN;
    var bias = bootstrapValues.initialBias;

    // Handle the basic code points: let `basic` be the number of input code
    // points before the last delimiter, or `0` if there is none, then copy
    // the first basic code points to the output.

    var basic = input.lastIndexOf(bootstrapValues.delimiter);
    if (basic < 0) {
      basic = 0;
    }

    for (var j = 0; j < basic; ++j) {
      // if it's not a basic code point
      if (input.codeUnitAt(j) >= 0x80) {
        throw RangeError('Illegal input >= 0x80 (not a basic code point)');
      }
      output.add(input.codeUnitAt(j));
    }

    // Main decoding loop: start just after the last delimiter if any basic code
    // points were copied; start at the beginning otherwise.

    for (
      var index = basic > 0 ? basic + 1 : 0;
      index < inputLength; /* no final expression */
    ) {
      // `index` is the index of the next character to be consumed.
      // Decode a generalized variable-length integer into `delta`,
      // which gets added to `i`. The overflow checking is easier
      // if we increase `i` as we go, then subtract off its starting
      // value at the end to obtain `delta`.
      final oldi = i;

      for (
        var w = 1, k = bootstrapValues.base;
        /* no condition */ ;
        k += bootstrapValues.base
      ) {
        if (index >= inputLength) {
          throw FormatException('Invalid input');
        }

        final digit = basicToDigit(input.codeUnitAt(index++));

        if (digit >= bootstrapValues.base) {
          throw FormatException('Invalid input');
        }

        if (digit > ((maxInt - i) / w).floor()) {
          throw FormatException(
            'Overflow: input needs wider integers to process',
          );
        }

        i += digit * w;
        final t =
            k <= bias
                ? bootstrapValues.tMin
                : (k >= bias + bootstrapValues.tMax
                    ? bootstrapValues.tMax
                    : k - bias);

        if (digit < t) {
          break;
        }

        final baseMinusT = bootstrapValues.base - t;

        if (w > (maxInt / baseMinusT).floor()) {
          throw FormatException(
            'Overflow: input needs wider integers to process',
          );
        }

        w *= baseMinusT;
      }

      final out = output.length + 1;
      bias = adapt(delta: i - oldi, numPoints: out, firstTime: oldi == 0);

      // `i` was supposed to wrap around from `out` to `0`,
      // incrementing `n` each time, so we'll fix that now:
      if ((i / out).floor() > maxInt - n) {
        throw FormatException(
          'Overflow: input needs wider integers to process',
        );
      }

      n += (i / out).floor();
      i %= out;

      // Insert `n` at position `i` of the output.
      output.insert(i, n);
      i++;
    }

    return String.fromCharCodes(output);
  }
}
