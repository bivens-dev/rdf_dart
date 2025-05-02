import 'package:iri/iri.dart';
import 'package:rdf_dart/src/codec/n_formats/parse_error.dart';
import 'package:rdf_dart/src/model/iri_term.dart';
import 'package:rdf_dart/src/model/literal.dart';

// Explicitly creating a helper class of useful related methods
// ignore: avoid_classes_with_only_static_members
/// Utility class for parsing elements common to N-Triples/N-Quads syntax.
///
/// Methods operate on the input string `line` starting from the given `cursor`
/// position and return the parsed result along with the updated cursor position.
/// They throw [ParseError] on syntax violations.
class NFormatsParserUtils {
  /// Helper to check if cursor is at the end of the line, throws if so.
  /// [cursor] is the current 0-based position in the line.
  /// [lineNumber] is the 1-based line number for error reporting.
  /// [context] is a string describing what was being parsed.
  /// [contextCol] is the 1-based column number where the context started.
  static void checkNotEof(
    String line,
    int cursor,
    int lineNumber,
    String context,
    int contextCol,
  ) {
    if (cursor >= line.length) {
      throw ParseError(
        'Unexpected end of line while parsing $context',
        lineNumber,
        contextCol,
      );
    }
  }

  /// Unescapes an N-Triples/N-Quads UCHAR sequence (\uXXXX or \UXXXXXXXX).
  /// Assumes [cursor] points *after* the 'u' or 'U'.
  /// Returns a record containing the unescaped character and the cursor position
  /// *after* the final hex digit.
  /// [escapeStartColumn] is the 1-based column where the '\' started.
  static ({String char, int cursor}) _unescapeUchar(
    String line,
    int cursor, // Cursor starts *after* 'u'/'U'
    int lineNumber,
    int hexDigits,
    int escapeStartColumn,
  ) {
    final hexStartCursor = cursor;
    final endHex = cursor + hexDigits;

    if (endHex > line.length) {
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
      throw ParseError(
        'Invalid UCHAR escape sequence (bad hex)',
        lineNumber,
        escapeStartColumn,
      );
    }

    // Basic validation of code point range (avoids creating invalid strings)
    if (codePoint > 0x10FFFF || (codePoint >= 0xD800 && codePoint <= 0xDFFF)) {
      throw ParseError(
        'Invalid UCHAR code point (out of range or surrogate)',
        lineNumber,
        escapeStartColumn,
      );
    }

    // Return the char and the new cursor position
    return (char: String.fromCharCode(codePoint), cursor: endHex);
  }

