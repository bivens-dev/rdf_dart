import 'rdf_term.dart';
import 'iri.dart';

class Triple {
  final RdfTerm subject;
  final IRI predicate;
  final RdfTerm object;

  Triple(this.subject, this.predicate, this.object);

  @override
  String toString() => "$subject $predicate $object .";

  @override
  int get hashCode => Object.hash(subject, predicate, object);

  @override
  bool operator ==(Object other) =>
      other is Triple &&
      subject == other.subject &&
      predicate == other.predicate &&
      object == other.object;
}
