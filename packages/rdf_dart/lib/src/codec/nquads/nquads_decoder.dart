import 'dart:collection';
import 'dart:convert';

import 'package:iri/iri.dart';
import 'package:rdf_dart/src/codec/n_formats/n_formats_parser_utils.dart';
import 'package:rdf_dart/src/codec/n_formats/parse_error.dart';
import 'package:rdf_dart/src/exceptions/invalid_language_tag_exception.dart';
import 'package:rdf_dart/src/exceptions/invalid_lexical_form_exception.dart';
import 'package:rdf_dart/src/exceptions/literal_constraint_exception.dart';
import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/dataset.dart';
import 'package:rdf_dart/src/model/graph.dart';
import 'package:rdf_dart/src/model/iri_term.dart';
import 'package:rdf_dart/src/model/literal.dart';
import 'package:rdf_dart/src/model/rdf_term.dart';
import 'package:rdf_dart/src/model/subject_type.dart';
import 'package:rdf_dart/src/model/triple.dart';
import 'package:rdf_dart/src/model/triple_term.dart';
import 'package:rdf_dart/src/vocab/rdf_vocab.dart';
import 'package:rdf_dart/src/vocab/xsd_vocab.dart';

/// Converts an N-Quads string representation into an RDF [Dataset].
///
/// This decoder handles parsing N-Quads documents according to the
/// RDF 1.2 N-Quads specification: https://www.w3.org/TR/rdf12-n-quads/
/// It supports both non-streaming conversion via [convert] and streaming
/// conversion using [startChunkedConversion].
///
/// It correctly parses IRIs, blank nodes, literals (including language tags
/// with optional direction and datatypes), and RDF-star triple terms in the
/// object position. Quads are added to the appropriate graph (default or named)
/// within the resulting [Dataset].
class NQuadsDecoder extends Converter<String, Dataset> {
  /// Creates an N-Quads decoder instance.
  const NQuadsDecoder();

  /// Converts the entire [input] N-Quads string into a single [Dataset].
  ///
  /// This is suitable for smaller inputs that can fit comfortably in memory.
  /// For larger inputs, consider using [startChunkedConversion] for streaming.
  @override
  Dataset convert(String input) {
    // Sink that does nothing, just fulfills the type requirement for startChunkedConversion.
    // We get the result directly from the worker sink instance itself.
    const discardingSink = _DatasetDiscardingSink();
    // Create the worker sink instance
    final workerSink =
        startChunkedConversion(discardingSink)
            as _NQuadsDecoderSink; // Cast needed

    workerSink.add(input);
    workerSink.close(); // This populates workerSink._dataset internally

    // Return the dataset built internally by the worker sink
    return workerSink._dataset;
  }

  /// Starts a chunked conversion for streaming N-Quads decoding.
  ///
  /// Input chunks (strings) are provided via the returned [ChunkedConversionSink].
  /// The resulting complete [Dataset] will be added to the provided [sink]
  /// exactly once when the input stream sink is closed.
  @override
  ChunkedConversionSink<String> startChunkedConversion(Sink<Dataset> sink) {
    // The sink will typically only add once to the output sink on close.
    // Or, maybe the Sink should be Sink<Quad>? Let's stick to Sink<Dataset> for now.
    return _NQuadsDecoderSink(sink);
  }
}

/// Helper sink for the non-streaming [NQuadsDecoder.convert] method
/// where the output sink is ignored because the result is obtained directly
/// from the [_NQuadsDecoderSink] instance.
class _DatasetDiscardingSink implements Sink<Dataset> {
  const _DatasetDiscardingSink(); // Added const constructor
  @override
  void add(Dataset data) {} // Do nothing
  @override
  void close() {} // Do nothing
}

/// Internal stateful sink for streaming N-Quads decoding.
///
/// This sink processes chunks of N-Quads strings, parses lines into quads
/// (or triples for the default graph), builds a [Dataset] internally,
/// and emits the complete dataset to the output sink upon closing.
class _NQuadsDecoderSink implements ChunkedConversionSink<String> {
  /// The output sink that receives the final parsed [Dataset].
  final Sink<Dataset> _outSink;

  /// Buffer for incomplete lines received across chunks.
  final StringBuffer _buffer = StringBuffer();

