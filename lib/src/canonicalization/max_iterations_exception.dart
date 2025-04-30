/// Represents an error that occurs when the RDF canonicalization process
/// takes too long and exceeds a predefined limit on the number of iterations.
///
/// This typically happens with very complex RDF graphs or datasets designed
/// maliciously to consume excessive resources (a "poison" dataset). Throwing
/// this exception prevents the process from running indefinitely.
class MaxIterationsExceededException implements Exception {
  /// The specific limit for the number of iterations that was reached.
  final num maxIterations;

  /// Creates a new [MaxIterationsExceededException].
  ///
  /// Requires the [maxIterations] limit that was configured and exceeded.
  const MaxIterationsExceededException(this.maxIterations);

  @override
  String toString() =>
      'MaxIterationsExceededException: Maximum deep iterations exceeded ($maxIterations). Possible dataset poisoning attempt or extremely complex graph.';
}
