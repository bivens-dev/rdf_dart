import 'package:rdf_dart/src/canonicalization/max_iterations_exception.dart'
    show MaxIterationsExceededException;

/// Controls the computational complexity allowed during the RDF canonicalization
/// process, specifically related to the deep comparison of blank nodes.
///
/// RDF canonicalization algorithms, like RDF Dataset Canonicalization 1.0 (RDfc10),
/// sometimes need to perform complex comparisons, especially when dealing with
/// graphs containing many blank nodes (nodes without a fixed IRI). In certain
/// scenarios, particularly with graphs designed to be computationally expensive
/// (so-called "poison" graphs), these comparisons can lead to excessive
/// processing time.
///
/// This enum allows setting limits on how much computational effort (measured
/// in terms of iterations related to the number of non-unique blank nodes, `n`)
/// is permitted. Setting a limit helps prevent denial-of-service scenarios
/// caused by overly complex or malicious datasets. If the configured limit is
/// exceeded during processing, a [MaxIterationsExceededException] is thrown.
///
/// The actual maximum number of iterations is calculated based on the
/// [maxWorkFactor] and the number of non-unique blank nodes (`n`) in the
/// dataset using a formula roughly equivalent to `n ^ maxWorkFactor`.
enum ComplexityLimits implements Comparable<ComplexityLimits> {
  /// **Strictest:** Disallows deep inspection entirely (O(1)).
  ///
  /// This setting prevents any deep comparison iterations. It's the most
  /// restrictive and might prevent canonicalization of graphs requiring blank
  /// node label assignment through comparison.
  strictest(maxWorkFactor: 0),

  /// **High:** Limits deep iterations to linear complexity (O(n)).
  ///
  /// This is often the default setting. It allows a number of iterations
  /// proportional to the number of non-unique blank nodes. Provides a good
  /// balance between performance and the ability to handle moderately complex
  /// graphs.
  high(maxWorkFactor: 1),

  /// **Medium:** Limits deep iterations to quadratic complexity (O(n^2)).
  ///
  /// Allows significantly more iterations than `high`, suitable for more complex
  /// graphs but with a higher potential processing time.
  medium(maxWorkFactor: 2),

  /// **Low:** Limits deep iterations to cubic complexity (O(n^3)).
  ///
  /// This setting permits a very high number of iterations. Use this level
  /// cautiously, as it can handle very complex graphs (including potential
  /// "poison" graphs) but may require substantial computational resources and time.
  low(maxWorkFactor: 3),

  /// **None:** Imposes no limitation on deep iterations.
  ///
  /// This effectively disables the complexity check, allowing the algorithm to
  /// run as many iterations as needed. While this ensures canonicalization for
  /// any graph, it carries the risk of extremely long processing times or even
  /// effective non-termination for "poison" graphs. Corresponds to
  /// `maxWorkFactor = infinity`.
  none(maxWorkFactor: double.infinity);

  const ComplexityLimits({required this.maxWorkFactor});

  /// The factor used to calculate the maximum allowed deep iterations.
  ///
  /// The maximum number of iterations allowed is calculated based on this factor
  /// and the number of non-unique blank nodes (`n`) in the input dataset,
  /// roughly following the formula: `max_iterations = n ^ maxWorkFactor`.
  ///
  /// - `0`: Corresponds to `strictest` (0 iterations).
  /// - `1`: Corresponds to `high` (O(n) iterations).
  /// - `2`: Corresponds to `medium` (O(n^2) iterations).
  /// - `3`: Corresponds to `low` (O(n^3) iterations).
  /// - `infinity`: Corresponds to `none` (unlimited iterations).
  final num maxWorkFactor;

  @override
  int compareTo(ComplexityLimits other) =>
      maxWorkFactor.compareTo(other.maxWorkFactor);
}
