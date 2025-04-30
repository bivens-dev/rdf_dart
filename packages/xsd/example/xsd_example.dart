import 'package:xsd/src/codecs/date/date_codec.dart';
import 'package:xsd/xsd.dart';

void main() {
  // Codecs for XSD Types to convert between XSD data and Dart native types
  final isTrue = booleanCodec.encode('1');
  print('Is True: $isTrue');

  // Custom classes for XSD Types without a Dart equivalent
  print('Todays Date: ${Date(day: 21, month: 01, year: 2024)}');

  // Along with the ability to convert back and forth
  final tomorrowsDate = xsdDateCodec.encoder.convert('2024-01-22');
  print('Tomorrows Date: $tomorrowsDate');
}
