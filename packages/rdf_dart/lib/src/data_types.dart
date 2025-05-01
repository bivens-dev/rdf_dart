import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/locale.dart';
import 'package:rdf_dart/src/exceptions/datatype_not_found_exception.dart';
import 'package:rdf_dart/src/iri.dart';
import 'package:rdf_dart/src/vocab/rdf_vocab.dart';
import 'package:rdf_dart/src/vocab/xsd_vocab.dart';
import 'package:xsd/xsd.dart';

/// A function that takes a lexical form (a string) and returns a Dart object.
///
/// This function is used to parse the string representation of a literal value
/// into its corresponding Dart object. For example, the lexical form "42"
/// might be parsed into the Dart `int` value `42`.
typedef LiteralParser = Object Function(String lexicalForm);

/// A function that takes a Dart object and returns its lexical form (a string).
///
/// This function is used to format a Dart object back into its string
/// representation. For example, the Dart `int` value `42` might be formatted
/// into the lexical form "42".
typedef LiteralFormatter = String Function(Object value);

/// Contains information about a specific datatype.
///
/// This class encapsulates the Dart type, the parser function, and the
/// formatter function for a single datatype.
class DatatypeInfo {
  /// The Dart type associated with this datatype.
  ///
  /// For example, `int`, `double`, `String`, or `DateTime`.
  final Type dartType;

  /// The function used to parse the lexical form of a literal of this datatype.
  ///
  /// This function takes a string and returns a Dart object of type
  /// [dartType].
  final LiteralParser parser;

  /// The function used to format a value of this datatype into its lexical form.
  ///
  /// This function takes a Dart object of type [dartType] and returns its
  /// string representation.
  final LiteralFormatter formatter;

  /// Creates a [DatatypeInfo] instance.
  ///
  /// - [dartType]: The Dart type associated with the datatype.
  /// - [parser]: The function used to parse the lexical form.
  /// - [formatter]: The function used to format a value into its lexical form.
  DatatypeInfo({
    required this.dartType,
    required this.parser,
    required this.formatter,
  });
}

/// A registry for managing datatypes and their associated parsers and formatters.
///
/// This class is a singleton that provides a central location to register and
/// look up information about different datatypes.
class DatatypeRegistry {
  /// The singleton instance of the [DatatypeRegistry].
  static final DatatypeRegistry _instance = DatatypeRegistry._internal();

  /// Returns the singleton instance of the [DatatypeRegistry].
  factory DatatypeRegistry() {
    return _instance;
  }

