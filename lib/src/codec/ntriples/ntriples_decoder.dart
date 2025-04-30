import 'dart:collection';
import 'dart:convert';

import 'package:rdf_dart/src/blank_node.dart';
import 'package:rdf_dart/src/codec/n_formats/n_formats_parser_utils.dart';
import 'package:rdf_dart/src/codec/n_formats/parse_error.dart';
import 'package:rdf_dart/src/exceptions.dart';
import 'package:rdf_dart/src/iri.dart';
import 'package:rdf_dart/src/iri_term.dart';
import 'package:rdf_dart/src/literal.dart';
import 'package:rdf_dart/src/rdf_term.dart';
import 'package:rdf_dart/src/subject_type.dart';
import 'package:rdf_dart/src/triple.dart';
import 'package:rdf_dart/src/triple_term.dart';
import 'package:rdf_dart/src/vocab/rdf_vocab.dart';
import 'package:rdf_dart/src/vocab/xsd_vocab.dart';

/// Converts an N-Triples string representation into a `List<Triple>`.
///
/// Supports streaming decoding via `startChunkedConversion`.
/// Follows the RDF 1.2 N-Triples specification:
/// https://www.w3.org/TR/rdf12-n-triples/
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

  int _cursor = 0;

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

    _outSink.close();
  }

  /// Processes the internal buffer, extracting and parsing complete lines.
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
  /// Increments line number, trims whitespace, checks for comments/blanks,
  /// and calls the main parsing logic.
  /// If [isFinal] is true, treats the line as the very last input segment.
  void _processLine(String line, {bool isFinal = false}) {
    _lineNumber++;
    final trimmedLine = line.trim();

    if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
      return;
    }

    // Reset cursor conceptually before parsing the line
    // (Actual reset happens in _parseTripleLine)

    try {
      final triple = _parseTripleLine(trimmedLine, _lineNumber);
      _outSink.add([triple]);
    } on ParseError catch (_) {
      // Let ParseErrors thrown by the parsing logic propagate directly.
      rethrow;
    } catch (e) {
      // Wrap other *unexpected* errors in a ParseError for context.
      // Use _cursor, but it might not be perfectly accurate if the error
      // happened outside the main parsing flow initiated by _parseTripleLine.
      // Provide a best-effort column number.
      final column = _cursor + 1; // Best guess at error location
      throw ParseError(
        'Internal error parsing line $_lineNumber near column $column: $e',
        _lineNumber,
        column,
      );
    }
  }

  /// Parses a non-empty, non-comment line into an RDF Triple.
  /// Throws [ParseError] if the line does not conform to N-Triples syntax.
  /// (Implementation Stub - This is where the core parsing logic will go)
  Triple _parseTripleLine(String line, int lineNumber) {
    // Reset cursor for this line
    _cursor = 0;

    // 1. Parse Subject
    final subject = _parseSubject(line, lineNumber);
    _cursor = NFormatsParserUtils.skipOptionalWhitespace(line, _cursor);

    // 2. Parse Predicate
    final predicate = _parsePredicate(line, lineNumber);
    _cursor = NFormatsParserUtils.skipOptionalWhitespace(line, _cursor);

    // 3. Parse Object - it extends to the final '.'
    final object = _parseObject(line, lineNumber);

    // 4. Skip optional whitespace before the final dot
    _cursor = NFormatsParserUtils.skipOptionalWhitespace(line, _cursor);

    // 5. Validate the final dot
    if (_cursor >= line.length || line[_cursor] != '.') {
      throw ParseError('Expected final dot (.)', lineNumber, _cursor + 1);
    }
    _cursor++; // Consume the dot
    _cursor = NFormatsParserUtils.skipOptionalWhitespace(
      line,
      _cursor,
    ); // Skip any spaces/tabs after the dot

    // 6. Ensure we are at the end of the line OR a comment starts
    if (_cursor < line.length && line[_cursor] != '#') {
      // Corrected: message, lineNumber, columnNumber
      throw ParseError(
        'Unexpected characters after final dot (.)',
        lineNumber,
        _cursor + 1,
      );
    }
    _cursor = line.length;

    return Triple(subject, predicate, object);
  }

  // --- Term Parsing ---
  // These will parse the term starting from the current _cursor position
  // and update the _cursor to point after the parsed term.

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
      final iriTerm = iriResult.term;
      if (iriTerm.value.hasScheme) {
        return iriTerm;
      } else {
        throw ParseError(
          'Relative IRI <${iriTerm.value}> not allowed as subject (absolute IRI required)',
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
      // Update the sink's cursor
      _cursor = bnodeResult.cursor;
      // Get the parsed label string
      final label = bnodeResult.label;
      // Re-integrate the caching logic using the sink's _bnodeLabels map
      if (_bnodeLabels.containsKey(label)) {
        return _bnodeLabels[label]!;
      } else {
        final newNode = BlankNode(label); // Create BlankNode object here
        _bnodeLabels[label] = newNode; // Cache it in the sink
        return newNode;
      }
    } else {
      throw ParseError(
        'Expected IRI or Blank Node to start subject',
        lineNumber,
        startCol,
      );
    }
  }

  IRITerm _parsePredicate(String line, int lineNumber) {
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
      final iriTerm = iriResult.term;
      if (iriTerm.value.hasScheme) {
        return iriTerm;
      } else {
        throw ParseError(
          'Relative IRI <${iriTerm.value}> not allowed as predicate (absolute IRI required)',
          lineNumber,
          startCol, // Error relates to the start of the term
        );
      }
    } else {
      throw ParseError('Expected IRI to start predicate', lineNumber, startCol);
    }
  }

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
        final iriTerm = iriResult.term;
        if (iriTerm.value.hasScheme) {
          return iriTerm;
        } else {
          throw ParseError(
            'Relative IRI <${iriTerm.value}> not allowed as object (absolute IRI required)',
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
      // Update the sink's cursor
      _cursor = bnodeResult.cursor;
      // Get the parsed label string
      final label = bnodeResult.label;

      // Re-integrate the caching logic (same as in _parseSubject)
      if (_bnodeLabels.containsKey(label)) {
        return _bnodeLabels[label]!;
      } else {
        final newNode = BlankNode(label);
        _bnodeLabels[label] = newNode;
        return newNode;
      }
    } else if (char == '"') {
      // --- Literal Path ---
      // return _parseLiteral(line, lineNumber);
      final literalResult = NFormatsParserUtils.parseLiteralComponents(
        line,
        _cursor,
        lineNumber,
      );
      // Update the sink's cursor *before* trying to construct the Literal
      _cursor = literalResult.cursor;

      // Now, re-integrate Literal construction using the returned components

      // Determine the correct datatype for the constructor
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
      } catch (e) {
        // Catch other potential errors during Literal creation
        throw ParseError('Error creating literal: $e', lineNumber, startCol);
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
