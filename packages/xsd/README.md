# XSD
Provides Dart representations and codecs for many common data types defined in the
[W3C XML Schema Part 2: Datatypes Second Edition](https://www.w3.org/TR/2004/REC-xmlschema-2-20041028/) specification.

This package helps developers work with XML Schema datatypes in Dart applications by providing tools for:

* **Parsing:** Converting lexical (string) representations from XML documents into appropriate Dart types.
* **Serialization:** Converting Dart types back into their canonical XSD lexical representations.
* **Validation:** Ensuring that values conform to the constraints (like range, pattern, length) defined by the XSD specification for each type.
* **Custom Types:** Offering dedicated Dart classes for complex XSD types (like `Date`, `XSDDuration`, `XsdGMonthDay`) that don't have direct Dart equivalents.

## Features

* **Type-Safe Codecs:** Utilizes Dart's `Codec` system for reliable bidirectional conversion between XSD strings and Dart types (`bool`, `int`, `BigInt`, `double`, `Decimal`, and custom classes).
* **Specification Compliance:** Aims to adhere closely to the W3C XML Schema Part 2 specification regarding lexical rules, value spaces, and constraining facets.
* **Custom Classes:** Provides immutable Dart classes for `xsd:date`, `xsd:duration`, and `xsd:gMonthDay`, handling their unique validation and formatting rules.
* **Whitespace Processing:** Includes helpers for XSD whitespace normalization (`preserve`, `replace`, `collapse`).
* **Well-Tested:** Includes a comprehensive test suite to verify correctness against various valid and invalid inputs.

## Getting Started

1.  **Add Dependency:** Add the package to your `pubspec.yaml`:
    ```yaml
    dependencies:
      xsd: ^0.1.0 # Use the latest version
      decimal: ^3.2.1 # Required if using xsd:decimal
    ```
    Or run:
    ```bash
    dart pub add xsd
    dart pub add decimal # If using xsd:decimal
    ```

2.  **Import:** Import the library in your Dart code:
    ```dart
    import 'package:xsd/xsd.dart';
    // Import decimal if needed
    import 'package:decimal/decimal.dart';
    ```

## Usage

Use the exported codec instances to convert between XSD strings and Dart types.

```dart
import 'package:xsd/xsd.dart';
import 'package:decimal/decimal.dart';

void main() {
  // --- Using Codecs for Primitive/Derived Types ---

  // Boolean (xsd:boolean)
  bool isEnabled = booleanCodec.encoder.convert('1'); // Result: true
  String boolStr = booleanCodec.decoder.convert(false); // Result: 'false'
  print('Boolean: $isEnabled, "$boolStr"');

  // Integer types (xsd:int, xsd:byte, etc.)
  int count = intCodec.encoder.convert('   -100   '); // Result: -100
  String countStr = intCodec.decoder.convert(count);   // Result: '-100'
  print('Int: $count, "$countStr"');

  // Use BigInt for xsd:integer, xsd:long, xsd:unsignedLong
  BigInt largeInt = bigIntCodec.encoder.convert('9999999999999999999');
  print('Integer (BigInt): $largeInt');

  // Decimal (xsd:decimal) - requires package:decimal
  Decimal price = decimalCodec.encoder.convert('19.95');
  String priceStr = decimalCodec.decoder.convert(price); // Result: '19.95'
  print('Decimal: $price, "$priceStr"');

  // --- Using Custom Implementation Classes ---

  // Date (xsd:date)
  Date today = Date(year: 2025, month: 5, day: 1);
  String dateStr = today.toString(); // Result: '2025-05-01'
  Date parsedDate = xsdDateCodec.encoder.convert('2025-05-01-05:00');
  print('Date: $dateStr, Parsed Date TZ: ${parsedDate.timeZoneOffset}');

  // Duration (xsd:duration)
  XSDDuration period = XSDDuration(years: 2, days: 10);
  String durationStr = period.toString(); // Result: 'P2Y10D'
  XSDDuration parsedDuration = durationCodec.encoder.convert('-PT1M30.5S');
  print('Duration: $durationStr, Parsed Seconds: ${parsedDuration.seconds}');

  // GMonthDay (xsd:gMonthDay)
  XsdGMonthDay recurringDay = XsdGMonthDay(month: 12, day: 25);
  String gMonthDayStr = recurringDay.toString(); // Result: '--12-25'
  XsdGMonthDay parsedGMonthDay = xsdGMonthDayCodec.encoder.convert('--12-25Z');
  print('GMonthDay: $gMonthDayStr, Parsed TZ: ${parsedGMonthDay.timeZoneOffset}');

  // --- Validation Example ---
  try {
    // Invalid boolean format
    booleanCodec.encoder.convert('yes');
  } on FormatException catch (e) {
    print('Validation failed as expected: $e');
  }
}

```

## Implemented Datatypes
This package currently implements the following XSD datatypes:

### Numeric Types:
- `xsd:decimal`
- `xsd:double`
- `xsd:integer`
- `xsd:long`
- `xsd:int`
- `xsd:short`
- `xsd:byte`
- `xsd:nonNegativeInteger`
- `xsd:positiveInteger`
- `xsd:unsignedLong`
- `xsd:unsignedInt`
- `xsd:unsignedShort`
- `xsd:unsignedByte`
- `xsd:nonPositiveInteger`
- `xsd:negativeInteger`

### Date/Time Types:
- `xsd:date`
- `xsd:duration`
- `xsd:gMonthDay`

### Other Types:
- `xsd:boolean`

(Support for other types like `xsd:string`, `xsd:dateTime`, `xsd:hexBinary`, `xsd:QName`,  etc., is planned for future releases).