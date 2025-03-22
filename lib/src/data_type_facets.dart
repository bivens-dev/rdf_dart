/// For some datatypes, this specifies an order relation for their value spaces
/// the ordered facet reflects this.
enum OrderedFacet {
  /// A none value means no order is prescribed;
  none,

  /// A total value assures that the prescribed order is a total order
  total,

  /// A partial value means that the prescribed order is a partial order,
  /// but not (for the primitive type in question) a total order.
  partial,
}

/// Every value space has a specific number of members. This number can be
/// characterized as finite or infinite. (Currently there are no datatypes
/// with infinite value spaces larger than countable.)
enum CardinalityFacet {
  /// When the mechanism for causing finiteness is difficult to detect, as,
  /// for example, when finiteness occurs because of a `derivation` using
  /// a pattern component
  countablyInfinite,

  /// Datatypes with finite value spaces
  finite,
}

/// This represents all of the supported XML data types as specified in RDF 1.2
enum XMLDataType {
  /// The string datatype represents character strings in XML.
  string(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#string',
  ),

  /// true, false
  boolean(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.finite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#boolean',
  ),

  /// 32-bit floating point numbers incl. ±Inf, ±0, NaN
  float(
    ordered: OrderedFacet.partial,
    bounded: true,
    cardinality: CardinalityFacet.finite,
    numeric: true,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#float',
  ),

  /// 64-bit floating point numbers incl. ±Inf, ±0, NaN
  double(
    ordered: OrderedFacet.partial,
    bounded: true,
    cardinality: CardinalityFacet.finite,
    numeric: true,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#double',
  ),

  /// Arbitrary-precision decimal numbers
  decimal(
    ordered: OrderedFacet.total,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: true,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#decimal',
  ),

  /// Duration of time
  duration(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#duration',
  ),

  /// Date and time with or without timezone
  dateTime(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#dateTime',
  ),

  /// Times (hh:mm:ss.sss…) with or without timezone
  time(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#time',
  ),

  /// Dates (yyyy-mm-dd) with or without timezone
  date(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#date',
  ),

  /// Gregorian calendar year and month
  gYearMonth(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#gYearMonth',
  ),

  /// Gregorian calendar year
  gYear(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#gYear',
  ),

  /// Gregorian calendar month and day
  gMonthDay(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#gMonthDay',
  ),

  /// Gregorian calendar day of the month
  gDay(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#gDay',
  ),

  /// Gregorian calendar month
  gMonth(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#gMonth',
  ),

  /// Hex-encoded binary data
  hexBinary(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#hexBinary',
  ),

  /// Base64-encoded binary data
  base64Binary(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#base64Binary',
  ),

  /// Resolved or relative URI and IRI references
  anyURI(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: true,
    iri: 'http://www.w3.org/2001/XMLSchema#anyURI',
  ),

  /// Arbitrary-size integer numbers
  integer(
    ordered: OrderedFacet.total,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#integer',
  ),

  /// Date and time with required timezone
  dateTimeStamp(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#dateTimeStamp',
  ),

  /// Duration of time (months and years only)
  yearMonthDuration(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#yearMonthDuration',
  ),

  /// Duration of time (days, hours, minutes, seconds only)
  dayTimeDuration(
    ordered: OrderedFacet.partial,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#dayTimeDuration',
  ),

  /// -128…+127 (8 bit)
  byte(
    ordered: OrderedFacet.total,
    bounded: true,
    cardinality: CardinalityFacet.finite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#byte',
  ),

  /// -32768…+32767 (16 bit)
  short(
    ordered: OrderedFacet.total,
    bounded: true,
    cardinality: CardinalityFacet.finite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#short',
  ),

  /// -2147483648…+2147483647 (32 bit)
  int(
    ordered: OrderedFacet.total,
    bounded: true,
    cardinality: CardinalityFacet.finite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#int',
  ),

  /// -9223372036854775808… +9223372036854775807 (64 bit)
  long(
    ordered: OrderedFacet.total,
    bounded: true,
    cardinality: CardinalityFacet.finite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#long',
  ),

  /// 0…255 (8 bit)
  unsignedByte(
    ordered: OrderedFacet.total,
    bounded: true,
    cardinality: CardinalityFacet.finite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#unsignedByte',
  ),

  /// 0…65535 (16 bit)
  unsignedShort(
    ordered: OrderedFacet.total,
    bounded: true,
    cardinality: CardinalityFacet.finite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#unsignedShort',
  ),

  /// 0…4294967295 (32 bit)
  unsignedInt(
    ordered: OrderedFacet.total,
    bounded: true,
    cardinality: CardinalityFacet.finite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#unsignedInt',
  ),

  /// 0…18446744073709551615 (64 bit)
  unsignedLong(
    ordered: OrderedFacet.total,
    bounded: true,
    cardinality: CardinalityFacet.finite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#unsignedLong',
  ),

  /// Integer numbers > 0
  positiveInteger(
    ordered: OrderedFacet.total,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#positiveInteger',
  ),

  /// Integer numbers ≥ 0
  nonNegativeInteger(
    ordered: OrderedFacet.total,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#nonNegativeInteger',
  ),

  /// Integer numbers < 0
  negativeInteger(
    ordered: OrderedFacet.total,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#negativeInteger',
  ),

  /// Integer numbers ≤ 0
  nonPositiveInteger(
    ordered: OrderedFacet.total,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: true,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#nonPositiveInteger',
  ),

  /// Language tags per BCP47
  language(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#language',
  ),

  /// Whitespace-normalized strings
  normalizedString(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#normalizedString',
  ),

  /// Tokenized strings
  token(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#token',
  ),

  /// XML NMTOKENs
  nmToken(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#NMTOKEN',
  ),

  /// XML Names
  name(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#Name',
  ),

  /// XML NCNamea represents XML "non-colonized" Names.
  ncName(
    ordered: OrderedFacet.none,
    bounded: false,
    cardinality: CardinalityFacet.countablyInfinite,
    numeric: false,
    primativeType: false,
    iri: 'http://www.w3.org/2001/XMLSchema#NCName',
  );

  const XMLDataType({
    required this.ordered,
    required this.bounded,
    required this.cardinality,
    required this.numeric,
    required this.primativeType,
    required this.iri,
  });

  /// For some datatypes, this specifies an order relation
  /// for their value spaces
  final OrderedFacet ordered;

  /// Every value space has a specific number of members.  This number can be
  /// characterized as finite or infinite.
  final CardinalityFacet cardinality;

  /// Some ordered datatypes have the property that there is one value greater
  /// than or equal to every other value, and another that is less than or
  /// equal to every other value.
  final bool bounded;

  /// Some value spaces are made up of things that are conceptually numeric,
  /// others are not.
  final bool numeric;

  /// Primitive datatypes are those datatypes that are not ·special· and are
  /// not defined in terms of other datatypes; they exist ab initio.
  final bool primativeType;

  /// Represents the Internationalized Resource Identifier Reference (IRI)
  /// associated with this particular data type
  final String iri;
}
