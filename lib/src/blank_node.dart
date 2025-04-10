import 'package:meta/meta.dart';
import 'package:rdf_dart/src/rdf_term.dart';
import 'package:rdf_dart/src/term_type.dart';
import 'package:uuid/uuid.dart';

/// Represents a blank node in an RDF graph.
///
/// Blank nodes are used to represent resources that do not have a globally unique
/// identifier (IRI). They are locally scoped within the RDF graph and are often
/// used for existential quantification or to represent unnamed or anonymous
/// resources.
///
/// Blank nodes are identified by a unique string identifier, which can be
/// provided by the user or automatically generated as a UUID. The identifier
/// is only unique within the scope of the data it is defined, not globally.
@immutable
class BlankNode extends RdfTerm {
  /// The unique identifier for this blank node.
  ///
  /// This identifier is a string that is unique within the scope of the data
  /// it is defined. If no identifier is provided when creating the [BlankNode],
  /// a new UUID will be generated and used as the identifier.
  final String id;

  /// Creates a new Blank Node.
  ///
  /// If no [id] is provided, a new UUID will be generated.
  BlankNode([String? id]) : id = id ?? const Uuid().v4();

  /// Returns `false` as this is not an IRI.
  ///
  /// Blank Nodes are not IRIs.
  @override
  bool get isIRI => false;

  /// Returns `true` as this is a Blank Node.
  ///
  /// This indicates that the term is a Blank Node.
  @override
  bool get isBlankNode => true;

  @override
  bool get isLiteral => false;

  @override
  bool get isTripleTerm=> false;

  @override
  TermType get termType => TermType.blankNode;

  @override
  String toString() => '_:$id';

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is BlankNode && id == other.id;
}
