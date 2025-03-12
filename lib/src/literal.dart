// lib/src/literal.dart
import 'rdf_term.dart';
import 'iri.dart';
import 'term_type.dart';

class Literal extends RdfTerm {
  final String lexicalForm;
  final IRI datatype;
  final String? language;

  Literal(this.lexicalForm, this.datatype, [this.language]);

  @override
  bool get isIRI => false;

  @override
  bool get isBlankNode => false;

  @override
  bool get isLiteral => true;

  @override
  TermType get termType => TermType.literal;

  @override
  String toString() {
    String result = '"$lexicalForm"';
    if (language != null) {
      result += "@$language";
    }
    if (datatype.value != 'http://www.w3.org/2001/XMLSchema#string') {
      result += "^^<$datatype>";
    }
    return result;
  }

  @override
  int get hashCode => Object.hash(lexicalForm, datatype, language);

  @override
  bool operator ==(Object other) =>
      other is Literal &&
      lexicalForm == other.lexicalForm &&
      datatype == other.datatype &&
      language == other.language;
}