  /// The [Dataset] being built internally during the parsing process.
  final Dataset _dataset = Dataset();

  /// Map to store and reuse [BlankNode] instances based on their labels
  /// within the scope of this single conversion instance (stream).
  final Map<String, BlankNode> _bnodeLabels = HashMap<String, BlankNode>();

  /// Current line number for error reporting.
  int _lineNumber = 0;

  /// Flag indicating if the input stream has been closed.
  bool _isClosed = false;

  /// Current 0-based cursor position within the *current line* being parsed.
  int _cursor = 0;

  /// RegExp to find line endings (handles \n and \r\n).
  static final RegExp _lineEndRegExp = RegExp(r'\r?\n');

  /// Creates a sink that sends its final [Dataset] result to [_outSink].
  _NQuadsDecoderSink(this._outSink);

  /// Adds a chunk of N-Quads string data to be decoded.
  ///
  /// Throws [StateError] if [close] has already been called.
  @override
  void add(String chunk) {
    if (_isClosed) {
      // As per Sink contract, throwing if add is called after close.
      throw StateError('Cannot add to a closed sink.');
    }
    _buffer.write(chunk);
    _processBuffer();
  }

  /// Finalizes the decoding process.
  ///
  /// Processes any remaining buffered data, adds the completed [Dataset]
  /// to the output sink, and closes the output sink.
  @override
  void close() {
    if (_isClosed) {
      return;
    }
    _isClosed = true;
    final remaining = _buffer.toString();
    // Treat remaining buffer content as the final line, even without terminator
    if (remaining.isNotEmpty) {
      // Process final line, trim whitespace here as it wasn't extracted via line ending
      _processLine(remaining.trim(), isFinal: true);
    } else if (remaining.isNotEmpty && remaining.trim().isEmpty) {
      // If buffer only contained whitespace, increment line number for consistency
      _lineNumber++;
    }
    // Ensure buffer is cleared after processing or if it was effectively empty
    _buffer.clear();
    // Add the complete dataset to the output sink before closing it
    _outSink.add(_dataset);
    _outSink.close();
  }

  /// Processes the internal [_buffer], extracting and parsing complete lines.
  void _processBuffer() {
    // Use a temporary string for processing to avoid issues with modifying
    // the buffer while iterating using indices based on the original string.
    final currentContent = _buffer.toString();
    var processedLength = 0; // Track how much of currentContent we've processed

    while (true) {
      // Find the next line ending from the current processing point
      final match = _lineEndRegExp.firstMatch(
        currentContent.substring(processedLength),
      );

      if (match == null) {
        // No more complete lines found.
        // Update the main buffer by removing the part we already processed.
        if (processedLength > 0) {
          _buffer.clear();
          _buffer.write(currentContent.substring(processedLength));
        }
        break; // Wait for more data or close()
      }

      // Calculate the start and end of the line within currentContent
      final lineStart = processedLength;
      final lineEnd = processedLength + match.start;
      // Extract the complete line (excluding the terminator)
      final line = currentContent.substring(lineStart, lineEnd);

      // Process the extracted line
      _processLine(line);

      // Update the total processed length to after the line terminator
      processedLength += match.end;

      // Optimization: If we've processed everything, clear buffer and exit early
      if (processedLength == currentContent.length) {
        _buffer.clear();
        break;
      }
    }
  }

  /// Processes a single extracted line.
  ///
  /// Increments line number, trims whitespace, ignores comments or blank lines,
  /// and calls the main quad parsing logic ([_parseQuadLine]).
  /// If [isFinal] is true, treats the line as the very last input segment
  /// (though this currently has no effect on parsing logic).
  void _processLine(String line, {bool isFinal = false}) {
    _lineNumber++;
    final trimmedLine = line.trim();

    // Ignore blank lines and comment lines
    if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
      return;
    }

