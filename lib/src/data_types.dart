// lib/src/data_types.dart

import 'package:rdf_dart/rdf_dart.dart';

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
      IRI('http://www.w3.org/2001/XMLSchema#string'),
      String,
      (lexicalForm) => lexicalForm,
      (value) => value.toString(),
    );
    registerDatatype(
      IRI('http://www.w3.org/2001/XMLSchema#integer'),
      int,
      int.parse,
      (value) => value.toString(),
    );
    registerDatatype(
      IRI('http://www.w3.org/2001/XMLSchema#double'),
      double,
      double.parse,
      (value) => value.toString(),
    );
    registerDatatype(
      IRI('http://www.w3.org/2001/XMLSchema#dateTime'),
      DateTime,
      DateTime.parse,
      (value) => (value as DateTime).toUtc().toIso8601String(),
    );
    registerDatatype(
      IRI('http://www.w3.org/2001/XMLSchema#boolean'),
      bool,
      (lexicalForm) {
        final lowerCaseLexicalForm = lexicalForm.toLowerCase();
        if (lowerCaseLexicalForm == 'true' || lowerCaseLexicalForm == '1') {
          return true;
        } else if (lowerCaseLexicalForm == 'false' ||
            lowerCaseLexicalForm == '0') {
          return false;
        } else {
          throw FormatException('Invalid xsd:boolean value: $lexicalForm');
        }
      },
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
      throw Exception('Datatype $datatypeIri not registered.');
    }
    return info;
  }
}
