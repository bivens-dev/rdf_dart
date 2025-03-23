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

/// The canonical version of the Punycode Encoder
const punycodeEncoder = PunycodeEncoder._();

/// Converts a string of Unicode symbols (e.g. a domain name label) to a
/// Punycode string of ASCII-only symbols.
class PunycodeEncoder extends Converter<String, String> {
  const PunycodeEncoder._();

  @override
  String convert(String input) {
    final output = <String>[] = [];

    // Convert the input in UCS-2 to an array of Unicode code points.
    final decodedInput = ucs2decode(input);

    // Cache the length.
    final inputLength = input.length;

    // Initialize the state.
    var n = bootstrapValues.initialN;
    var delta = 0;
    var bias = bootstrapValues.initialBias;

    // Handle the basic code points.
    for (final currentValue in decodedInput) {
      if (currentValue < 0x80) {
        output.add(String.fromCharCode(currentValue));
      }
    }

    final basicLength = output.length;
    var handledCPCount = basicLength;

    // `handledCPCount` is the number of code points that have been handled;
    // `basicLength` is the number of basic code points.

    // Finish the basic string with a delimiter unless it's empty.
    if (basicLength > 0) {
      output.add(bootstrapValues.delimiter);
    }

    // Main encoding loop:
    while (handledCPCount < inputLength) {
      // All non-basic code points < n have been handled already. Find the next
      // larger one:
      var m = maxInt;

      for (final currentValue in decodedInput) {
        if (currentValue >= n && currentValue < m) {
          m = currentValue;
        }
      }

      // Increase `delta` enough to advance the decoder's <n,i> state to <m,0>,
      // but guard against overflow.
      final handledCPCountPlusOne = handledCPCount + 1;

      if (m - n > ((maxInt - delta) / handledCPCountPlusOne).floor()) {
        throw FormatException(
          'Overflow: input needs wider integers to process',
        );
      }

      delta += (m - n) * handledCPCountPlusOne;
      n = m;

      for (final currentValue in decodedInput) {
        if (currentValue < n && ++delta > maxInt) {
          throw FormatException(
            'Overflow: input needs wider integers to process',
          );
        }

        if (currentValue == n) {
          // Represent delta as a generalized variable-length integer.
          var q = delta;

          for (
            var k = bootstrapValues.base;
            /* no condition */ ;
            k += bootstrapValues.base
          ) {
            final t =
                k <= bias
                    ? bootstrapValues.tMin
                    : (k >= bias + bootstrapValues.tMax
                        ? bootstrapValues.tMax
                        : k - bias);

            if (q < t) {
              break;
            }

            final qMinusT = q - t;
            final baseMinusT = bootstrapValues.base - t;
            output.add(
              String.fromCharCode(digitToBasic(t + qMinusT % baseMinusT, 0)),
            );
            q = (qMinusT / baseMinusT).floor();
          }

          output.add(String.fromCharCode(digitToBasic(q, 0)));
          bias = adapt(
            delta: delta,
            numPoints: handledCPCountPlusOne,
            firstTime: handledCPCount == basicLength,
          );
          delta = 0;
          ++handledCPCount;
        }
      }
      ++delta;
      ++n;
    }

    return output.join();
  }
}
