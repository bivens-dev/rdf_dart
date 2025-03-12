import 'package:rdf_dart/rdf_dart.dart';

void main() {
  // Create an IRI
  final subject = IRI('http://example.com/resource');

  // Create an IRI
  final perdicate = IRI('http://example.com/predicate');

  // Create a Literal
  final object = Literal(
    'Hello',
    IRI('http://www.w3.org/2001/XMLSchema#string'),
  );

  // Create a Triple
  final triple = Triple(subject, perdicate, object);

  // Create a Dataset
  final dataset = Dataset();

  // Add the Triple to the Dataset
  dataset.defaultGraph.add(triple);
}
