import 'package:rdf_dart/src/codec/ntriples/lexer.dart';

/// Represents a syntax error encountered during N-Triples parsing.
///
/// Contains information about the error message, the location (line and column)
/// where the error occurred, and optionally the expected token type versus the
/// actual token found at that location.
///
/// This class implements [Exception], making it suitable for representing
/// recoverable error conditions encountered during parsing external input.
class ParseError implements Exception {
  /// A human-readable message describing the parse error.
  final String message;

  /// The line number (1-based) in the input string where the error occurred.
  final int line;

  /// The column number (1-based) in the input string where the error occurred.
  final int column;

  /// The type of token that the parser expected at the error location, if known.
  final TokenType? expectedToken;

  /// The actual token found at the error location, if available.
  final Token? actualToken;

  /// Creates a representation of a parse error.
  ///
  /// Requires a [message], the [line] number, and the [column] number.
  /// Optionally takes the [expectedToken] and the [actualToken] found.
  const ParseError(this.message, this.line, this.column,
      {this.expectedToken, this.actualToken});

  /// Provides a user-friendly string representation of the parse error,
  /// including location and token details if available.
  @override
  String toString() {
    final location = 'L$line:C$column';
    var details = '';
    if (expectedToken != null) {
      details += ' Expected $expectedToken';
    }
    if (actualToken != null) {
      // Sanitize token value for printing (e.g., replace newlines)
      final safeValue = actualToken!.value
          .replaceAll('\n', r'\n')
          .replaceAll('\r', r'\r')
          .replaceAll('\t', r'\t');
      details += ' but found ${actualToken!.type}("$safeValue")';
    }
    return 'Parse Error ($location): $message.$details';
  }

  /// Allows comparing ParseError objects for equality, useful for testing
  /// or storing unique errors.
   @override
   bool operator ==(Object other) =>
       identical(this, other) ||
       other is ParseError &&
           runtimeType == other.runtimeType &&
           message == other.message &&
           line == other.line &&
           column == other.column &&
           expectedToken == other.expectedToken &&
           // Compare relevant parts of actualToken if present
           actualToken?.type == other.actualToken?.type &&
           actualToken?.value == other.actualToken?.value;

   /// Provides a hash code consistent with the equality comparison.
   @override
   int get hashCode =>
       message.hashCode ^
       line.hashCode ^
       column.hashCode ^
       expectedToken.hashCode ^
       actualToken.hashCode; // Hash combines relevant fields
}
