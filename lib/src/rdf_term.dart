import 'term_type.dart';

abstract class RdfTerm {
  bool get isIRI;
  bool get isBlankNode;
  bool get isLiteral;
  TermType get termType;

  @override
  int get hashCode;

  @override
  bool operator ==(Object other);
}
