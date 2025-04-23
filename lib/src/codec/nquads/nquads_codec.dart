import 'dart:convert';

import 'package:rdf_dart/src/codec/nquads/nquads_decoder.dart';
import 'package:rdf_dart/src/codec/nquads/nquads_encoder.dart';
import 'package:rdf_dart/src/dataset.dart';

/// A [Codec] for encoding and decoding RDF [Dataset] objects to and from
/// N-Quads formatted strings.
///
/// This codec implements the conversions described in the
/// RDF 1.2 N-Quads specification: https://www.w3.org/TR/rdf12-n-quads/
///
/// Use the [encoder] to convert a [Dataset] to an N-Quads string.
/// Use the [decoder] to convert an N-Quads string to a [Dataset].
///
/// A pre-instantiated version is available as [nQuadsCodec].
class NQuadsCodec extends Codec<Dataset, String> {
  /// Creates an N-Quads codec.
  const NQuadsCodec();

  /// Returns the [NQuadsEncoder] for converting a [Dataset] to an N-Quads string.
  @override
  Converter<Dataset, String> get encoder => const NQuadsEncoder();

  /// Returns the [NQuadsDecoder] for converting an N-Quads string to a [Dataset].
  @override
  Converter<String, Dataset> get decoder => const NQuadsDecoder();
}

/// A default constant instance of the [NQuadsCodec].
///
/// Provides convenient access for encoding/decoding N-Quads.
/// ```dart
/// import 'package:rdf_dart/rdf_dart.dart';
/// import 'package:rdf_dart/src/codec/nquads/nquads_codec.dart'; // Or adjust import
///
/// final nquadsString = '<subj> <pred> <obj> <graph> .';
/// final dataset = nQuadsCodec.decode(nquadsString);
///
/// final encodedString = nQuadsCodec.encode(dataset);
/// ```
const nQuadsCodec = NQuadsCodec();
