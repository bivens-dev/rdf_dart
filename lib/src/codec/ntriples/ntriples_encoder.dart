import 'dart:convert';

import 'package:rdf_dart/rdf_dart.dart';

/// Converts a `List<Triple>` to its N-Triples string representation.
///
/// Follows the RDF 1.2 N-Triples specification for formatting terms and triples.
/// https://www.w3.org/TR/rdf12-n-triples/
class NTriplesEncoder extends Converter<List<Triple>, String> {
  const NTriplesEncoder();
  
  @override
  String convert(List<Triple> input) {
    // TODO: implement convert
    throw UnimplementedError();
  }
}