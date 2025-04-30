/// Used to calculate a maximum number of deep iterations based 
/// on the number of non-unique blank nodes.
enum ComplexityLimits implements Comparable<ComplexityLimits> {
  /// Deep inspection disallowed.
  strictest(maxWorkFactor: 0),
  /// Limit deep iterations to O(n). (default)
  high(maxWorkFactor: 1),
  /// Limit deep iterations to O(n^2).
  medium(maxWorkFactor: 2),
  /// Limit deep iterations to O(n^3). Values at this level or higher will 
  /// allow processing of complex "poison" graphs but may take significant 
  /// amounts of computational resources.
  low(maxWorkFactor: 3),
  /// No limitation.
  none(maxWorkFactor: double.infinity);

  const ComplexityLimits({required this.maxWorkFactor});

  /// how many times the blank node deep comparison algorithm can be run 
  /// to assign blank node labels before throwing an error.
  final num maxWorkFactor;

  @override
  int compareTo(ComplexityLimits other) =>
      maxWorkFactor.compareTo(other.maxWorkFactor);
}