    try {
      // Parse the line; result is added to internal _dataset
      _parseQuadLine(trimmedLine, _lineNumber);
    } on ParseError catch (_) {
      // Let ParseErrors thrown by the parsing logic propagate directly.
      rethrow;
    } catch (e, s) {
      // Catch stack trace for better internal debugging
      // Wrap other *unexpected* errors in a ParseError for context.
      // Use _cursor, but it might not be perfectly accurate if the error
      // happened outside the main parsing flow initiated by _parseTripleLine.
      // Provide a best-effort column number.
      final column = _cursor + 1; // Best guess at error location
      throw ParseError(
        'Internal error parsing line $_lineNumber near column $column: $e\n$s',
        _lineNumber,
        column,
      );
    }
  }

  /// Parses a non-empty, non-comment N-Quads line.
  ///
  /// Parses subject, predicate, object, and optionally a graph label,
  /// validates the terminating dot, and adds the resulting triple to the
  /// appropriate graph (default or named) in the internal [_dataset].
  /// Throws [ParseError] if the line does not conform to N-Quads syntax.
  void _parseQuadLine(String line, int lineNumber) {
    // Reset cursor for this line
    _cursor = 0;

    // 1. Parse Subject
    final subject = _parseSubject(line, lineNumber);
    _cursor = NFormatsParserUtils.skipOptionalWhitespace(line, _cursor);

    // 2. Parse Predicate
    final predicate = _parsePredicate(line, lineNumber);
    _cursor = NFormatsParserUtils.skipOptionalWhitespace(line, _cursor);

    // 3. Parse Object
    final object = _parseObject(line, lineNumber);
    _cursor = NFormatsParserUtils.skipOptionalWhitespace(line, _cursor);

    // 4. Parse Optional Graph Label
    SubjectTerm?
    graphLabel; // Use SubjectTerm as graph can be IRINode or BlankNode
    if (_cursor < line.length && line[_cursor] != '.') {
      // Check if it looks like a valid start for a graph label term
      if (line[_cursor] == '<' || line[_cursor] == '_') {
        graphLabel = _parseSubject(
          line,
          lineNumber,
        ); // Re-use subject parsing logic
        _cursor = NFormatsParserUtils.skipOptionalWhitespace(line, _cursor);
      } else {
        // If it's not '.' and not '<' or '_', it's invalid syntax before the dot
        throw ParseError(
          'Expected graph label (IRI or Blank Node) or final dot (.)',
          lineNumber,
          _cursor + 1,
        );
      }
    }

    // 5. Validate the final dot
    if (_cursor >= line.length || line[_cursor] != '.') {
      throw ParseError('Expected final dot (.)', lineNumber, _cursor + 1);
    }
    _cursor++; // Consume the dot
    _cursor = NFormatsParserUtils.skipOptionalWhitespace(line, _cursor);

    // 6. Ensure No Trailing Characters (besides comments)
    if (_cursor < line.length && line[_cursor] != '#') {
      // Corrected: message, lineNumber, columnNumber
      throw ParseError(
        'Unexpected characters after final dot (.)',
        lineNumber,
        _cursor + 1,
      );
    }

    // 7. Construct Triple and Add to Dataset
    final triple = Triple(subject, predicate, object);
    if (graphLabel != null) {
      // Add to named graph (create if needed)
      final namedGraph = _dataset.namedGraphs.putIfAbsent(
        graphLabel,
        Graph.new,
      );
      // Add the Triple to the named graph
      namedGraph.add(triple);
    } else {
      // Add to default graph
      _dataset.defaultGraph.add(triple);
    }
  }

  // --- Term Parsing Orchestrators ---
  // These methods remain in the sink to handle context-specific logic
  // (e.g., which term types are allowed, BNode caching, Literal construction)
  // and call the static NFormatsParserUtils for the actual syntax parsing.

  /// Parses an N-Quads subject term (IRI or Blank Node) at the current cursor
  /// position and updates the sink's cursor.
  SubjectTerm _parseSubject(String line, int lineNumber) {
    final startCol = _cursor + 1;
    NFormatsParserUtils.checkNotEof(
      line,
      _cursor,
      lineNumber,
      'subject',
      startCol,
    );
    final char = line[_cursor];
    if (char == '<') {
      // --- IRI Path ---
      final iriResult = NFormatsParserUtils.parseIri(line, _cursor, lineNumber);
      // Update the sink's cursor
      _cursor = iriResult.cursor;
      // Use the term from the result
      final iriNode = iriResult.term;
      // N-Triples/N-Quads require absolute IRIs for subject
      if (iriNode.value.hasScheme) {
        return iriNode;
      } else {
        throw ParseError(
          'Relative IRI <${iriNode.value}> not allowed as subject (absolute IRI required)',
          lineNumber,
          startCol,
        );
      }
    } else if (char == '_' &&
        _cursor + 1 < line.length &&
        line[_cursor + 1] == ':') {
      // --- Blank Node Path ---
      final bnodeResult = NFormatsParserUtils.parseBlankNodeLabel(
        line,
        _cursor,
        lineNumber,
      );
      _cursor = bnodeResult.cursor;
      final label = bnodeResult.label;
      // Return from cache or create/add/return new BlankNode
      return _bnodeLabels.putIfAbsent(label, () => BlankNode(label));
    } else {
      throw ParseError(
        'Expected IRI or Blank Node to start subject',
        lineNumber,
        startCol,
      );
    }
  }

  /// Parses an N-Quads predicate term (IRI) at the current cursor position
  /// and updates the sink's cursor.
  IRINode _parsePredicate(String line, int lineNumber) {
    final startCol = _cursor + 1;
    NFormatsParserUtils.checkNotEof(
      line,
      _cursor,
      lineNumber,
      'predicate',
      startCol,
    );
    if (line[_cursor] == '<') {
      final iriResult = NFormatsParserUtils.parseIri(line, _cursor, lineNumber);
      // Update the sink's cursor from the result record
      _cursor = iriResult.cursor;
      final iriNode = iriResult.term;
      // N-Triples/N-Quads require absolute IRIs for predicate
      if (iriNode.value.hasScheme) {
        return iriNode;
      } else {
        throw ParseError(
          'Relative IRI <${iriNode.value}> not allowed as predicate (absolute IRI required)',
          lineNumber,
          startCol, // Error relates to the start of the term
        );
      }
    } else {
      throw ParseError('Expected IRI to start predicate', lineNumber, startCol);
    }
  }

  /// Parses an N-Quads object term (IRI, Blank Node, Literal, or Triple Term)
  /// at the current cursor position and updates the sink's cursor.
  RdfTerm _parseObject(String line, int lineNumber) {
    final startCol = _cursor + 1;
    NFormatsParserUtils.checkNotEof(
      line,
      _cursor,
      lineNumber,
      'object',
      startCol,
    );
    final char = line[_cursor];
    if (char == '<') {
      // --- IRI or Triple Term Path ---
      // Look ahead more carefully
      if (_cursor + 2 < line.length && line.startsWith('<<(', _cursor)) {
        // Check for '<<( '
        return _parseTripleTerm(line, lineNumber);
      } else {
        // --- IRI Path ---
        final iriResult = NFormatsParserUtils.parseIri(
          line,
          _cursor,
          lineNumber,
        );
        // Update the sink's cursor
        _cursor = iriResult.cursor;
        // Use the term from the result
        final iriNode = iriResult.term;
        // N-Triples/N-Quads require absolute IRIs for object
        if (iriNode.value.hasScheme) {
          return iriNode;
        } else {
          throw ParseError(
            'Relative IRI <${iriNode.value}> not allowed as object (absolute IRI required)',
            lineNumber,
            startCol, // Error relates to the start of the term
          );
        }
      }
    } else if (char == '_' &&
        _cursor + 1 < line.length &&
        line[_cursor + 1] == ':') {
      // --- Blank Node Path ---
      final bnodeResult = NFormatsParserUtils.parseBlankNodeLabel(
        line,
        _cursor,
        lineNumber,
      );
      _cursor = bnodeResult.cursor;
      final label = bnodeResult.label;
      // Return from cache or create/add/return new BlankNode
      return _bnodeLabels.putIfAbsent(label, () => BlankNode(label));
    } else if (char == '"') {
      // --- Literal Path ---
      final literalResult = NFormatsParserUtils.parseLiteralComponents(
        line,
        _cursor,
        lineNumber,
      );
      _cursor = literalResult.cursor;

      // Construct Literal object here, handling defaults and exceptions
      final IRI datatypeForConstructor;
      if (literalResult.languageTag != null) {
        // If language tag is present, datatype MUST be rdf:langString
        datatypeForConstructor = RDF.langString;
      } else {
        // Otherwise, use the parsed datatype, or default to xsd:string
        datatypeForConstructor = literalResult.datatypeIri ?? XSD.string;
      }

      // Calculate language tag start column for potential errors (same logic as original _parseLiteral)
      int? languageTagStartCol;
      if (literalResult.languageTag != null) {
        // Find the '@' before the current cursor
        final atPos = line.lastIndexOf('@', _cursor);
        if (atPos != -1 && atPos > startCol) {
          // Ensure '@' is after term start
          languageTagStartCol = atPos + 2;
        } else {
          languageTagStartCol = startCol; // Fallback
        }
      }
      // Column where the literal content started (after opening quote)
      // We need to calculate this based on where the literal started.
      // startCol is the position of '"', so content starts at startCol + 1
      final contentStartCol = startCol + 1;

      // Construct the Literal - include the original try/catch block
      try {
        return Literal(
          literalResult.lexicalForm,
          datatypeForConstructor, // Use determined datatype
          literalResult.languageTag,
          literalResult.direction,
        );
      } on LiteralConstraintException catch (e) {
        throw ParseError('Invalid literal arguments: $e', lineNumber, startCol);
      } on InvalidLexicalFormException catch (e) {
        throw ParseError(
          'Invalid lexical form for datatype ${e.datatypeIri}: "${e.lexicalForm}" ($e)',
          lineNumber,
          contentStartCol,
        );
      } on InvalidLanguageTagException catch (e) {
        throw ParseError(
          'Invalid language tag: "${e.languageTag}" ($e)',
          lineNumber,
          languageTagStartCol ?? startCol,
        );
      } catch (e, s) {
        // Catch other potential errors during Literal creation
        throw ParseError(
          'Internal error creating literal: $e\n$s',
          lineNumber,
          startCol,
        );
      }
    } else {
      throw ParseError(
        'Expected IRI, Blank Node, Literal or Triple Term to start object',
        lineNumber,
        startCol,
      );
    }
  }

  /// Parses an N-Triples Triple Term at the current cursor position.
  /// Assumes the cursor points to the starting '<' of '<<('.
  /// Updates the cursor past the closing ')>>'.
  /// Throws [ParseError] on syntax violations.
  TripleTerm _parseTripleTerm(String line, int lineNumber) {
    final startCol = _cursor + 1; // 1-based column for error reporting

    // Check for starting '<<(' - defensive, usually handled by _parseObject lookahead
    if (_cursor + 2 >= line.length || !line.startsWith('<<(', _cursor)) {
      throw ParseError(
        "Internal Error: Expected Triple Term to start with '<<('",
        lineNumber,
        startCol,
      );
    }
    _cursor += 3; // Consume '<<('

    _cursor = NFormatsParserUtils.skipOptionalWhitespace(
      line,
      _cursor,
    ); // Allow whitespace after '<<('

    // --- Parse inner triple components recursively ---
    // These calls will update the _cursor internally

    // 1. Parse Inner Subject
    final subject = _parseSubject(line, lineNumber);
    _cursor = NFormatsParserUtils.skipOptionalWhitespace(line, _cursor);

    // 2. Parse Inner Predicate
    final predicate = _parsePredicate(line, lineNumber);
    _cursor = NFormatsParserUtils.skipOptionalWhitespace(
      line,
      _cursor,
    ); // Require whitespace after inner predicate

    // 3. Parse Inner Object
    final object = _parseObject(line, lineNumber);

    // --- End of inner triple components ---

    _cursor = NFormatsParserUtils.skipOptionalWhitespace(
      line,
      _cursor,
    ); // Allow whitespace before closing ')>>'

    // Check for closing ')>>'
    final closingMarkStartCol = _cursor + 1;
    if (_cursor + 2 >= line.length || !line.startsWith(')>>', _cursor)) {
      throw ParseError(
        "Expected Triple Term to end with ')>>'",
        lineNumber,
        closingMarkStartCol,
      );
    }
    _cursor += 3; // Consume ')>>'

    // Construct the inner Triple and wrap it in a TripleTerm
    final innerTriple = Triple(subject, predicate, object);
    return TripleTerm(innerTriple);
  }
}
