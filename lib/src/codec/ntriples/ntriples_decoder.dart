import 'dart:convert';

import 'package:rdf_dart/rdf_dart.dart';

// Consider using 'package:characters/characters.dart' if complex grapheme handling is needed,
// but standard string indexing might suffice for N-Triples parsing.

/// Converts an N-Triples string representation into a `List<Triple>`.
///
/// Supports streaming decoding via `startChunkedConversion`.
/// Follows the RDF 1.2 N-Triples specification:
/// https://www.w3.org/TR/rdf12-n-triples/
///
/// It uses a recursive descent approach based on the EBNF grammar.
class NTriplesDecoder extends Converter<String, List<Triple>> {
  const NTriplesDecoder();

  @override
  StringConversionSink startChunkedConversion(Sink<List<Triple>> sink) {
    // TODO: implement convert
    throw UnimplementedError();
  }

  @override
  List<Triple> convert(String input) {
    // TODO: implement convert
    throw UnimplementedError();
  }
}
