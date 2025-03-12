import 'rdf_term.dart';
import 'package:uuid/uuid.dart';

import 'term_type.dart';

class BlankNode extends RdfTerm {
  final String id;

  BlankNode([String? id]) : id = id ?? const Uuid().v4();

  @override
  bool get isIRI => false;

  @override
  bool get isBlankNode => true;

  @override
  bool get isLiteral => false;

  @override
  TermType get termType => TermType.blankNode;

  @override
  String toString() => "_:$id";

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is BlankNode && id == other.id;
}
