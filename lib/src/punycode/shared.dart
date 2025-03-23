// SPDX-License-Identifier: MIT
//
// This code is based on a port of the Punycode.js library by Mathias Bynens.
// Original library: https://github.com/mathiasbynens/punycode.js/
// Original library license: MIT
//
// The original library was written by Mathias Bynens and is covered under the
// MIT license. This Dart port is also covered under the MIT license.

/// Bootstring parameters & constants from the Punycode
/// specification (RFC 3492)
const bootstrapValues = (
  base: 36,
  tMin: 1,
  tMax: 26,
  skew: 38,
  damp: 700,
  initialBias: 72,
  initialN: 128, // 0x80
  delimiter: '-', // '\x2D'
);

///  Highest positive signed 32-bit float value
const maxInt = 2147483647; // aka. 0x7FFFFFFF or 2^31-1

/// Bias adaptation function as per section 3.4 of RFC 3492.
/// https://www.ietf.org/html/rfc3492#section-3.4
///
/// Args:
///   delta: The delta value.
///   numPoints: The total number of code points encoded/decoded so far.
///   firstTime: True if this is the very first delta, false otherwise.
///
/// Returns:
///   The adapted bias.
int adapt({
  required int delta,
  required int numPoints,
  required bool firstTime,
}) {
  var k = 0;

  // 1. Delta scaling (avoid overflow)
  delta =
      firstTime
          ? (delta ~/ bootstrapValues.damp)
          : (delta ~/ 2); // Integer division

  // 2. Delta increase (compensate for longer string)
  delta += delta ~/ numPoints; // Integer division

  // 3. Delta division (predict minimum digits)
  while (delta >
      (((bootstrapValues.base - bootstrapValues.tMin) * bootstrapValues.tMax) ~/
          2)) {
    delta =
        delta ~/
        (bootstrapValues.base - bootstrapValues.tMin); // Integer division
    k += bootstrapValues.base;
  }

  // 4. Bias calculation
  return k +
      ((((bootstrapValues.base - bootstrapValues.tMin) + 1) * delta) ~/
          (delta + bootstrapValues.skew));
}

/// Decodes a string into a list of Unicode code points.
///
/// This function handles surrogate pairs to correctly represent Unicode
/// characters beyond the Basic Multilingual Plane (BMP). This
/// function combines surrogate pairs into single code points, matching UTF-16
/// encoding.
///
/// Args:
///   string: The input string to decode.
///
/// Returns:
///   A [List<int>] where each element represents a Unicode code point.
List<int> ucs2decode(String string) {
  final output = <int>[];
  var counter = 0;
  while (counter < string.length) {
    final value = string.codeUnitAt(counter++);
    if (value >= 0xD800 && value <= 0xDBFF && counter < string.length) {
      // It's a high surrogate, and there is a next character.
      final extra = string.codeUnitAt(counter++) - 0xDC00 + 0x10000;
      if ((extra & 0xFC00) == 0xDC00) {
        // Low surrogate.
        output.add(((value & 0x3FF) << 10) + (extra & 0x3FF) + 0x10000);
      } else {
        // It's an unmatched surrogate; only append this code unit, in case the
        // next code unit is the high surrogate of a surrogate pair.
        output.add(value);
        counter--;
      }
    } else {
      output.add(value);
    }
  }
  return output;
}

/// Converts a digit/integer into a basic code point.
///
/// See `basicToDigit()`
///
/// Args:
///   digit: The numeric value of a basic code point.  Must be in the range
///     `0` to `base - 1` (where `base` is presumably 36, but this function
///     doesn't depend on that).
///   flag: If non-zero, the uppercase form is used; else, the lowercase form
///     is used.
///
/// Returns:
///   The basic code point (an integer representing a Unicode code point)
///   whose value (when used for representing integers) is `digit`.
///
/// Throws:
///    ArgumentError: if digit is outside of the range 0-35.
int digitToBasic(int digit, int flag) {
  //  0..25 map to ASCII a..z or A..Z
  // 26..35 map to ASCII 0..9
  if (digit < 0 || digit > 35) {
    throw ArgumentError.value(digit, 'digit', 'must be between 0 and 35');
  }
  if (digit < 26) {
    // a-z or A-Z
    if (flag != 0) {
      return 'A'.codeUnitAt(0) + digit; // Uppercase
    } else {
      return 'a'.codeUnitAt(0) + digit; // Lowercase
    }
  } else {
    // 0-9
    return '0'.codeUnitAt(0) + (digit - 26);
  }
}

/// Converts a basic code point (ASCII character) to its corresponding digit value.
///
/// This function maps ASCII characters representing digits (0-9) and letters (A-Z, a-z)
/// to their corresponding integer values used in Punycode encoding.
///
/// Args:
///   codePoint: The ASCII code point to convert.
///
/// Returns:
///   The integer value of the code point, or [bootstrapValues.base] if the
///   code point is not a valid basic code point.
///   - 0-25: Represents 'a' to 'z' (or 'A' to 'Z').
///   - 26-35: Represents '0' to '9'.
///   - [bootstrapValues.base]: Represents an invalid code point.
int basicToDigit(int codePoint) {
  if (codePoint >= 0x30 && codePoint < 0x3A) {
    return 26 + (codePoint - 0x30);
  }
  if (codePoint >= 0x41 && codePoint < 0x5B) {
    return codePoint - 0x41;
  }
  if (codePoint >= 0x61 && codePoint < 0x7B) {
    return codePoint - 0x61;
  }
  return bootstrapValues.base;
}

/// A record of handy regular expressions to use when working with Punycode
final punycodeRegex = (
  regexPunycode: RegExp('^xn--'),
  regexNonASCII: RegExp(r'[^\x00-\x7F]'), // Note: U+007F DEL is excluded too.
  regexSeparators: RegExp(r'[\x2E\u3002\uFF0E\uFF61]'), // RFC 3490 separators
);
