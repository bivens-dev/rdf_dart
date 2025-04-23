import 'dart:convert';

import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/codec/n_formats/n_formats_serializer_utils.dart';

/// Converts a [Dataset] to its N-Quads string representation.
///
/// Follows the RDF 1.2 N-Quads specification:
/// https://www.w3.org/TR/rdf12-n-quads/
class NQuadsEncoder extends Converter<Dataset, String> {
  /// Creates an NQuadsEncoder.
  const NQuadsEncoder();

  /// Formats any [RdfTerm] into its N-Triples/N-Quads string representation.
  ///
  /// Uses the static methods from [NFormatsSerializerUtils] and handles
  /// [TripleTerm] recursively.
  String _formatTerm(RdfTerm term) {
    switch (term.termType) {
      case TermType.iri:
        // Use static method for IRI formatting
        return NFormatsSerializerUtils.formatIri((term as IRITerm).value);
      case TermType.blankNode:
        // Use static method for BlankNode formatting
        return NFormatsSerializerUtils.formatBlankNode(term as BlankNode);
      case TermType.literal:
        // Use static method for Literal formatting
        return NFormatsSerializerUtils.formatLiteral(term as Literal);
      case TermType.tripleTerm:
        // Handle TripleTerm formatting recursively
        return _formatTripleTerm(term as TripleTerm);
    }
  }

  /// Formats a [TripleTerm] according to N-Triples/N-Quads syntax: `<<( S P O )>>`.
  ///
  /// Recursively calls [_formatTerm] for the inner subject, predicate, and object.
  String _formatTripleTerm(TripleTerm term) {
    final subjStr = _formatTerm(term.triple.subject);
    final predStr = _formatTerm(term.triple.predicate);
    final objStr = _formatTerm(term.triple.object);
    // Note: N-Triples/N-Quads spec uses spaces within the <<( )>> delimiters.
    return '<<( $subjStr $predStr $objStr )>>';
  }

  @override
  String convert(Dataset input) {
    final buffer = StringBuffer();

    // 1. Serialize triples from the default graph (3 terms + dot + newline)
    for (final triple in input.defaultGraph.triples) {
      final subjStr = _formatTerm(triple.subject);
      final predStr = _formatTerm(triple.predicate);
      final objStr = _formatTerm(triple.object);
      // Format: subject predicate object .\\n
      buffer.write('$subjStr $predStr $objStr .\n');
    }

    // 2. Serialize quads from named graphs (4 terms + dot + newline)
    input.namedGraphs.forEach((graphLabel, graph) {
      // Validate graphLabel type (must be IRI or BlankNode for N-Quads)
      if (graphLabel is! IRITerm && graphLabel is! BlankNode) {
        throw ArgumentError(
            'Invalid graph label type for N-Quads serialization: ${graphLabel.runtimeType}. Must be IRITerm or BlankNode.');
      }
      final graphLabelStr = _formatTerm(graphLabel);

      for (final triple in graph.triples) {
        final subjStr = _formatTerm(triple.subject);
        final predStr = _formatTerm(triple.predicate);
        final objStr = _formatTerm(triple.object);
        // Format: subject predicate object graphLabel .\\n
        buffer.write('$subjStr $predStr $objStr $graphLabelStr .\n');
      }
    });

    return buffer.toString();
  }

  @override
  ChunkedConversionSink<Dataset> startChunkedConversion(Sink<String> sink) {
    // Pass the encoder instance itself so the sink can use its _formatTerm helper
    return _NQuadsEncoderSink(sink, this);
  }
}

/// Internal sink implementation for chunked N-Quads encoding.
class _NQuadsEncoderSink implements ChunkedConversionSink<Dataset> {
  final Sink<String> _outSink;
  // Keep a reference to the encoder to use its private formatting helpers
  final NQuadsEncoder _encoder;

   _NQuadsEncoderSink(this._outSink, this._encoder);

  @override
  void add(Dataset chunk) {
    final buffer = StringBuffer();

    // 1. Serialize triples from the chunk's default graph
    for (final triple in chunk.defaultGraph.triples) {
       final subjStr = _encoder._formatTerm(triple.subject);
       final predStr = _encoder._formatTerm(triple.predicate);
       final objStr = _encoder._formatTerm(triple.object);
       buffer.write('$subjStr $predStr $objStr .\n');
    }

    // 2. Serialize quads from the chunk's named graphs
    chunk.namedGraphs.forEach((graphLabel, graph) {
      // Consistent validation as in the convert method
      if (graphLabel is! IRITerm && graphLabel is! BlankNode) {
         // Let the error propagate. Applications using chunked conversion
         // should handle potential errors from the stream/sink.
         throw ArgumentError(
            'Invalid graph label type for N-Quads serialization: ${graphLabel.runtimeType}. Must be IRITerm or BlankNode.');
      }
      final graphLabelStr = _encoder._formatTerm(graphLabel);

      for (final triple in graph.triples) {
        final subjStr = _encoder._formatTerm(triple.subject);
        final predStr = _encoder._formatTerm(triple.predicate);
        final objStr = _encoder._formatTerm(triple.object);
        buffer.write('$subjStr $predStr $objStr $graphLabelStr .\n');
      }
    });

    // Add the formatted string chunk to the output sink if it's not empty
    if (buffer.isNotEmpty) {
        _outSink.add(buffer.toString());
    }
  }

  @override
  void close() {
    _outSink.close();
  }
}
