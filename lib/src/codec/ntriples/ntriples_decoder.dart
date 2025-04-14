import 'dart:collection';
import 'dart:convert';

import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/codec/ntriples/parse_error.dart';

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
    _skipOptionalWhitespace(line);

    // 2. Parse Predicate
    final predicate = _parsePredicate(line, lineNumber);
    _skipOptionalWhitespace(line);

    // 3. Parse Object - it extends to the final '.'
    final object = _parseObject(line, lineNumber);

    // 4. Skip optional whitespace before the final dot
    _skipOptionalWhitespace(line);

    // 5. Validate the final dot
    if (_cursor >= line.length || line[_cursor] != '.') {
      throw ParseError('Expected final dot (.)', lineNumber, _cursor + 1);
    }
    _cursor++; // Consume the dot
    _skipOptionalWhitespace(line); // Skip any spaces/tabs after the dot

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

  /// Skips zero or more whitespace characters (space or tab).
  void _skipOptionalWhitespace(String line) {
    while (_cursor < line.length &&
        (line[_cursor] == ' ' || line[_cursor] == '\t')) {
      _cursor++;
    }
  }

  // --- Term Parsing ---
  // These will parse the term starting from the current _cursor position
  // and update the _cursor to point after the parsed term.

  SubjectTerm _parseSubject(String line, int lineNumber) {
    final startCol = _cursor + 1;
    _checkNotEof(line, 'subject', startCol);
    final char = line[_cursor];
    if (char == '<') {
      return _parseIri(line, lineNumber);
    } else if (char == '_' &&
        _cursor + 1 < line.length &&
        line[_cursor + 1] == ':') {
      return _parseBlankNode(line, lineNumber);
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
    _checkNotEof(line, 'predicate', startCol);
    if (line[_cursor] == '<') {
      return _parseIri(line, lineNumber);
    } else {
      throw ParseError('Expected IRI to start predicate', lineNumber, startCol);
    }
  }

  RdfTerm _parseObject(String line, int lineNumber) {
    final startCol = _cursor + 1;
    _checkNotEof(line, 'object', startCol);
    final char = line[_cursor];
    if (char == '<') {
      // Could be IRI or Triple Term
      // Look ahead more carefully
      if (_cursor + 2 < line.length && line.startsWith('<<(', _cursor)) {
        // Check for '<<( '
        return _parseTripleTerm(line, lineNumber);
      } else {
        // Assume IRI if not TripleTerm start sequence
        return _parseIri(line, lineNumber);
      }
    } else if (char == '_' &&
        _cursor + 1 < line.length &&
        line[_cursor + 1] == ':') {
      return _parseBlankNode(line, lineNumber);
    } else if (char == '"') {
      return _parseLiteral(line, lineNumber);
    } else {
      throw ParseError(
        'Expected IRI, Blank Node, Literal or Triple Term to start object',
        lineNumber,
        startCol,
      );
    }
  }

  /// Parses an N-Triples IRIREF at the current cursor position.
  /// Assumes the cursor points to the starting '<'.
  /// Updates the cursor past the closing '>'.
  /// Throws [ParseError] on syntax violations.
  IRITerm _parseIri(String line, int lineNumber) {
    final startColumn = _cursor + 1; // 1-based column for error reporting

    if (line[_cursor] != '<') {
      // Defensive check
      throw ParseError('Expected IRI to start with <', lineNumber, startColumn);
    }
    _cursor++; // Consume '<'

    final iriBuffer = StringBuffer();
    final startContentColumn = _cursor + 1; // For unterminated error

    while (_cursor < line.length) {
      final char = line[_cursor];
      final charCode = line.codeUnitAt(_cursor);
      final currentCol = _cursor + 1;

      if (char == '>') {
        // Found closing bracket
        _cursor++; // Consume '>'
        try {
          // Attempt to create IRI object, which might perform validation
          return IRITerm(IRI(iriBuffer.toString()));
        } catch (e) {
          // Wrap IRI construction errors in ParseError
          throw ParseError(
            'Invalid IRI value: $iriBuffer ($e)',
            lineNumber,
            startContentColumn, // Error relates to the content start
          );
        }
      }

      if (char == r'\') {
        // Potential escape sequence
        final escapeStartCol = _cursor + 1;
        _cursor++; // Consume '\'
        _checkNotEof(
          line,
          'IRI escape sequence',
          escapeStartCol,
        ); // Pass start column of potential escape
        final escapeChar = line[_cursor];

        if (escapeChar == 'u') {
          _cursor++; // Consume 'u'
          // _unescapeUchar updates _cursor internally
          iriBuffer.write(_unescapeUchar(line, lineNumber, 4, escapeStartCol));
        } else if (escapeChar == 'U') {
          _cursor++; // Consume 'U'
          // _unescapeUchar updates _cursor internally
          iriBuffer.write(_unescapeUchar(line, lineNumber, 8, escapeStartCol));
        } else {
          // Corrected ParseError call
          throw ParseError(
            r'Invalid escape sequence in IRI (only \uXXXX or \UXXXXXXXX allowed)',
            lineNumber,
            escapeStartCol, // Error occurred at the start of the escape attempt
          );
        }
      } else {
        // Check for disallowed characters according to Grammar [9]
        // Disallowed: #x00-#x20, <, >, ", {, }, |, ^, `, \
        if ((charCode >= 0x00 && charCode <= 0x20) ||
            char == '<' ||
            char == '>' ||
            char == '"' ||
            char == '{' ||
            char == '}' ||
            char == '|' ||
            char == '^' ||
            char == '`' ||
            char == r'\') {
          // Corrected ParseError call
          throw ParseError(
            'Invalid character in IRI: U+${charCode.toRadixString(16).toUpperCase()}',
            lineNumber,
            currentCol,
          );
        }
        // Append allowed character
        iriBuffer.write(char);
        _cursor++;
      }
    }

    // If loop finishes without finding '>', it's an error
    // Corrected ParseError call
    throw ParseError(
      'Unterminated IRI (missing >)',
      lineNumber,
      startContentColumn,
    );
  }

  /// Parses an N-Triples BLANK_NODE_LABEL at the current cursor position.
  /// Assumes the cursor points to the starting '_'.
  /// Updates the cursor past the end of the label.
  /// Throws [ParseError] on syntax violations.
  BlankNode _parseBlankNode(String line, int lineNumber) {
    final startCol = _cursor + 1;

    // Check prefix '_:'
    if (_cursor + 1 >= line.length ||
        line[_cursor] != '_' ||
        line[_cursor + 1] != ':') {
      throw ParseError(
        "Internal error: Expected blank node to start with '_:'",
        lineNumber,
        startCol,
      );
    }
    _cursor += 2; // Consume '_:'

    _checkNotEof(line, 'blank node label', startCol + 1); // Check after '_:'

    final labelStartCursor = _cursor; // Label starts here
    final firstCharCol = _cursor + 1;
    final firstCharCode = line.codeUnitAt(_cursor);

    // Validate first character: PN_CHARS_U | [0-9]
    if (!_isPnCharsU(firstCharCode) &&
        !(firstCharCode >= 0x30 && firstCharCode <= 0x39)) {
      throw ParseError(
        'Invalid first character for blank node label',
        lineNumber,
        firstCharCol,
      );
    }
    _cursor++; // Consume first character

    // Consume subsequent characters: (PN_CHARS | '.')*
    // No need for labelIntermediateStartCursor here
    while (_cursor < line.length) {
      final currentCharCode = line.codeUnitAt(_cursor);
      if (_isPnChars(currentCharCode) || currentCharCode == 0x2E /* '.' */ ) {
        _cursor++;
      } else {
        break; // End of label characters
      }
    }

    // Label extracted from labelStartCursor up to the current _cursor
    final label = line.substring(labelStartCursor, _cursor);

    // Final validation: Check last character is not '.'
    if (label.endsWith('.')) {
      throw ParseError(
        "Blank node label cannot end with '.'",
        lineNumber,
        _cursor,
      ); // _cursor is after the dot
    }

    // Check cache or create new BlankNode
    if (_bnodeLabels.containsKey(label)) {
      return _bnodeLabels[label]!;
    } else {
      final newNode = BlankNode(label);
      _bnodeLabels[label] = newNode;
      return newNode;
    }
  }

  /// Parses an N-Triples Literal at the current cursor position.
  /// Assumes the cursor points to the starting '"'.
  /// Updates the cursor past the end of the literal (quote, tag, or type).
  /// Throws [ParseError] on syntax violations.
  Literal _parseLiteral(String line, int lineNumber) {
    final startCol = _cursor + 1; // 1-based column for error reporting

    if (line[_cursor] != '"') {
      // Defensive check
      throw ParseError(
        'Expected Literal to start with "',
        lineNumber,
        startCol,
      );
    }
    _cursor++; // Consume opening '"'

    final lexicalBuffer = StringBuffer();
    final contentStartCol =
        _cursor + 1; // For reporting errors within the content
    var closed = false;

    // Parse the literal's content (STRING_LITERAL_QUOTE)
    while (_cursor < line.length) {
      final char = line[_cursor];
      final charCode = line.codeUnitAt(_cursor);
      final currentCol = _cursor + 1;

      if (char == '"') {
        _cursor++; // Consume closing '"'
        closed = true;
        break; // End of literal string content
      }

      if (char == r'\') {
        // Handle escape sequences (ECHAR or UCHAR)
        final escapeStartCol = _cursor + 1;
        _cursor++; // Consume '\'
        _checkNotEof(line, 'literal escape sequence', escapeStartCol);
        final escapeChar = line[_cursor];

        switch (escapeChar) {
          // ECHAR: [tbnrf"'] plus our addition of \ for \ itself
          case 't':
            lexicalBuffer.write('\t');
            _cursor++;
          case 'b':
            lexicalBuffer.write('\b');
            _cursor++;
          case 'n':
            lexicalBuffer.write('\n');
            _cursor++;
          case 'r':
            lexicalBuffer.write('\r');
            _cursor++;
          case 'f':
            lexicalBuffer.write('\f');
            _cursor++;
          case '"':
            lexicalBuffer.write('"');
            _cursor++;
          case r'\':
            lexicalBuffer.write(r'\');
            _cursor++;
          // UCHAR
          case 'u':
            _cursor++; // Consume 'u'
            // _unescapeUchar handles cursor update past hex digits
            lexicalBuffer.write(
              _unescapeUchar(line, lineNumber, 4, escapeStartCol),
            );
          case 'U':
            _cursor++; // Consume 'U'
            // _unescapeUchar handles cursor update past hex digits
            lexicalBuffer.write(
              _unescapeUchar(line, lineNumber, 8, escapeStartCol),
            );
          default:
            throw ParseError(
              'Invalid escape sequence in literal: \\$escapeChar',
              lineNumber,
              escapeStartCol,
            );
        }
      } else {
        // Check for disallowed unescaped characters LF (U+0A), CR (U+0D)
        if (charCode == 0x0A || charCode == 0x0D) {
          throw ParseError(
            'Invalid unescaped character (LF or CR) in literal',
            lineNumber,
            currentCol,
          );
        }
        // Append allowed character
        lexicalBuffer.write(char);
        _cursor++;
      }
    }

    if (!closed) {
      // Reached end of line without finding closing quote
      throw ParseError(
        'Unterminated string literal',
        lineNumber,
        contentStartCol,
      );
    }

    final lexicalForm = lexicalBuffer.toString();

    // --- Check for suffix: @lang--dir or ^^<datatype> ---
    TextDirection? parsedDirection;
    IRI? parsedDatatype;
    String? pureLanguageTag; // Store only the BCP47 part

    if (_cursor < line.length) {
      final suffixStartCol = _cursor + 1;
      if (line[_cursor] == '@') {
        // --- Parse LANG_DIR ---
        _cursor++; // Consume '@'
        final tagStartCursor = _cursor; // Remember where the tag content starts
        _checkNotEof(line, 'language tag', suffixStartCol);

        // 1. Parse primary language tag: [a-zA-Z]+
        final primaryTagMatch = RegExp(
          '^[a-zA-Z]+',
        ).firstMatch(line.substring(_cursor));
        if (primaryTagMatch == null) {
          throw ParseError(
            'Expected primary language subtag after @',
            lineNumber,
            suffixStartCol,
          );
        }
        _cursor += primaryTagMatch.group(0)!.length;

        // 2. Parse optional subtags: ( '-' [a-zA-Z0-9]+ )*
        while (_cursor < line.length && line[_cursor] == '-') {
          // Look ahead: Is it '--' or just '-'?
          if (_cursor + 1 < line.length && line[_cursor + 1] == '-') {
            // Found '--', potential direction separator, stop subtag loop
            break;
          }
          // It's just a single '-', expect alphanumeric subtag
          _cursor++; // Consume '-'
          _checkNotEof(line, 'language subtag', _cursor + 1);
          final subtagMatch = RegExp(
            '^[a-zA-Z0-9]+',
          ).firstMatch(line.substring(_cursor));
          if (subtagMatch == null) {
            throw ParseError(
              'Expected language subtag after -',
              lineNumber,
              _cursor + 1,
            );
          }
          _cursor += subtagMatch.group(0)!.length;
        }

        // Remember the end of the BCP47 part before checking for direction
        final bcp47EndCursor = _cursor;

        // 3. Check for optional direction part: ( '--' [a-zA-Z]+ )?
        if (_cursor + 1 < line.length && line.startsWith('--', _cursor)) {
          final directionStartCursor = _cursor; // For error reporting col
          _cursor += 2; // Consume '--'
          _checkNotEof(
            line,
            'language direction',
            directionStartCursor + 3,
          ); // Check after --
          final dirMatch = RegExp(
            '^[a-zA-Z]+',
          ).firstMatch(line.substring(_cursor));
          if (dirMatch == null) {
            throw ParseError(
              'Expected direction (ltr/rtl) after --',
              lineNumber,
              directionStartCursor + 3,
            );
          }
          final directionStr = dirMatch.group(0)!;
          _cursor += directionStr.length;

          // Validate direction string
          if (directionStr == 'ltr') {
            parsedDirection = TextDirection.ltr;
          } else if (directionStr == 'rtl') {
            parsedDirection = TextDirection.rtl;
          } else {
            // Error points to the start of the invalid direction string
            throw ParseError(
              'Invalid direction "$directionStr", expected "ltr" or "rtl"',
              lineNumber,
              directionStartCursor + 3,
            );
          }
        }

        // Extract the pure BCP47 part (up to where -- started, or end if no dir)
        pureLanguageTag = line.substring(tagStartCursor, bcp47EndCursor);

        // Datatype is implicitly rdf:langString (Literal constructor handles actual type based on direction)
        parsedDatatype = RDF.langString;
      } else if (line[_cursor] == '^') {
        // --- Parse Datatype IRI ---
        _checkNotEof(line, 'datatype separator ^^', suffixStartCol);
        if (_cursor + 1 >= line.length || line[_cursor + 1] != '^') {
          throw ParseError(
            'Expected second ^ for datatype',
            lineNumber,
            _cursor + 2,
          );
        }
        _cursor += 2; // Consume '^^'
        _skipOptionalWhitespace(line); // Allow whitespace before IRI starts
        _checkNotEof(line, 'datatype IRI', _cursor + 1);

        if (line[_cursor] != '<') {
          throw ParseError(
            'Expected < to start datatype IRI',
            lineNumber,
            _cursor + 1,
          );
        }
        // Re-use IRI parser, which handles cursor update
        final iriTerm = _parseIri(line, lineNumber);
        parsedDatatype = iriTerm.value;

        // Language tag must be null if datatype is explicitly provided
        pureLanguageTag = null;
        parsedDirection = null;
      }
      // If neither @ nor ^, the literal ends after the closing quote.
      // The calling function (_parseTripleLine) checks what follows (whitespace/dot).
    }

    // Determine final datatype: Use parsed one, or default to xsd:string
    final finalDatatype = parsedDatatype ?? XSD.string;

    // Variable to hold the 1-based column where the language tag started, if applicable
    int? languageTagStartCol;
    if (pureLanguageTag != null) {
      // Calculate where the tag started: after the closing quote and the '@'
      // This assumes no whitespace is allowed between '"' and '@',
      // and between '@' and the tag itself, which aligns with LANG_DIR grammar.
      // Find the position of '@' by working backwards from the current cursor.
      final atPos = line.lastIndexOf('@', _cursor);
      if (atPos != -1) {
        languageTagStartCol = atPos + 2; // Column after '@'
      } else {
        languageTagStartCol = startCol; // Fallback if calculation fails
      }
    }

    // Construct the Literal - this performs final validation
    try {
      return Literal(
        lexicalForm,
        finalDatatype,
        pureLanguageTag,
        parsedDirection,
      );
    } on LiteralConstraintException catch (e) {
      // Wrap constraint errors from constructor (e.g., lang tag mismatch)
      throw ParseError('Invalid literal arguments: $e', lineNumber, startCol);
    } on InvalidLexicalFormException catch (e) {
      // Wrap lexical validation errors from constructor (if value parsing fails)
      throw ParseError(
        'Invalid lexical form for datatype ${e.datatypeIri}: "${e.lexicalForm}" ($e)',
        lineNumber,
        contentStartCol,
      );
    } on InvalidLanguageTagException catch (e) {
      // Wrap invalid language tag errors
      throw ParseError(
        'Invalid language tag: "${e.languageTag}" ($e)',
        lineNumber,
        languageTagStartCol ?? startCol,
      ); // Use specific tag start column if found
    } catch (e) {
      // Catch other potential errors during Literal creation
      throw ParseError('Error creating literal: $e', lineNumber, startCol);
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

    _skipOptionalWhitespace(line); // Allow whitespace after '<<('

    // --- Parse inner triple components recursively ---
    // These calls will update the _cursor internally

    // 1. Parse Inner Subject
    final subject = _parseSubject(line, lineNumber);
    _skipOptionalWhitespace(line);

    // 2. Parse Inner Predicate
    final predicate = _parsePredicate(line, lineNumber);
    _skipOptionalWhitespace(line); // Require whitespace after inner predicate

    // 3. Parse Inner Object
    final object = _parseObject(line, lineNumber);

    // --- End of inner triple components ---

    _skipOptionalWhitespace(line); // Allow whitespace before closing ')>>'

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

  /// Unescapes a N-Triples UCHAR sequence (\uXXXX or \UXXXXXXXX).
  /// Assumes the cursor points *after* the 'u' or 'U'.
  /// Updates the cursor past the final hex digit.
  /// Returns the unescaped character as a String.
  /// [escapeStartColumn] is the 1-based column where the '\' started.
  String _unescapeUchar(
    String line,
    int lineNumber,
    int hexDigits,
    int escapeStartColumn,
  ) {
    final hexStartCursor = _cursor; // Cursor is currently after 'u' or 'U'
    final endHex = _cursor + hexDigits;

    if (endHex > line.length) {
      // Corrected ParseError call
      throw ParseError(
        'Unterminated UCHAR escape sequence',
        lineNumber,
        escapeStartColumn,
      );
    }

    final hexString = line.substring(hexStartCursor, endHex);
    int? codePoint;
    try {
      // Validate hex digits strictly
      if (hexString.length != hexDigits ||
          !RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexString)) {
        throw const FormatException('Invalid hex digits');
      }
      codePoint = int.parse(hexString, radix: 16);
    } on FormatException catch (_) {
      // Corrected ParseError call
      throw ParseError(
        'Invalid UCHAR escape sequence (bad hex)',
        lineNumber,
        escapeStartColumn,
      );
    }

    // Basic validation of code point range (avoids creating invalid strings)
    if (codePoint > 0x10FFFF || (codePoint >= 0xD800 && codePoint <= 0xDFFF)) {
      // Corrected ParseError call
      throw ParseError(
        'Invalid UCHAR code point (out of range or surrogate)',
        lineNumber,
        escapeStartColumn,
      );
    }

    _cursor = endHex; // Update cursor past the hex digits
    return String.fromCharCode(codePoint);
  }

  /// Helper to check if cursor is at the end of the line, throws if so.
  /// [contextCol] is the 1-based column number where the context started.
  void _checkNotEof(String line, String context, int contextCol) {
    if (_cursor >= line.length) {
      // Corrected ParseError call
      throw ParseError(
        'Unexpected end of line while parsing $context',
        _lineNumber,
        contextCol,
      );
    }
  }

  /// Checks if a character code matches the PN_CHARS_BASE production.
  /// Based on N-Triples EBNF Grammar [15].
  bool _isPnCharsBase(int c) {
    return
    // A-Z
    (c >= 0x41 && c <= 0x5A) ||
        // a-z
        (c >= 0x61 && c <= 0x7A) ||
        // C0-D6
        (c >= 0xC0 && c <= 0xD6) ||
        // D8-F6
        (c >= 0xD8 && c <= 0xF6) ||
        // F8-02FF
        (c >= 0xF8 && c <= 0x02FF) ||
        // 0370-037D
        (c >= 0x0370 && c <= 0x037D) ||
        // 037F-1FFF
        (c >= 0x037F && c <= 0x1FFF) ||
        // 200C-200D (Zero Width Non-Joiner, Zero Width Joiner)
        (c >= 0x200C && c <= 0x200D) ||
        // 2070-218F
        (c >= 0x2070 && c <= 0x218F) ||
        // 2C00-2FEF
        (c >= 0x2C00 && c <= 0x2FEF) ||
        // 3001-D7FF (Excludes surrogates D800-DFFF)
        (c >= 0x3001 && c <= 0xD7FF) ||
        // F900-FDCF
        (c >= 0xF900 && c <= 0xFDCF) ||
        // FDF0-FFFD (Includes replacement char FFFD)
        (c >= 0xFDF0 && c <= 0xFFFD) ||
        // 10000-EFFFF (Planes 1-14)
        (c >= 0x10000 && c <= 0xEFFFF);
  }

  /// Checks if a character code matches the PN_CHARS_U production.
  /// PN_CHARS_U ::= PN_CHARS_BASE | '_'
  /// Based on N-Triples EBNF Grammar [16].
  bool _isPnCharsU(int c) {
    // Check PN_CHARS_BASE OR underscore (U+005F)
    return _isPnCharsBase(c) || c == 0x5F;
  }

  /// Checks if a character code matches the PN_CHARS production.
  /// PN_CHARS ::= PN_CHARS_U | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]
  /// Based on N-Triples EBNF Grammar [17].
  bool _isPnChars(int c) {
    return
    // Check PN_CHARS_U first
    _isPnCharsU(c) ||
        // Hyphen (U+002D)
        c == 0x2D ||
        // Digits 0-9
        (c >= 0x30 && c <= 0x39) ||
        // Middle Dot (U+00B7)
        c == 0xB7 ||
        // Combining Diacritical Marks (U+0300 to U+036F)
        (c >= 0x0300 && c <= 0x036F) ||
        // Undertie (U+203F) and Character Tie (U+2040)
        (c >= 0x203F && c <= 0x2040);
  }
}
