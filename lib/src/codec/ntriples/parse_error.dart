/// Represents a syntax error encountered during N-Triples parsing.
///
/// Contains information about the error message, the location (line and column)
/// where the error occurred, and optionally the expected token type versus the
/// actual token found at that location.
class ParseError implements Exception {
  /// A human-readable message describing the parse error.
  final String message;

  /// The line number (1-based) in the input string where the error occurred.
  final int line;

  /// The column number (1-based) in the input string where the error occurred.
  final int column;

  /// Creates a representation of a parse error.
  ///
  /// Requires a [message], the [line] number, and the [column] number.
  const ParseError(this.message, this.line, this.column);

  /// Provides a user-friendly string representation of the parse error,
  /// including location and token details if available.
  @override
  String toString() {
    final location = 'L$line:C$column';
    return 'Parse Error ($location): $message';
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
          column == other.column;

  /// Provides a hash code consistent with the equality comparison.
  @override
  int get hashCode => message.hashCode ^ line.hashCode ^ column.hashCode; // Hash combines relevant fields
}
