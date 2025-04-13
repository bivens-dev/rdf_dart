import 'dart:collection';
import 'dart:convert';

import 'package:rdf_dart/rdf_dart.dart';

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
  List<Triple> convert(String input) {
    final result = <Triple>[];
    // Use the chunked conversion mechanism for the non-streaming case.
    // Create a sink that collects triples into the 'result' list.
    final collectingSink = ChunkedConversionSink<List<Triple>>.withCallback((
      tripleLists,
    ) {
      for (final list in tripleLists) {
        result.addAll(list);
      }
    });

    // Start the chunked conversion
    final conversionSink = startChunkedConversion(collectingSink);

    // Add the entire input as a single chunk
    conversionSink.add(input);

    // Close the conversion sink to finalize processing
    conversionSink.close();

    return result;
  }

  @override
  ChunkedConversionSink<String> startChunkedConversion(
    Sink<List<Triple>> sink,
  ) {
    return _NTriplesDecoderSink(sink);
  }
}

/// Internal stateful sink for streaming N-Triples decoding.
class _NTriplesDecoderSink implements ChunkedConversionSink<String> {
  /// The output sink receiving lists of parsed triples.
  final Sink<List<Triple>> _outSink;

  /// Buffer for incomplete lines received across chunks.
  final StringBuffer _buffer = StringBuffer();

  /// Map to store and reuse BlankNode instances based on their labels
  /// within the scope of this conversion instance.
  final Map<String, BlankNode> _bnodeLabels = HashMap<String, BlankNode>();

  /// Current line number for error reporting.
  int _lineNumber = 0;

  /// Flag indicating if the input stream has been closed.
  bool _isClosed = false;

  /// RegExp to find line endings (handles \n and \r\n).
  static final RegExp _lineEndRegExp = RegExp(r'\r?\n');

  _NTriplesDecoderSink(this._outSink);

  @override
  void add(String chunk) {
    if (_isClosed) {
      // As per Sink contract, throwing if add is called after close.
      throw StateError('Cannot add to a closed sink.');
    }
    _buffer.write(chunk);
    _processBuffer();
  }

  @override
  void close() {
    if (_isClosed) {
      return; // Allow closing multiple times idempotently.
    }
    _isClosed = true;
    // Process any remaining content in the buffer as the final line.
    final remaining = _buffer.toString();
    if (remaining.isNotEmpty) {
      _processLine(remaining, isFinal: true);
    }
    // Close the output sink regardless of remaining content.
    _outSink.close();
  }

  /// Processes the internal buffer, extracting and parsing complete lines.
  void _processBuffer() {
    var currentBuffer = _buffer.toString();
    var searchStart = 0;

    while (true) {
      // Find the next line ending in the current buffer content
      final match = _lineEndRegExp.firstMatch(
        currentBuffer.substring(searchStart),
      );

      if (match == null) {
        // No more complete lines found in the current buffer.
        // Remove the processed part from the buffer.
        if (searchStart > 0) {
          _buffer.clear();
          _buffer.write(currentBuffer.substring(searchStart));
        }
        break; // Exit the loop, wait for more data or close()
      }

      // Calculate the end position of the line (excluding the terminator)
      final lineEnd = searchStart + match.start;
      // Extract the complete line
      final line = currentBuffer.substring(searchStart, lineEnd);

      // Process the extracted line
      _processLine(line);

      // Update the search start position to after the line terminator
      searchStart = searchStart + match.end;

      // If we've processed the entire buffer content analyzed so far
      if (searchStart >= currentBuffer.length) {
        _buffer.clear(); // Clear buffer as all content was processed
        break; // Exit loop
      }
    }
  }

  /// Processes a single extracted line.
  /// Increments line number, trims whitespace, checks for comments/blanks,
  /// and calls the main parsing logic.
  /// If [isFinal] is true, treats the line as the very last input segment.
  void _processLine(String line, {bool isFinal = false}) {
    _lineNumber++;
    final trimmedLine = line.trim(); // Remove leading/trailing whitespace

    if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
      // Ignore blank lines and comments (N-Triples Spec Section 5.1, 5.2)
      return;
    }

    try {
      // Call the main parsing function for the line content
      final triple = _parseTripleLine(trimmedLine, _lineNumber);
      // If successful, add the triple (in a list) to the output sink
      _outSink.add([triple]);
    } catch (e) {
      // If parsing fails, propagate the error (e.g., ParseError)
      // TODO: Consider adding error to sink instead? For now, let it throw.
      // _outSink.addError(e, StackTrace.current); // Alternative
      rethrow; // Re-throw the caught error (likely ParseError)
    }
  }

  /// Parses a non-empty, non-comment line into an RDF Triple.
  /// Throws [ParseError] if the line does not conform to N-Triples syntax.
  /// (Implementation Stub - This is where the core parsing logic will go)
  Triple _parseTripleLine(String line, int lineNumber) {
    // TODO: Implement the detailed parsing logic for:
    // 1. Tokenizing the line (subject, predicate, object, final '.')
    // 2. Handling whitespace between tokens (at least one required)
    // 3. Calling specific term parsers (_parseSubject, _parsePredicate, _parseObject)
    // 4. Validating the final '.'
    // 5. Using the _bnodeLabels map for blank nodes
    // 6. Throwing ParseError with line/column info on failure.

    throw UnimplementedError('N-Triples line parsing not yet implemented.');
  }

  // TODO: Add helper methods for parsing terms:
  // SubjectTerm _parseSubject(String token, int line, int col) { ... }
  // IRITerm _parsePredicate(String token, int line, int col) { ... }
  // RdfTerm _parseObject(String token, int line, int col) { ... }
  // RdfTerm _parseTerm(String token, int line, int col) { ... } // General dispatcher
  // IRI _parseIri(String token, int line, int col) { ... }
  // BlankNode _parseBlankNode(String token, int line, int col) { ... } // Uses _bnodeLabels
  // Literal _parseLiteral(String token, int line, int col) { ... } // Handles escapes, lang, dir, type
  // TripleTerm _parseTripleTerm(String token, int line, int col) { ... } // Recursive call
  // String _unescape(String input) { ... } // Handles \u, \U, \t, \n, etc.
}
