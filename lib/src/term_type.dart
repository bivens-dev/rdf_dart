/// Represents the type of an RDF term according to RDF 1.2.
///
/// RDF terms are the components of RDF triples and can be one of four types:
///
/// * [iri]: An Internationalized Resource Identifier (IRI), used to uniquely
///     identify resources.
/// * [blankNode]: A blank node, representing an unnamed resource, scoped
///     locally.
/// * [literal]: A literal, representing a data value, such as a string,
///     number, or date, potentially with a language tag or datatype.
/// * [tripleTerm]: An RDF triple that is itself used as a term (typically
///     as the object) in another triple. Introduced in RDF 1.2.
enum TermType {
  /// An Internationalized Resource Identifier (IRI).
  iri,

  /// A blank node.
  blankNode,

  /// A literal value (e.g., string, number, date).
  literal,

  /// An RDF triple used as a term (RDF 1.2).
  tripleTerm
}