/// Enum representing the available RDF Dataset canonicalization algorithms.
enum CanonicalizationAlgorithm {
  /// RDF Dataset Canonicalization 1.0 (RDFC-1.0)
  /// Spec: https://www.w3.org/TR/rdf-canon/
  rdfc10,

  /// Universal RDF Dataset Normalization Algorithm 2015 (URDNA2015)
  /// Spec: https://www.w3.org/community/reports/credentials/CG-FINAL-rdf-dataset-canonicalization-20221009/
  urdna2015,

  /// Universal RDF Graph Normalization Algorithm 2012 (URGNA2012)
  /// Note: This algorithm is generally considered superseded and is
  /// included as a placeholder; implementation is not planned initially.
  urgna2012,
}
