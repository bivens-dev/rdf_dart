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