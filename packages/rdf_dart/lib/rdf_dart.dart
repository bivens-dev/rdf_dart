// Comments contain known references to identifiers not imported to this file
// ignore_for_file: comment_references

/// Support for working with RDF (Resource Description Framework) data in Dart.
///
/// This library provides classes and utilities for representing and manipulating
/// RDF data structures, including:
///
/// *   **Terms:** [IRINode], [BlankNode], [Literal], [RdfTerm], [TripleTerm]
/// *   **Triples:** [Triple]
/// *   **IRIs:**: [IRI]
/// *   **Graphs:** [Graph]
/// *   **Datasets:** [Dataset]
/// *   **Exceptions:** [RDFException], [InvalidTermException], [DatatypeNotFoundException],
///     [InvalidLexicalFormException], [InvalidLanguageTagException],
///     [LiteralConstraintException]
///
/// **Terms**
///
/// RDF data is built from *terms*, which can be one of three types:
///
/// *   **IRIs (Internationalized Resource Identifiers):** Used to name things
///     (resources). See [IRI].
/// *   **Blank Nodes:** Anonymous nodes within an RDF graph, used to represent
///     things without a specific IRI. See [BlankNode].
/// *   **Literals:** Data values, like strings, numbers, and dates. See
///     [Literal].
///
/// The [RdfTerm] class is an abstract base class for all term types.
/// The [TermType] enum is used to represent the type of an RDF term.
///
/// **Triples**
///
/// RDF data is expressed as *triples*, which are statements about resources.
/// Each triple consists of a subject, a predicate, and an object. See [Triple].
///
/// **Graphs**
///
/// An RDF *graph* is a collection of RDF triples. See [Graph].
///
/// **Datasets**
///
/// An RDF *dataset* is a collection of RDF graphs. It contains a default graph
/// and zero or more named graphs. See [Dataset].
///
/// **Usage**
///
/// To use this library, add `rdf_dart` as a dependency in your `pubspec.yaml` file.
///
/// ```yaml
/// dependencies:
///   rdf_dart: ^1.0.0 # Or the latest version
/// ```
///
/// Then, import the library in your Dart code:
///
/// ```dart
/// import 'package:rdf_dart/rdf_dart.dart';
///
/// void main() {
///   // Create some IRIs
///   final subject = IRI('http://example.com/resource');
///   final predicate = IRI('http://example.com/property');
///   print(subject);
///
///   // Create a Blank Node
///   final blankNode = BlankNode();
///   print(blankNode);
///
///   // Create a Literal
///   final literal = Literal("Hello", XSD.string);
///   print(literal);
///
///   // Create a Triple
///   final triple = Triple(IRINode(subject), IRINode(predicate), literal);
///   print(triple);
/// }
/// ```
library;

export 'src/canonicalization/canonicalizer.dart';
export 'src/codec/nquads/nquads_codec.dart';
export 'src/codec/ntriples/ntriples_codec.dart';
export 'src/exceptions/exceptions.dart';
export 'src/model/blank_node.dart';
export 'src/model/dataset.dart';
export 'src/model/graph.dart';
export 'src/model/iri_term.dart';
export 'src/model/literal.dart';
export 'src/model/rdf_term.dart';
export 'src/model/subject_type.dart';
export 'src/model/term_type.dart';
export 'src/model/triple.dart';
export 'src/model/triple_term.dart';
export 'src/vocab/rdf_vocab.dart';
export 'src/vocab/xsd_vocab.dart';
