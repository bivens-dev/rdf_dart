// Comments contain known references to identifiers not imported to this file 
// ignore_for_file: comment_references

import 'package:rdf_dart/src/term_type.dart';

/// The abstract base class for all RDF terms.
///
/// RDF terms are the fundamental building blocks of RDF data. They can be
/// one of three types: [IRI], [BlankNode], or [Literal]. This abstract class
/// defines the common properties and methods shared by all RDF terms.
///
/// All concrete RDF term classes (such as [IRI], [BlankNode], and [Literal])
/// must extend this class and implement its abstract members.
abstract class RdfTerm {
  /// Returns `true` if this term is an IRI, `false` otherwise.
  ///
  /// An IRI (Internationalized Resource Identifier) is a globally unique
  /// identifier for a resource.
  bool get isIRI;

  /// Returns `true` if this term is a blank node, `false` otherwise.
  ///
  /// A blank node is a local identifier for an unnamed resource.
  bool get isBlankNode;

  /// Returns `true` if this term is a literal, `false` otherwise.
  ///
  /// A literal is a data value, such as a string, number, or date.
  bool get isLiteral;

  /// Returns the [TermType] of this term.
  ///
  /// The [TermType] enum indicates whether the term is an [IRI], a
  /// [BlankNode], or a [Literal].
  TermType get termType;

  @override
  int get hashCode;

  @override
  bool operator ==(Object other);
}
