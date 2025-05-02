// ignore_for_file: avoid_print

import 'package:iri/iri.dart';
import 'package:rdf_dart/rdf_dart.dart';

void main() {
  print('--- Basic RDF Term Creation ---');

  // Create an IRI Term (used for subjects, predicates, objects, graph names)
  final iriSubj = IRINode(IRI('http://example.com/resource'));
  final iriPred = IRINode(IRI('http://xmlns.com/foaf/0.1/name'));
  final iriObj = IRINode(IRI('http://example.com/another_resource'));
  final graphName = IRINode(IRI('http://example.com/graph1'));

  print('IRI Term (Subject): $iriSubj');
  print('IRI Term (Predicate): $iriPred');
  print('IRI Term (Object): $iriObj');
  print('IRI Term (Graph Name): $graphName');

  // Create a Blank Node (used for subjects or objects)
  // Can be created with or without a specific ID
  final blankNode1 = BlankNode(); // Auto-generated ID
  final blankNode2 = BlankNode('bnode123'); // Specific ID
  print('Blank Node (Auto ID): $blankNode1');
  print('Blank Node (Specific ID): $blankNode2');

  // Create Literals (used for objects)
  // Simple literal (defaults to xsd:string)
  final literalSimple = Literal('Alice', XSD.string);
  // Literal with explicit datatype (xsd:string)
  final literalString = Literal('Hello', XSD.string);
  // Literal with language tag
  final literalLang = Literal('Bonjour', RDF.langString, 'fr');
  // Literal with a different datatype (e.g., integer)
  final literalInt = Literal('30', XSD.integer);
  // Literal with boolean datatype
  final literalBool = Literal('true', XSD.boolean);
  print('Literal (Simple String): $literalSimple');
  print('Literal (Explicit String): $literalString');
  print('Literal (Language Tag): $literalLang');
  print('Literal (Integer): $literalInt');
  print('Literal (Boolean): $literalBool');

  print('\n--- Basic Triple Creation ---');

  // Create standard Triples
  final triple1 = Triple(
    iriSubj,
    iriPred,
    literalSimple,
  ); // Subject knows Name "Alice"
  final triple2 = Triple(
    iriSubj,
    IRINode(IRI('http://xmlns.com/foaf/0.1/knows')),
    blankNode2,
  ); // Subject knows Someone (blank node)
  final triple3 = Triple(
    blankNode2,
    iriPred,
    Literal('Bob', XSD.string),
  ); // That Someone's Name is "Bob"

  print('Triple 1: $triple1');
  print('Triple 2: $triple2');
  print('Triple 3: $triple3');

  print('\n--- RDF 1.2 Triple Term Creation ---');

  // Create an inner triple that will be used as an object
  final innerTriple = Triple(
    iriSubj, // Alice's resource
    IRINode(IRI('http://example.com/confidence')),
    literalInt, // Confidence "30"^^xsd:integer
  );
  print('Inner Triple structure: $innerTriple');

  // Create a TripleTerm by wrapping the inner triple
  final tripleTermObj = TripleTerm(innerTriple);
  print('TripleTerm object: $tripleTermObj');

  // Create an outer triple where the object IS the TripleTerm
  // This triple makes a statement ABOUT the inner triple
  final outerTriple = Triple(
    blankNode1, // Some context
    IRINode(IRI('http://example.com/assertedBy')), // assertedBy relation
    IRINode(IRI('http://example.com/source/sensorA')), // Asserted by Sensor A
    // The object is the statement about Alice's confidence
    // NOTE: For a triple to *contain* a triple term, its object needs to be TripleTerm
    // We'll create a *new* triple *about* the tripleTermObj
  );
  print('Outer Triple (with TripleTerm object): $outerTriple');

  // Let's make a statement *about* the innerTriple's assertion
  // e.g., "Sensor A reported that <resource> has confidence 30"
  final tripleAboutTriple = Triple(
    IRINode(IRI('http://example.com/source/sensorA')), // Sensor A
    IRINode(IRI('http://example.com/reported')), // reported
    tripleTermObj, // the statement << <resource> <confidence> "30"^^xsd:integer . >>
  );

  print('Triple ABOUT the inner triple: $tripleAboutTriple');

  print('\n--- Dataset Usage ---');

  // Create a Dataset
  final dataset = Dataset();

  // Add standard triples to the default graph
  dataset.defaultGraph.add(triple1);
  dataset.defaultGraph.addAll([triple2, triple3]);

  // Add the triple containing the TripleTerm to a named graph
  final tempGraph = Graph();
  tempGraph.add(tripleAboutTriple);
  dataset.addNamedGraph(graphName, tempGraph);

  // You could also add the inner triple itself if it's asserted separately
  // dataset.defaultGraph.add(innerTriple);

  print('\nDataset Default Graph Triples:');
  for (final t in dataset.defaultGraph.triples) {
    print(t);
  }

  print('\nDataset Named Graph (${graphName.value}) Triples:');
  final namedGraph = dataset.namedGraphs[graphName];
  if (namedGraph != null) {
    for (final t in namedGraph.triples) {
      print(t);
    }
  } else {
    print('Named graph not found!');
  }
}
