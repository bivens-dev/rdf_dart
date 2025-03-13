import 'dart:convert';

import 'package:rdf_dart/rdf_dart.dart';

final class NTriplesSerializer extends Converter<Set<Triple>, String> {
  const NTriplesSerializer();
  @override
  String convert(Set<Triple> input) {
    // TODO: implement convert
    throw UnimplementedError();
  }
}
