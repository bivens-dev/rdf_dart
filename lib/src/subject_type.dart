// ignore_for_file: comment_references

import 'package:rdf_dart/src/rdf_term.dart';

/// Abstract marker class for RDF terms that can function as the subject of an
/// RDF [Triple].
///
/// According to the RDF 1.2 specification, the subject of a triple must be
/// either an [IRITerm] or a [BlankNode]. This abstract class is implemented
/// by those specific term types (`IRITerm`, `BlankNode`) to allow for
/// compile-time type checking when constructing [Triple] instances.
///
/// This ensures that attempts to create a [Triple] with an invalid subject type
/// (like a [Literal] or [TripleTerm]) are caught by the Dart type system.
///
/// It does not introduce a new type of RDF term itself, but rather classifies
/// existing term types based on their valid roles within a triple.
///
/// See: <https://www.w3.org/TR/rdf12-concepts/#section-triples>
abstract class SubjectTerm extends RdfTerm {}