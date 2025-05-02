import 'dart:convert';

import 'package:rdf_dart/src/codec/ntriples/ntriples_decoder.dart';
import 'package:rdf_dart/src/codec/ntriples/ntriples_encoder.dart';
import 'package:rdf_dart/src/model/triple.dart';

/// A [Codec] for encoding and decoding RDF triples according to the
/// N-Triples specification.
///
/// This codec transforms between a [List<Triple>] and its N-Triples
/// string representation. It adheres to the RDF 1.2 N-Triples specification:
/// https://www.w3.org/TR/rdf12-n-triples/
///
/// Example (Encoding):
/// ```dart
/// final triples = [
///   Triple(
///     IRINode(IRI('http://example.org/subject')),
///     IRINode(IRI('http://example.org/predicate')),
///     Literal('object value', XSD.string)
///   ),
///   // ... more triples
/// ];
/// final nTriplesString = nTriplesCodec.encode(triples);
/// print(nTriplesString);
/// ```
///
/// Example (Decoding):
/// ```dart
/// const nTriplesData = '''
/// <http://example.org/john> <http://example.org/knows> <http://example.org/steve> .
/// <http://example.org/john> <http://example.org/age> <http://example.org/42> .
/// ''';
/// final decodedTriples = nTriplesCodec.decode(nTriplesData);
/// print(decodedTriples.length); // Output: 2
/// ```
///
/// Example (Streaming Decoding):
/// ```dart
/// Stream<String> nTriplesStream = getNTriplesStream(); // Your stream source
/// Stream<List<Triple>> triplesStream = nTriplesStream
///     .transform(utf8.decoder) // Ensure input is String
///     .transform(nTriplesCodec.decoder);
///
/// triplesStream.listen((tripleList) {
///   // Process each triple as it's parsed (usually one per list)
///   for (final triple in tripleList) {
///     print('Parsed Triple: $triple');
///   }
/// });
/// ```
class NTriplesCodec extends Codec<List<Triple>, String> {
  /// Creates an N-Triples codec.
  const NTriplesCodec();

  @override
  Converter<List<Triple>, String> get encoder => const NTriplesEncoder();

  @override
  Converter<String, List<Triple>> get decoder => const NTriplesDecoder();
}

/// Constant instance of the default [NTriplesCodec].
const nTriplesCodec = NTriplesCodec();
