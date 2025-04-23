/// Represents a syntax error encountered during N-Triples or N-Quads parsing.
      ///
/// Contains information about the error message, the location (line and column)
/// where the error occurred.
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
  /// including location.
  @override
  String toString() {
    final location = 'L$line:C$column';
    return 'Parse Error ($location): $message';
  }

  /// Allows comparing ParseError objects for equality.
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
  int get hashCode => message.hashCode ^ line.hashCode ^ column.hashCode;
}
