import 'package:meta/meta.dart';
import 'package:rdf_dart/src/rdf_term.dart';
import 'package:rdf_dart/src/term_type.dart';
import 'package:rdf_dart/src/triple.dart';

/// Represents an RDF Triple used as an RDF Term (RDF 1.2).
///
/// In RDF 1.2, an entire RDF triple can function as the subject or, more
/// commonly, the object of another triple. This class represents such a
/// "triple term". It acts as a wrapper around a [Triple] object when that
/// triple is used in the role of a term within another statement.
///
/// This distinguishes it from the [Triple] class, which represents the
/// fundamental structure of a subject-predicate-object statement itself.
///
/// See: <https://www.w3.org/TR/rdf12-concepts/#section-triple-terms>
@immutable
class TripleTerm extends RdfTerm {
  /// The underlying RDF [Triple] that this term represents.
  final Triple triple;

  /// Creates a new [TripleTerm] that wraps the given [triple].
  ///
  /// The provided [triple] is the RDF statement being used as a term.
  TripleTerm(this.triple);

  @override
  bool get isIRI => false;

  @override
  bool get isBlankNode => false;

  @override
  bool get isLiteral => false;

  @override
  bool get isTripleTerm => true;

  @override
  TermType get termType => TermType.tripleTerm;

  @override
  int get hashCode => triple.hashCode;

  /// Compares this [TripleTerm] to another object for equality.
  ///
  /// Two [TripleTerm] instances are considered equal if their wrapped [triple]
  /// instances are equal.
  @override
  bool operator ==(Object other) =>
      other is TripleTerm && triple == other.triple;

  /// Returns a string representation of the triple term.
  ///
  /// Follows a Turtle-like syntax `<< subject predicate object . >>`.
  @override
  String toString() => '<< $triple >>';
}
