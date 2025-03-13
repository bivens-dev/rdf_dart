import 'dart:convert';

import 'package:rdf_dart/rdf_dart.dart';

import 'decoder.dart';
import 'encoder.dart';

/// {@template ntriples_codec}
/// A codec for encoding and decoding N-Triples data.
///
/// This class implements the [Codec] interface to provide a way to both
/// parse (decode) N-Triples strings into a [Set] of [Triple] objects,
/// and serialize (encode) a [Set] of [Triple] objects into an N-Triples string.
///
/// The codec uses [NTriplesParser] to perform the parsing and [NTriplesSerializer]
/// to perform the serialization.
///
/// Example:
/// ```dart
/// final codec = NTriplesCodec();
/// final parser = codec.encoder;
/// final serializer = codec.decoder;
///
/// final ntriplesString = '<http://example.com/subject> <http://example.com/predicate> "object" .';
/// final triples = parser.convert(ntriplesString);
/// print(triples); // Output: {http://example.com/subject http://example.com/predicate "object" .}
///
/// final newNtriplesString = serializer.convert(triples);
/// print(newNtriplesString); // Output: <http://example.com/subject> <http://example.com/predicate> "object" .\n
/// ```
/// {@endtemplate}
final class NTriplesCodec extends Codec<String, Set<Triple>> {
  /// {@macro ntriples_codec}
  const NTriplesCodec();
  
  /// Returns a [NTriplesSerializer] which serializes a [Set] of [Triple] objects to
  /// an N-Triples string.
  @override
  Converter<Set<Triple>, String> get decoder => const NTriplesSerializer();
  
  /// Returns a [NTriplesParser] which parses an N-Triples string to a [Set] of [Triple] objects.
  @override
  Converter<String, Set<Triple>> get encoder => const NTriplesParser();
}
