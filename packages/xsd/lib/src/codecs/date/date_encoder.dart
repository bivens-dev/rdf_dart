import 'dart:convert';

import 'package:xsd/src/codecs/date/date_codec.dart';
import 'package:xsd/src/codecs/date/config.dart';
import 'package:xsd/src/implementations/date.dart';
import 'package:xsd/src/helpers/whitespace.dart';

/// Encoder: Converts an XSD date lexical string into an [Date] object.
///
/// Parses strings conforming to the `xsd:date` lexical format:
/// `CCYY-MM-DD(Z|(+|-)hh:mm)?`
/// Throws [FormatException] if the input string is not a valid lexical
/// representation or if the date components are invalid (e.g., invalid day
/// for month/year, year 0).
class XsdDateEncoder extends Converter<String, Date> {
  const XsdDateEncoder();

  @override
  Date convert(String input) {
    // Process whitespace according to XSD rules
    final processedInput = processWhiteSpace(
      input,
      dateConstraints.whitespace,
    );

    // Use the refined regex to match and extract components
    final match = dateConstraints.refinedRegex.firstMatch(
      processedInput,
    );

    // If the regex doesn't match the expected format, throw an error
    if (match == null) {
      throw FormatException('Invalid xsd:date format: "$input"');
    }

    try {
      // Extract year, month, and day strings from regex groups
      final yearString = match.group(1)!;
      final monthString = match.group(2)!;
      final dayString = match.group(3)!;

      // Parse numeric components
      final year = int.parse(yearString);
      final month = int.parse(monthString);
      final day = int.parse(dayString);

      // Parse the optional timezone using the static helper
      final timeZoneOffset = XsdDateCodec.parseTimeZone(match);

      // Create the XsdDate object; the constructor handles final validation
      return Date(
        year: year,
        month: month,
        day: day,
        timeZoneOffset: timeZoneOffset,
      );
      // Catch validation errors from the XsdDate constructor
      // (e.g., day invalid for month/year, year 0, invalid timezone range)
      // ignore: avoid_catching_errors
    } on ArgumentError catch (e) {
      // Re-throw as FormatException for consistency within the converter
      throw FormatException(
        'Invalid date components for "$input": ${e.message}',
      );
    } on FormatException catch (e) {
      // Catch potential int.parse errors
      throw FormatException('Invalid number format in "$input": $e');
    } catch (e) {
      // Catch any other unexpected errors during parsing
      throw FormatException('Error parsing xsd:date "$input": $e');
    }
  }
}