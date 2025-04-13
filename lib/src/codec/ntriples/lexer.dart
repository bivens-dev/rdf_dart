import 'package:meta/meta.dart';

/// Defines the different types of tokens recognized by the [Lexer].
enum TokenType {
  IRIREF, // <...>
  BLANK_NODE_LABEL, // _:...
  STRING_LITERAL_QUOTE, // "..."
  LANG_DIR, // @lang or @lang--dir
  DATATYPE_MARKER, // ^^
  DOT, // .
  TRIPLE_TERM_START, // <<( 
  TRIPLE_TERME_END, // )>> 
  WHITESPACE, // Space or Tab characters (significant between terms)
  EOL, // End of Line sequence (\n, \r, \r\n)
  COMMENT, // #... until EOL
  EOF, // End of input
  ERROR // Unrecognized character or sequence
}

/// Represents a single lexical token identified by the [Lexer].
@immutable
class Token {
  final TokenType type;
  final String value; // Content: IRI value, label, literal value, lang/dir tag, etc.
  final int line;
  final int column;
  final String? errorMessage; // Present if type is ERROR

  const Token(this.type, this.value, this.line, this.column, [this.errorMessage]);

  @override
  String toString() =>
      'Token($type, "$value", L$line:C$column${errorMessage != null ? ', Error: $errorMessage' : ''})';

  @override
   bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value &&
          line == other.line &&
          column == other.column &&
          errorMessage == other.errorMessage;

   @override
   int get hashCode =>
       type.hashCode ^
       value.hashCode ^
       line.hashCode ^
       column.hashCode ^
       errorMessage.hashCode;
}

/// Converts an N-Triples input string into a stream of lexical tokens.
///
/// This lexer follows the RDF 1.2 N-Triples specification:
/// {https://www.w3.org/TR/rdf12-n-triples/}
///
/// It handles UTF-8 input (assuming the input `String` is correctly decoded Dart String),
/// RDF-Star quoted triples (`<<...>>`), literals with language tags and direction
/// indicators (`@lang--dir`), comments (`#...`), and various line ending conventions (`EOL`).
///
/// It produces tokens defined by the [TokenType] enum. Basic error reporting is
/// provided via tokens with [TokenType.ERROR].
class Lexer {
  /// The N-Triples input string being tokenized.
  final String input;

  /// Creates a lexer for the given N-Triples [input] string.
  Lexer(this.input);
}