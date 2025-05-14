import 'package:iri/iri.dart';

/// Provides constants for XML Schema Definition (XSD) datatype IRIs.
///
/// These IRIs are commonly used in RDF literals to specify the datatype
/// of the literal's value.
///
/// See: https://www.w3.org/TR/xmlschema-2/
/// See: https://www.w3.org/TR/rdf12-concepts/#xsd-datatypes
final class XSD {
  /// The base namespace for XML Schema datatypes.
  static const String namespace = 'http://www.w3.org/2001/XMLSchema#';

  // --- Primitive Datatypes ---

  /// `xsd:string` - Represents character strings.
  static final IRI string = IRI('${namespace}string');

  /// `xsd:boolean` - Represents boolean values (true, false).
  static final IRI boolean = IRI('${namespace}boolean');

  /// `xsd:float` - Represents 32-bit floating-point numbers.
  static final IRI float = IRI('${namespace}float');

  /// `xsd:double` - Represents 64-bit floating-point numbers.
  static final IRI double = IRI('${namespace}double');

  /// `xsd:decimal` - Represents arbitrary-precision decimal numbers.
  static final IRI decimal = IRI('${namespace}decimal');

  /// `xsd:duration` - Represents a duration of time.
  static final IRI duration = IRI('${namespace}duration');

  /// `xsd:dateTime` - Represents a specific date and time.
  static final IRI dateTime = IRI('${namespace}dateTime');

  /// `xsd:time` - Represents a specific time of day.
  static final IRI time = IRI('${namespace}time');

  /// `xsd:date` - Represents a specific date.
  static final IRI date = IRI('${namespace}date');

  /// `xsd:gYearMonth` - Represents a specific Gregorian year and month.
  static final IRI gYearMonth = IRI('${namespace}gYearMonth');

  /// `xsd:gYear` - Represents a specific Gregorian year.
  static final IRI gYear = IRI('${namespace}gYear');

  /// `xsd:gMonthDay` - Represents a specific Gregorian month and day.
  static final IRI gMonthDay = IRI('${namespace}gMonthDay');

  /// `xsd:gDay` - Represents a specific Gregorian day of the month.
  static final IRI gDay = IRI('${namespace}gDay');

  /// `xsd:gMonth` - Represents a specific Gregorian month.
  static final IRI gMonth = IRI('${namespace}gMonth');

  /// `xsd:hexBinary` - Represents hex-encoded binary data.
  static final IRI hexBinary = IRI('${namespace}hexBinary');

  /// `xsd:base64Binary` - Represents Base64-encoded binary data.
  static final IRI base64Binary = IRI('${namespace}base64Binary');

  /// `xsd:anyURI` - Represents a URI reference.
  static final IRI anyURI = IRI('${namespace}anyURI');

  // --- Derived Datatypes ---

  /// `xsd:integer` - Represents arbitrary-size integer numbers.
  static final IRI integer = IRI('${namespace}integer');

  /// `xsd:dateTimeStamp` - Represents a dateTime with a required timezone.
  static final IRI dateTimeStamp = IRI('${namespace}dateTimeStamp');

  /// `xsd:yearMonthDuration` - Represents duration measured in years and months.
  static final IRI yearMonthDuration = IRI('${namespace}yearMonthDuration');

  /// `xsd:dayTimeDuration` - Represents duration measured in days, hours, minutes, seconds.
  static final IRI dayTimeDuration = IRI('${namespace}dayTimeDuration');

  /// `xsd:byte` - Represents signed 8-bit integers (-128 to +127).
  static final IRI byte = IRI('${namespace}byte');

  /// `xsd:short` - Represents signed 16-bit integers (-32768 to +32767).
  static final IRI short = IRI('${namespace}short');

  /// `xsd:int` - Represents signed 32-bit integers.
  static final IRI int = IRI('${namespace}int');

  /// `xsd:long` - Represents signed 64-bit integers.
  static final IRI long = IRI('${namespace}long');

  /// `xsd:unsignedByte` - Represents unsigned 8-bit integers (0 to 255).
  static final IRI unsignedByte = IRI('${namespace}unsignedByte');

  /// `xsd:unsignedShort` - Represents unsigned 16-bit integers (0 to 65535).
  static final IRI unsignedShort = IRI('${namespace}unsignedShort');

  /// `xsd:unsignedInt` - Represents unsigned 32-bit integers.
  static final IRI unsignedInt = IRI('${namespace}unsignedInt');

  /// `xsd:unsignedLong` - Represents unsigned 64-bit integers.
  static final IRI unsignedLong = IRI('${namespace}unsignedLong');

  /// `xsd:positiveInteger` - Represents integers greater than 0.
  static final IRI positiveInteger = IRI('${namespace}positiveInteger');

  /// `xsd:nonNegativeInteger` - Represents integers greater than or equal to 0.
  static final IRI nonNegativeInteger = IRI('${namespace}nonNegativeInteger');

  /// `xsd:negativeInteger` - Represents integers less than 0.
  static final IRI negativeInteger = IRI('${namespace}negativeInteger');

  /// `xsd:nonPositiveInteger` - Represents integers less than or equal to 0.
  static final IRI nonPositiveInteger = IRI('${namespace}nonPositiveInteger');

  /// `xsd:language` - Represents language tags per BCP 47.
  static final IRI language = IRI('${namespace}language');

  /// `xsd:normalizedString` - Represents whitespace-normalized strings.
  static final IRI normalizedString = IRI('${namespace}normalizedString');

  /// `xsd:token` - Represents tokenized strings (no leading/trailing/internal spaces).
  static final IRI token = IRI('${namespace}token');

  /// `xsd:NMTOKEN` - Represents XML NMTOKENs.
  static final IRI nmToken = IRI('${namespace}NMTOKEN');

  /// `xsd:Name` - Represents XML Names.
  static final IRI name = IRI('${namespace}Name');

  /// `xsd:NCName` - Represents XML NCNames (non-colonized names).
  static final IRI ncName = IRI('${namespace}NCName');

  /// Private constructor to prevent instantiation.
  XSD._();
}
