// Comments contain known references to identifiers not imported to this file
// ignore_for_file: comment_references

import 'package:meta/meta.dart';
import 'package:rdf_dart/src/model/term_type.dart';

/// The abstract base class for all RDF terms.
///
/// RDF terms are the fundamental building blocks of RDF data. They can be
/// one of three types: [IRINode], [BlankNode], or [Literal]. This abstract class
/// defines the common properties and methods shared by all RDF terms.
///
/// All concrete RDF term classes (such as [IRINode], [BlankNode], [Literal]
/// and [TripleTerm]) must extend this class and implement its abstract members.
@immutable
abstract class RdfTerm {
  /// Returns `true` if this term is an IRI term, `false` otherwise.
  ///
  /// An IRI term is a term that represents an IRI (Internationalized Resource Identifier)
  /// which is a globally unique identifier for a resource.
  bool get isIRI;

  /// Returns `true` if this term is a blank node, `false` otherwise.
  ///
  /// A blank node is a local identifier for an unnamed resource.
  bool get isBlankNode;

  /// Returns `true` if this term is a literal, `false` otherwise.
  ///
  /// A literal is a data value, such as a string, number, or date.
  bool get isLiteral;

  /// Returns `true` if this term is a triple term, `false` otherwise.
  ///
  /// A triple term is a term that represents a triple.
  bool get isTripleTerm;

  /// Returns the [TermType] of this term.
  ///
  /// The [TermType] enum indicates whether the term is an [IRINode], a
  /// [BlankNode], a [Literal], or a [TripleTerm].
  TermType get termType;

  @override
  int get hashCode;

  @override
  bool operator ==(Object other);
}
