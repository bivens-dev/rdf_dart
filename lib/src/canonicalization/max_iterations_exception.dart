/// Exception thrown when the canonicalization process exceeds the configured
/// maximum number of deep iterations allowed, typically indicating a potentially
/// complex or "poison" dataset.
class MaxIterationsExceededException implements Exception {
  /// The maximum number of iterations that was configured.
  final num maxIterations;

  const MaxIterationsExceededException(this.maxIterations);

  @override
  String toString() =>
      'MaxIterationsExceededException: Maximum deep iterations exceeded ($maxIterations). Possible dataset poisoning attempt or extremely complex graph.';
}
