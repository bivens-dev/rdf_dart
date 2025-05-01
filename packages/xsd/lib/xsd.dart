/// Provides Dart representations and codecs for W3C XML Schema Datatypes (XSD).
///
/// This library offers tools for working with data types defined in the
/// [W3C XML Schema Part 2: Datatypes Second Edition](https://www.w3.org/TR/2004/REC-xmlschema-2-20041028/)
/// specification. It includes:
///
/// * **Codecs:** For converting between XSD lexical string representations and
///     native Dart types (`bool`, `int`, `double`, `BigInt`, `Decimal`). Examples
///     include [booleanCodec], [intCodec], [doubleCodec], [bigIntCodec]
///     (for `xsd:integer`), and [decimalCodec].
/// * **Custom Classes:** Immutable Dart classes for XSD types without direct
///     Dart equivalents, such as [Date] (`xsd:date`), [XSDDuration] (`xsd:duration`),
///     and [XsdGMonthDay] (`xsd:gMonthDay`). These classes handle XSD-specific
///     validation, canonical formatting, and comparison logic (where applicable).
/// * **Validation:** Enforces lexical and value space constraints according to
///     the XSD specification, including range limits for numeric types and
///     pattern matching.
/// * **Whitespace Processing:** Includes utilities like [processWhiteSpace] to
///     handle XSD whitespace facets (`preserve`, `replace`, `collapse`).
///
/// ## Usage
///
/// ```dart
/// import 'package:xsd/xsd.dart';
///
/// void main() {
///   // Boolean
///   bool isEnabled = booleanCodec.decode('1'); // true
///   String boolStr = booleanCodec.encode(false); // 'false'
///   print('Boolean: $isEnabled, "$boolStr"');
/// }
/// 
/// ```
///
/// See Also:
/// * [W3C XML Schema Part 2: Datatypes Second Edition](https://www.w3.org/TR/2004/REC-xmlschema-2-20041028/)
library;

export 'src/codecs/boolean/boolean_codec.dart';
export 'src/codecs/byte/byte_codec.dart';
export 'src/codecs/date/date_codec.dart';
export 'src/codecs/decimal/decimal_codec.dart';
export 'src/codecs/double/double_codec.dart';
export 'src/codecs/duration/duration_codec.dart';
export 'src/codecs/gMonthDay/g_month_day_codec.dart';
export 'src/codecs/int/int_codec.dart';
export 'src/codecs/integer/integer_codec.dart';
export 'src/codecs/long/long_codec.dart';
export 'src/codecs/negativeInteger/negative_integer_codec.dart';
export 'src/codecs/nonNegativeInteger/non_negative_integer_codec.dart';
export 'src/codecs/nonPositiveInteger/non_positive_integer_codec.dart';
export 'src/codecs/positiveInteger/positive_integer_codec.dart';
export 'src/codecs/short/short_codec.dart';
export 'src/codecs/unsignedByte/unsigned_byte_codec.dart';
export 'src/codecs/unsignedInt/unsigned_int_codec.dart';
export 'src/codecs/unsignedLong/unsigned_long_codec.dart';
export 'src/codecs/unsignedShort/unsigned_short_codec.dart';
export 'src/implementations/date.dart';
export 'src/implementations/duration.dart';
export 'src/implementations/g_month_day.dart';
export 'src/helpers/whitespace.dart';
