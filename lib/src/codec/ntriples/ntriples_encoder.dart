import 'dart:convert';

import 'package:rdf_dart/rdf_dart.dart';

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
        return _formatIri((term as IRITerm).value);
      case TermType.blankNode:
        return _formatBlankNode(term as BlankNode);
      case TermType.literal:
        return _formatLiteral(term as Literal);
      case TermType.tripleTerm:
        return _formatTripleTerm(term as TripleTerm);
    }
  }

  /// Formats an IRI according to N-Triples IRIREF rules.
  /// IRIREF ::= '<' ([^#x00-#x20<>"{}|^`\] | UCHAR)* '>'
  String _formatIri(IRI iri) {
    // Use the IRI's own toString method.
    final iriString = iri.toString();
    final sb = StringBuffer('<');
    // Escape characters: U+00-U+20, <, >, ", {, }, |, ^, `, \
    for (final rune in iriString.runes) {
      if ((rune >= 0x00 && rune <= 0x20) || // Control characters U+00 to U+20
          rune == 0x3C || // <
          rune == 0x3E || // >
          rune == 0x22 || // "
          rune == 0x7B || // {
          rune == 0x7D || // }
          rune == 0x7C || // |
          rune == 0x5E || // ^
          rune == 0x60 || // `
          rune == 0x5C) {
        // \
        sb.write(_escapeRune(rune)); // Use UCHAR escape (\uXXXX or \UXXXXXXXX)
      } else {
        sb.writeCharCode(rune); // Append allowed character directly
      }
    }
    sb.write('>');
    return sb.toString();
  }

  /// Formats a BlankNode according to N-Triples BLANK_NODE_LABEL rules.
  /// BLANK_NODE_LABEL ::= '_:'
  String _formatBlankNode(BlankNode bnode) {
    // TODO: N-Triples blank node labels have syntax constraints (PN_CHARS_U, etc.).
    // Confirm the BlankNode.id provided adheres to these or is suitable.
    return '_:${bnode.id}';
  }

  /// Formats a Literal according to N-Triples literal rules.
  /// literal ::= STRING_LITERAL_QUOTE ('^^' IRIREF | LANG_DIR )?
  String _formatLiteral(Literal literal) {
    final sb = StringBuffer();
    sb.write('"'); // Start delimiter for STRING_LITERAL_QUOTE

    // Escape lexical form according to STRING_LITERAL_QUOTE rules
    // Spec section 2.4 mandates escaping: ", \, LF, CR
    // We use ECHAR where possible (\n, \r, \", \\, \t) and UCHAR otherwise.
    final lexical = literal.lexicalForm;
    for (final rune in lexical.runes) {
      switch (rune) {
        case 0x22: // " Quotation mark
          sb.write(r'\"');
        case 0x5C: // \ Backslash
          sb.write(r'\\');
        case 0x0A: // Line Feed
          sb.write(r'\n');
        case 0x0D: // Carriage Return
          sb.write(r'\r');
        case 0x09: // Tab (Optional ECHAR, good practice)
          sb.write(r'\t');
        case 0x08: // Backspace (BS)
          sb.write(r'\b');
        case 0x0C: // Form Feed (FF)
          sb.write(r'\f');
        default:
          // Use UCHAR for other control characters (U+00-U+1F, excluding \t, \n, \r) and DEL (U+7F)
          if ((rune >= 0x00 && rune <= 0x08) ||
              rune == 0x0B || // Vertical Tab
              (rune >= 0x0E && rune <= 0x1F) ||
              rune == 0x7F) {
            sb.write(_escapeRune(rune));
          } else {
            // Append other characters directly
            sb.writeCharCode(rune);
          }
      }
    }
    sb.write('"'); // End delimiter

    // Append language tag/direction or datatype IRI
    if (literal.language != null) {
      sb.write('@');
      sb.write(literal.language!.toLanguageTag()); // BCP47 format
      if (literal.baseDirection != null) {
        // RDF 1.2 feature
        // LANG_DIR
        sb.write('--');
        sb.write(literal.baseDirection == TextDirection.ltr ? 'ltr' : 'rtl');
      }
      // Datatype for language-tagged strings is implicitly rdf:langString or rdf:dirLangString
      // and MUST NOT be written explicitly according to RDF Concepts/N-Triples.
    } else if (literal.datatype != XSD.string) {
      // Datatype is not xsd:string and no language tag exists.
      // Append ^^<datatypeIRI>
      // Spec Section 2.4: Simple literals (xsd:string) written without ^^
      sb.write('^^');
      sb.write(_formatIri(literal.datatype)); // Reuse IRI formatting
    }
    // If datatype is xsd:string and no language tag, nothing is appended after the quotes.

    return sb.toString();
  }

  /// Formats a TripleTerm according to N-Triples tripleTerm rules.
  /// tripleTerm ::= '<<(' subject predicate object ')>>'
  String _formatTripleTerm(TripleTerm term) {
    // Recursively format the inner triple's terms
    final subjStr = _formatTerm(term.triple.subject); // [cite: 14]
    final predStr = _formatTerm(term.triple.predicate);
    final objStr = _formatTerm(term.triple.object);
    // Include spaces for readability
    return '<<( $subjStr $predStr $objStr )>>';
  }

  /// Helper to create UCHAR escape sequences (\uXXXX or \UXXXXXXXX).
  /// UCHAR ::= ('\u' HEX{4}) | ('\U' HEX{8})
  String _escapeRune(int rune) {
    if (rune <= 0xFFFF) {
      // Use \u for BMP characters
      return '\\u${rune.toRadixString(16).toUpperCase().padLeft(4, '0')}';
    } else {
      // Use \U for characters outside BMP
      return '\\U${rune.toRadixString(16).toUpperCase().padLeft(8, '0')}';
    }
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