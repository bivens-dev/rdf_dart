// Comments contain known references to identifiers not imported to this file
// ignore_for_file: comment_references

import 'package:meta/meta.dart';
import 'package:rdf_dart/src/model/iri_node.dart';
import 'package:rdf_dart/src/model/rdf_term.dart';
import 'package:rdf_dart/src/model/subject_type.dart';

/// Represents an RDF triple, which is a statement about a resource.
///
/// An RDF triple consists of a [subject], a [predicate], and an [object].
/// The triple asserts that the relationship described by the [predicate]
/// holds between the [subject] and the [object].
///
///   * The [subject] must be a [SubjectTerm] (specifically, an [IRINode] or
///     a [BlankNode]), representing the resource being described.
///   * The [predicate] must be an [IRINode], representing the relationship.
///   * The [object] can be any [RdfTerm] ([IRINode], [BlankNode], [Literal],
///     or [TripleTerm]), representing the value or resource related to the
///     subject.
///
/// Example:
///
/// ```dart
/// // Use the specific Term classes for clarity
/// final subject = IRINode(IRI('http://example.com/person/john'));
/// final predicate = IRINode(IRI('http://xmlns.com/foaf/0.1/knows'));
/// final object = IRINode(IRI('http://example.com/person/jane'));
/// final triple = Triple(subject, predicate, object);
/// print(triple); // Output: http://example.com/person/john http://xmlns.com/foaf/0.1/knows http://example.com/person/jane .
/// ```
@immutable
class Triple {
  /// The subject of this triple.
  ///
  /// The subject is the resource that the triple is describing. It must be a
  /// [SubjectTerm], which restricts it to being either an [IRINode] or a
  /// [BlankNode], according to the RDF specification.
  final SubjectTerm subject;

  /// The predicate of this triple.
  ///
  /// The predicate is the relationship between the [subject] and the [object].
  /// It must be an [IRINode].
  final IRINode predicate;

  /// The object of this triple.
  ///
  /// The object is the value or resource related to the [subject] by the
  /// [predicate]. It can be any concrete [RdfTerm]: an [IRINode], a
  /// [BlankNode], a [Literal], or (in RDF 1.2) a [TripleTerm].
  final RdfTerm object;

  /// Creates a new Triple with the given [subject], [predicate], and [object].
  ///
  /// The [subject] must be an [IRINode] or a [BlankNode].
  /// The [predicate] must be an [IRINode].
  /// The [object] can be any [RdfTerm] ([IRINode], [BlankNode], [Literal], or [TripleTerm]).
  ///
  /// Example:
  /// ```dart
  /// final subject = IRINode(IRI('http://example.com/person/john'));
  /// final predicate = IRINode(IRI('http://xmlns.com/foaf/0.1/knows'));
  /// final object = IRINode(IRI('http://example.com/person/jane'));
  /// final triple = Triple(subject, predicate, object);
  ///
  /// final subjectB = BlankNode();
  /// final predicateB = IRINode(IRI('http://xmlns.com/foaf/0.1/name'));
  /// final objectB = Literal('Anonymous', XSD.string);
  /// final tripleB = Triple(subjectB, predicateB, objectB);
  /// ```
  Triple(this.subject, this.predicate, this.object);

  /// Returns `true` if this triple is a ground triple, `false` otherwise.
  ///
  /// A ground RDF triple is an RDF triple in which no blank nodes appear.
  bool get isGroundTriple {
    return subject.isGroundTerm &&
        predicate.isGroundTerm &&
        object.isGroundTerm;
  }

  @override
  String toString() => '$subject $predicate $object .';

  @override
  int get hashCode => Object.hash(subject, predicate, object);

  @override
  bool operator ==(Object other) =>
      other is Triple &&
      subject == other.subject &&
      predicate == other.predicate &&
      object == other.object;
}
