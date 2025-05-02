import 'dart:convert';

import 'package:rdf_dart/src/codec/n_formats/n_formats_serializer_utils.dart';
import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/iri_term.dart';
import 'package:rdf_dart/src/model/literal.dart';
import 'package:rdf_dart/src/model/rdf_term.dart';
import 'package:rdf_dart/src/model/term_type.dart';
import 'package:rdf_dart/src/model/triple.dart';
import 'package:rdf_dart/src/model/triple_term.dart';

/// Converts a `List<Triple>` to its N-Triples string representation.
///
/// Follows the RDF 1.2 N-Triples specification for formatting terms and triples.
/// https://www.w3.org/TR/rdf12-n-triples/ [cite: 1]
class NTriplesEncoder extends Converter<List<Triple>, String> {
  const NTriplesEncoder();

  @override
  String convert(List<Triple> input) {
    // Handle empty list case
    if (input.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      buffer.write(_formatTriple(input[i]));
      // Add newline after each triple (including the last one)
      // N-Triples spec grammar EOL is optional at the end,
      // but canonical form requires it, and it's common practice.
      buffer.write('\n');
    }
    return buffer.toString();
  }

  /// Starts a chunked conversion.
  ///
  /// The converter consumes lists of [Triple] objects and outputs multi-line
  /// N-Triples [String] chunks.
  @override
  ChunkedConversionSink<List<Triple>> startChunkedConversion(
    Sink<String> sink,
  ) {
    // Return the specialized sink that handles the chunked logic.
    return _NTriplesEncoderSink(sink, this);
  }

  /// Formats a single Triple according to N-Triples syntax.
  /// triple ::= subject predicate object '.'
  String _formatTriple(Triple triple) {
    final subjStr = _formatTerm(triple.subject);
    final predStr = _formatTerm(triple.predicate); // Predicate must be IRI
    final objStr = _formatTerm(triple.object);
    // Add required whitespace between terms and the final ' .'
    return '$subjStr $predStr $objStr .';
  }

  /// Formats any RdfTerm into its N-Triples string representation.
  String _formatTerm(RdfTerm term) {
    switch (term.termType) {
      case TermType.iri:
        return NFormatsSerializerUtils.formatIri((term as IRINode).value);
      case TermType.blankNode:
        return NFormatsSerializerUtils.formatBlankNode(term as BlankNode);
      case TermType.literal:
        return NFormatsSerializerUtils.formatLiteral(term as Literal);
      case TermType.tripleTerm:
        return _formatTripleTerm(term as TripleTerm);
    }
  }

  /// Formats a TripleTerm according to N-Triples tripleTerm rules.
  /// tripleTerm ::= '<<(' subject predicate object ')>>'
  String _formatTripleTerm(TripleTerm term) {
    // Recursively format the inner triple's terms
    final subjStr = _formatTerm(term.triple.subject);
    final predStr = _formatTerm(term.triple.predicate);
    final objStr = _formatTerm(term.triple.object);
    // Include spaces for readability
    return '<<( $subjStr $predStr $objStr )>>';
  }
}

/// Internal sink implementation for chunked N-Triples encoding.
class _NTriplesEncoderSink implements ChunkedConversionSink<List<Triple>> {
  /// The output sink receiving the formatted N-Triples strings.
  final Sink<String> _outSink;

  /// Reference to the encoder to access formatting helpers.
  final NTriplesEncoder _encoder;

  _NTriplesEncoderSink(this._outSink, this._encoder);

  /// Processes a chunk of triples.
  ///
  /// Each triple in the chunk is formatted and added to the output sink,
  /// followed by a newline.
  @override
  void add(List<Triple> chunk) {
    // Avoid processing if the chunk is empty.
    if (chunk.isEmpty) return;

    final buffer = StringBuffer();
    for (var i = 0; i < chunk.length; i++) {
      // Use the encoder's helper method to format the triple.
      buffer.write(_encoder._formatTriple(chunk[i]));
      // Append a newline after each triple string.
      buffer.write('\n');
    }
    // Add the formatted string chunk to the output sink.
    _outSink.add(buffer.toString());
  }

  /// Closes the underlying output sink.
  ///
  /// This indicates that no more chunks will be added.
  @override
  void close() {
    _outSink.close();
  }
}