  /// Checks if a character code matches the PN_CHARS_BASE production.
  /// Based on N-Triples & N-Quads EBNF Grammar [15].
  static bool _isPnCharsBase(int c) {
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
  static bool _isPnCharsU(int c) {
    // Check PN_CHARS_BASE OR underscore (U+005F)
    return _isPnCharsBase(c) || c == 0x5F;
  }

  /// Checks if a character code matches the PN_CHARS production.
  /// PN_CHARS ::= PN_CHARS_U | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]
  /// Based on N-Triples EBNF Grammar [17].
  static bool _isPnChars(int c) {
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

  /// Skips zero or more whitespace characters (space or tab) from the cursor.
  /// Returns the updated cursor position.
  static int skipOptionalWhitespace(String line, int cursor) {
    var currentCursor = cursor;
    while (currentCursor < line.length &&
        (line[currentCursor] == ' ' || line[currentCursor] == '\t')) {
      currentCursor++;
    }
    return currentCursor;
  }

  /// Parses the content of an N-Triples/N-Quads string literal ("...")
  /// Handles ECHAR and UCHAR escape sequences. Assumes cursor is *after* opening quote.
  /// Returns the unescaped string content and cursor position *after* closing quote.
  /// Throws [ParseError] if syntax is invalid or unterminated.
  static ({String content, int cursor}) _parseLiteralStringContent(
    String line,
    int cursor, // Cursor starts *after* opening '"'
    int lineNumber,
    int contentStartCol, // Column number for error reporting inside content
  ) {
    var currentCursor = cursor;
    final lexicalBuffer = StringBuffer();
    var closed = false;

    while (currentCursor < line.length) {
      final char = line[currentCursor];
      final charCode = line.codeUnitAt(currentCursor);
      final currentCol = currentCursor + 1;

      if (char == '"') {
        currentCursor++; // Consume closing '"'
        closed = true;
        break; // End of literal string content
      }

      if (char == r'\') {
        // Handle escape sequences (ECHAR or UCHAR)
        final escapeStartCol = currentCursor + 1;
        currentCursor++; // Consume '\'
        // Use static helper (make public if needed, or keep private if only called here)
        checkNotEof(
          line,
          currentCursor,
          lineNumber,
          'literal escape sequence',
          escapeStartCol,
        );
        final escapeChar = line[currentCursor];

        switch (escapeChar) {
          // ECHAR: [tbnrf"'] plus our addition of \ for \ itself
          case 't':
            lexicalBuffer.write('\t');
            currentCursor++;
          case 'b':
            lexicalBuffer.write('\b');
            currentCursor++;
          case 'n':
            lexicalBuffer.write('\n');
            currentCursor++;
          case 'r':
            lexicalBuffer.write('\r');
            currentCursor++;
          case "'": //
            lexicalBuffer.write("'");
            currentCursor++;
          case 'f':
            lexicalBuffer.write('\f');
            currentCursor++;
          case '"':
            lexicalBuffer.write('"');
            currentCursor++;
          case r'\':
            lexicalBuffer.write(r'\');
            currentCursor++;
          // UCHAR
          case 'u':
            currentCursor++; // Consume 'u'
            final uResult = _unescapeUchar(
              line,
              currentCursor,
              lineNumber,
              4,
              escapeStartCol,
            );
            lexicalBuffer.write(uResult.char);
            currentCursor = uResult.cursor;
          case 'U':
            currentCursor++; // Consume 'U'
            final uResult = _unescapeUchar(
              line,
              currentCursor,
              lineNumber,
              8,
              escapeStartCol,
            );
            lexicalBuffer.write(uResult.char);
            currentCursor = uResult.cursor;
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
        currentCursor++;
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

    return (content: lexicalBuffer.toString(), cursor: currentCursor);
  }

  /// Parses an N-Triples/N-Quads IRIREF at the given [cursor] position.
  /// Assumes the cursor points to the starting '<'.
  /// Returns a record containing the parsed [IRINode] and the cursor position
  /// *after* the closing '>'.
  /// Throws [ParseError] on syntax violations.
  static ({IRINode term, int cursor}) parseIri(
    String line,
    int cursor, // Cursor starts at '<'
    int lineNumber,
  ) {
    var currentCursor = cursor; // Use a local mutable cursor
    final startColumn = currentCursor + 1; // 1-based column for error reporting

    if (line[currentCursor] != '<') {
      // Defensive check
      throw ParseError('Expected IRI to start with <', lineNumber, startColumn);
    }
    currentCursor++; // Consume '<'

    final iriBuffer = StringBuffer();
    final startContentColumn = currentCursor + 1; // For unterminated error

    while (currentCursor < line.length) {
      final char = line[currentCursor];
      final charCode = line.codeUnitAt(currentCursor);
      final currentCol = currentCursor + 1;

      if (char == '>') {
        // Found closing bracket
        currentCursor++; // Consume '>'
        try {
          final iriValue = IRI(iriBuffer.toString());
          return (
            term: IRINode(iriValue),
            cursor: currentCursor,
          ); // Return record
        } catch (e) {
          throw ParseError(
            'Invalid IRI value: $iriBuffer ($e)',
            lineNumber,
            startContentColumn,
          );
        }
      }

      if (char == r'\') {
        // Potential escape sequence
        final escapeStartCol = currentCursor + 1;
        currentCursor++; // Consume '\'
        // Call static helper, passing current state
        checkNotEof(
          line,
          currentCursor,
          lineNumber,
          'IRI escape sequence',
          escapeStartCol,
        );
        final escapeChar = line[currentCursor];

        if (escapeChar == 'u') {
          currentCursor++; // Consume 'u'
          // Call static helper, update local cursor from result
          final result = _unescapeUchar(
            line,
            currentCursor,
            lineNumber,
            4,
            escapeStartCol,
          );
          iriBuffer.write(result.char);
          currentCursor = result.cursor; // Update local cursor
        } else if (escapeChar == 'U') {
          currentCursor++; // Consume 'U'
          // Call static helper, update local cursor from result
          final result = _unescapeUchar(
            line,
            currentCursor,
            lineNumber,
            8,
            escapeStartCol,
          );
          iriBuffer.write(result.char);
          currentCursor = result.cursor; // Update local cursor
        } else {
          throw ParseError(
            r'Invalid escape sequence in IRI (only \uXXXX or \UXXXXXXXX allowed)',
            lineNumber,
            escapeStartCol,
          );
        }
      } else {
        // Check for disallowed characters (unchanged logic)
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
          throw ParseError(
            'Invalid character in IRI: U+${charCode.toRadixString(16).toUpperCase()}',
            lineNumber,
            currentCol,
          );
        }
        // Append allowed character
        iriBuffer.write(char);
        currentCursor++;
      }
    }

    // If loop finishes without finding '>', it's an error
    throw ParseError(
      'Unterminated IRI (missing >)',
      lineNumber,
      startContentColumn,
    );
  }

  /// Parses an N-Triples/N-Quads BLANK_NODE_LABEL at the given [cursor] position.
  /// Assumes the cursor points to the starting '_'.
  /// Returns a record containing the parsed label string (without the leading '_:')
  /// and the cursor position *after* the end of the label.
  /// Throws [ParseError] on syntax violations.
  static ({String label, int cursor}) parseBlankNodeLabel(
    String line,
    int cursor,
    int lineNumber,
  ) {
    var currentCursor = cursor; // Use local mutable cursor
    final startCol = currentCursor + 1;

    // Check prefix '_:'
    if (currentCursor + 1 >= line.length ||
        line[currentCursor] != '_' ||
        line[currentCursor + 1] != ':') {
      // This check might be slightly redundant if the caller ensures '_'
      // but good for robustness if called directly.
      throw ParseError(
        "Expected blank node to start with '_:'",
        lineNumber,
        startCol,
      );
    }
    currentCursor += 2; // Consume '_:'

    // Use static helper _checkNotEof (adjust if made public)
    checkNotEof(
      line,
      currentCursor,
      lineNumber,
      'blank node label',
      startCol + 1,
    );

    final labelStartCursor = currentCursor; // Label starts here
    final firstCharCol = currentCursor + 1;
    final firstCharCode = line.codeUnitAt(currentCursor);

    // Validate first character: PN_CHARS_U | [0-9]
    if (!_isPnCharsU(firstCharCode) &&
        !(firstCharCode >= 0x30 && firstCharCode <= 0x39)) {
      throw ParseError(
        'Invalid first character for blank node label',
        lineNumber,
        firstCharCol,
      );
    }
    currentCursor++; // Consume first character

    // Consume subsequent characters: (PN_CHARS | '.')*
    while (currentCursor < line.length) {
      final currentCharCode = line.codeUnitAt(currentCursor);
      final isDot = currentCharCode == 0x2E; /* '.' */

      // Check if this character is potentially the triple/quad terminator dot
      // It's a potential terminator if it's a dot AND followed by EOL, whitespace, or comment
      final isPotentialTerminator =
          isDot &&
          (currentCursor + 1 == line.length ||
              line[currentCursor + 1] == ' ' ||
              line[currentCursor + 1] == '\t' ||
              line[currentCursor + 1] == '#');

      // Use static helper isPnChars
      if (_isPnChars(currentCharCode) || currentCharCode == 0x2E /* '.' */ ) {
        // Only consume if it's NOT the potential terminator dot
        if (!isPotentialTerminator) {
          currentCursor++;
        } else {
          break; // Stop before consuming the potential terminator dot
        }
      } else {
        break; // End of label characters
      }
    }

    // Label extracted from labelStartCursor up to the current currentCursor
    final label = line.substring(labelStartCursor, currentCursor);

    // Final validation: Check last character is not '.'
    // Check if the *extracted label itself* ends with '.'
    if (label.endsWith('.')) {
      throw ParseError(
        "Blank node label cannot end with '.'",
        lineNumber,
        currentCursor, // Error column is where the dot was (end of label)
      );
    }

    // Return the extracted label and the final cursor position
    return (label: label, cursor: currentCursor);
  }

  /// Parses an N-Triples/N-Quads Literal at the given [cursor] position.
  /// Assumes the cursor points to the starting '"'.
  /// Returns a record containing the literal components (lexical form,
  /// language tag, direction, datatype IRI) and the cursor position *after*
  /// the end of the literal (including any suffix).
  /// Returns null for language/direction/datatype if not present.
  /// Throws [ParseError] on syntax violations.
  static ({
    String lexicalForm,
    String? languageTag,
    TextDirection? direction,
    IRI? datatypeIri,
    int cursor,
  })
  parseLiteralComponents(
    String line,
    int cursor, // Cursor starts at '"'
    int lineNumber,
  ) {
    var currentCursor = cursor;
    final startCol = currentCursor + 1; // 1-based column for error reporting

    if (line[currentCursor] != '"') {
      throw ParseError(
        'Expected Literal to start with "',
        lineNumber,
        startCol,
      );
    }
    currentCursor++; // Consume opening '"'
    final contentStartCol = currentCursor + 1;

    // Parse the string content using the helper
    final contentResult = _parseLiteralStringContent(
      line,
      currentCursor,
      lineNumber,
      contentStartCol,
    );
    final lexicalForm = contentResult.content;
    currentCursor = contentResult.cursor; // Update cursor past closing quote

    // --- Check for suffix: @lang--dir or ^^<datatype> ---
    TextDirection? parsedDirection;
    IRI? parsedDatatypeIri;
    String? parsedLanguageTag;

    // Look ahead - skip whitespace doesn't consume if no whitespace exists
    final cursorBeforeSuffix = currentCursor;
    final cursorAfterWhitespace = skipOptionalWhitespace(line, currentCursor);

    if (cursorAfterWhitespace < line.length) {
      final suffixStartCol = cursorAfterWhitespace + 1;
      if (line[cursorAfterWhitespace] == '@') {
        // --- Parse LANG_DIR ---
        currentCursor = cursorAfterWhitespace + 1; // Consume '@'
        final tagStartCursor = currentCursor;
        checkNotEof(
          line,
          currentCursor,
          lineNumber,
          'language tag',
          suffixStartCol,
        );

        // 1. Parse primary language tag: [a-zA-Z]+
        final primaryTagMatch = RegExp(
          '^[a-zA-Z]+',
        ).firstMatch(line.substring(currentCursor));
        if (primaryTagMatch == null) {
          throw ParseError(
            'Expected primary language subtag after @',
            lineNumber,
            currentCursor + 1,
          );
        }
        currentCursor += primaryTagMatch.group(0)!.length;

        // 2. Parse optional subtags: ( '-' [a-zA-Z0-9]+ )*
        while (currentCursor < line.length && line[currentCursor] == '-') {
          if (currentCursor + 1 < line.length &&
              line[currentCursor + 1] == '-') {
            break; // Found '--', potential direction separator
          }
          currentCursor++; // Consume '-'
          checkNotEof(
            line,
            currentCursor,
            lineNumber,
            'language subtag',
            currentCursor + 1,
          );
          final subtagMatch = RegExp(
            '^[a-zA-Z0-9]+',
          ).firstMatch(line.substring(currentCursor));
          if (subtagMatch == null) {
            throw ParseError(
              'Expected language subtag after -',
              lineNumber,
              currentCursor + 1,
            );
          }
          currentCursor += subtagMatch.group(0)!.length;
        }
        final bcp47EndCursor = currentCursor; // End of BCP47 part

        // 3. Check for optional direction part: ( '--' [a-zA-Z]+ )?
        if (currentCursor + 1 < line.length &&
            line.startsWith('--', currentCursor)) {
          final directionStartCursor = currentCursor;
          currentCursor += 2; // Consume '--'
          checkNotEof(
            line,
            currentCursor,
            lineNumber,
            'language direction',
            directionStartCursor + 3,
          );
          final dirMatch = RegExp(
            '^[a-zA-Z]+',
          ).firstMatch(line.substring(currentCursor));
          if (dirMatch == null) {
            throw ParseError(
              'Expected direction (ltr/rtl) after --',
              lineNumber,
              directionStartCursor + 3,
            );
          }
          final directionStr = dirMatch.group(0)!;
          currentCursor += directionStr.length;

          if (directionStr == 'ltr') {
            parsedDirection = TextDirection.ltr;
          } else if (directionStr == 'rtl') {
            parsedDirection = TextDirection.rtl;
          } else {
            throw ParseError(
              'Invalid direction "$directionStr", expected "ltr" or "rtl"',
              lineNumber,
              directionStartCursor + 3,
            );
          }
        }
        parsedLanguageTag = line.substring(tagStartCursor, bcp47EndCursor);
      } else if (line[cursorAfterWhitespace] == '^') {
        // --- Parse Datatype IRI ---
        checkNotEof(
          line,
          cursorAfterWhitespace,
          lineNumber,
          'datatype separator ^^',
          suffixStartCol,
        );
        if (cursorAfterWhitespace + 1 >= line.length ||
            line[cursorAfterWhitespace + 1] != '^') {
          throw ParseError(
            'Expected second ^ for datatype',
            lineNumber,
            cursorAfterWhitespace + 2,
          );
        }
        currentCursor = cursorAfterWhitespace + 2; // Consume '^^'
        currentCursor = skipOptionalWhitespace(
          line,
          currentCursor,
        ); // Allow whitespace
        checkNotEof(
          line,
          currentCursor,
          lineNumber,
          'datatype IRI',
          currentCursor + 1,
        );

        if (line[currentCursor] != '<') {
          throw ParseError(
            'Expected < to start datatype IRI',
            lineNumber,
            currentCursor + 1,
          );
        }
        // Use static IRI parser
        final iriResult = parseIri(line, currentCursor, lineNumber);
        parsedDatatypeIri = iriResult.term.value; // Get the IRI object
        currentCursor = iriResult.cursor; // Update cursor
      } else {
        // Suffix started with something else, revert cursor
        currentCursor = cursorBeforeSuffix;
      }
    } else {
      // Reached end of line after quote, no suffix present
      currentCursor = cursorBeforeSuffix; // Revert to position after quote
    }

    return (
      lexicalForm: lexicalForm,
      languageTag: parsedLanguageTag,
      direction: parsedDirection,
      datatypeIri: parsedDatatypeIri, // Will be null if langtag or no suffix
      cursor: currentCursor,
    );
  }
}
