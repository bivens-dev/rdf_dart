/// Represents the type of an RDF term.
///
/// RDF terms can be one of three types:
///
/// *   [iri]: An Internationalized Resource Identifier (IRI), which is used
///     to name things.
/// *   [blankNode]: A blank node, which is a local identifier for an
///     unnamed resource.
/// *   [literal]: A literal, which represents a data value, such as a string,
///     number, or date.
enum TermType {
  /// An Internationalized Resource Identifier (IRI).
  iri,

  /// A blank node.
  blankNode,

  /// A literal value.
  literal,
}