  /// The internal constructor for the singleton.
  ///
  /// This constructor registers the default datatypes.
  DatatypeRegistry._internal() {
    // Register default datatypes
    registerDatatype(
      XSD.string,
      String,
      (lexicalForm) => processWhiteSpace(lexicalForm, Whitespace.preserve),
      (value) => processWhiteSpace(value.toString(), Whitespace.preserve),
    );
    registerDatatype(
      XSD.anyURI,
      Uri,
      (lexicalForm) =>
          Uri.parse(processWhiteSpace(lexicalForm, Whitespace.collapse)),
      (value) => processWhiteSpace(value.toString(), Whitespace.collapse),
    );
    registerDatatype(
      XSD.normalizedString,
      String,
      (lexicalForm) => processWhiteSpace(lexicalForm, Whitespace.replace),
      (value) => processWhiteSpace(value.toString(), Whitespace.replace),
    );
    registerDatatype(
      XSD.token,
      String,
      (lexicalForm) => processWhiteSpace(lexicalForm, Whitespace.collapse),
      (value) => processWhiteSpace(value.toString(), Whitespace.collapse),
    );
    registerDatatype(
      RDF.langString,
      String,
      (lexicalForm) => processWhiteSpace(lexicalForm, Whitespace.preserve),
      (value) => processWhiteSpace(value.toString(), Whitespace.preserve),
    );
    registerDatatype(
      XSD.nonNegativeInteger,
      int,
      nonNegativeInteger.encoder.convert,
      nonNegativeInteger.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.duration,
      XSDDuration,
      durationCodec.encoder.convert,
      durationCodec.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.gMonthDay,
      XsdGMonthDay,
      xsdGMonthDayCodec.encoder.convert,
      xsdGMonthDayCodec.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.date,
      Date,
      xsdDateCodec.encoder.convert,
      xsdDateCodec.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.negativeInteger,
      int,
      negativeInteger.encoder.convert,
      negativeInteger.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.nonPositiveInteger,
      int,
      nonPositiveInteger.encoder.convert,
      nonPositiveInteger.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.positiveInteger,
      int,
      positiveInteger.encoder.convert,
      positiveInteger.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.integer,
      BigInt,
      bigIntCodec.encoder.convert,
      bigIntCodec.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.decimal,
      Decimal,
      decimalCodec.encoder.convert,
      decimalCodec.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.double,
      double,
      doubleCodec.encoder.convert,
      doubleCodec.decoder.convert as LiteralFormatter,
    );
    // Technically it only represents a 32-bit sized number compared
    // to the 64 bit of a double but its logic to and from a Dart
    // native [double] is otherwise the same so just reuse the double codec
    registerDatatype(
      XSD.float,
      double,
      doubleCodec.encoder.convert,
      doubleCodec.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.dateTime,
      DateTime,
      DateTime.parse,
      (value) => (value as DateTime).toUtc().toIso8601String(),
    );
    registerDatatype(
      XSD.boolean,
      bool,
      booleanCodec.encoder.convert,
      booleanCodec.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.base64Binary,
      Uint8List,
      base64.decode,
      base64.encode as LiteralFormatter,
    );
    registerDatatype(
      XSD.hexBinary,
      Uint8List,
      hex.decode,
      hex.encode as LiteralFormatter,
    );
    registerDatatype(
      XSD.unsignedByte,
      int,
      unsignedByte.encoder.convert,
      unsignedByte.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.byte,
      int,
      byte.encoder.convert,
      byte.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.unsignedShort,
      int,
      unsignedShort.encoder.convert,
      unsignedShort.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.short,
      int,
      shortCodec.encoder.convert,
      shortCodec.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.int,
      int,
      intCodec.encoder.convert,
      intCodec.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.unsignedInt,
      int,
      unsignedInt.encoder.convert,
      unsignedInt.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.unsignedLong,
      BigInt,
      unsignedLong.encoder.convert,
      unsignedLong.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.long,
      BigInt,
      longCodec.encoder.convert,
      longCodec.decoder.convert as LiteralFormatter,
    );
    registerDatatype(
      XSD.language,
      Locale,
      Locale.parse,
      (value) => value.toString(),
    );
  }

  /// The map that holds the registered datatypes.
  final Map<IRI, DatatypeInfo> _registry = {};

  /// Registers a new datatype with its associated parser and formatter.
  ///
  /// - [datatypeIri]: The [IRI] of the datatype.
  /// - [dartType]: The Dart [Type] associated with the datatype.
  /// - [parser]: The [LiteralParser] used to parse the lexical form of a
  ///   literal of this datatype.
  /// - [formatter]: The [LiteralFormatter] used to format a value of this
  ///   datatype into its lexical form.
  ///
  /// Example:
  /// ```dart
  /// final myDatatype = IRI('http://example.org/myDatatype');
  /// final myParser = (String lexicalForm) => int.parse(lexicalForm);
  /// final myFormatter = (Object value) => value.toString();
  /// DatatypeRegistry().registerDatatype(myDatatype, int, myParser, myFormatter);
  /// ```
  void registerDatatype(
    IRI datatypeIri,
    Type dartType,
    LiteralParser parser,
    LiteralFormatter formatter,
  ) {
    _registry[datatypeIri] = DatatypeInfo(
      dartType: dartType,
      parser: parser,
      formatter: formatter,
    );
  }

  /// Returns the [DatatypeInfo] for the given datatype IRI.
  ///
  /// Throws an [Exception] if the datatype is not registered.
  ///
  /// - [datatypeIri]: The [IRI] of the datatype to look up.
  DatatypeInfo getDatatypeInfo(IRI datatypeIri) {
    final info = _registry[datatypeIri];
    if (info == null) {
      throw DatatypeNotFoundException(datatypeIri.toString());
    }
    return info;
  }
}
