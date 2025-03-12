// Comments contain known references to identifiers not imported to this file
// ignore_for_file: comment_references

import 'package:meta/meta.dart';
import 'package:rdf_dart/src/iri.dart';
import 'package:rdf_dart/src/rdf_term.dart';

/// Represents an RDF triple, which is a statement about a resource.
///
/// An RDF triple consists of a [subject], a [predicate], and an [object].
/// The triple asserts that the relationship described by the [predicate]
/// holds between the [subject] and the [object].
///
/// - The [subject] is an [RdfTerm] that represents the resource being described.
/// - The [predicate] is an [IRI] that represents the relationship between the
///   subject and the object.
/// - The [object] is an [RdfTerm] that represents the value or resource
///   related to the subject by the predicate.
///
/// Example:
///
/// ```dart
/// final subject = IRI('http://example.com/person/john');
/// final predicate = IRI('http://example.com/relation/knows');
/// final object = IRI('http://example.com/person/jane');
/// final triple = Triple(subject, predicate, object);
/// print(triple); // Output: http://example.com/person/john http://example.com/relation/knows http://example.com/person/jane .
/// ```
@immutable
class Triple {
  /// The subject of this triple.
  ///
  /// The subject is the resource that the triple is describing. It must be an
  /// [RdfTerm], which can be an [IRI] or a [BlankNode].
  final RdfTerm subject;

  /// The predicate of this triple.
  ///
  /// The predicate is the relationship between the [subject] and the [object].
  /// It must be an [IRI].
  final IRI predicate;

  /// The object of this triple.
  ///
  /// The object is the value or resource related to the [subject] by the
  /// [predicate]. It must be an [RdfTerm], which can be an [IRI], a
  /// [BlankNode], or a [Literal].
  final RdfTerm object;

  /// Creates a new Triple with the given [subject], [predicate], and [object].
  ///
  /// The [subject] is the resource being described.
  /// The [predicate] is the relationship between the subject and the object.
  /// The [object] is the value or resource related to the subject by the predicate.
  ///
  /// Example:
  /// ```dart
  /// final subject = IRI('http://example.com/person/john');
  /// final predicate = IRI('http://example.com/relation/knows');
  /// final object = IRI('http://example.com/person/jane');
  /// final triple = Triple(subject, predicate, object);
  /// ```
  Triple(this.subject, this.predicate, this.object);

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
