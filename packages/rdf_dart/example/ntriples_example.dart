// Ignore lint directives for this example
// ignore_for_file: avoid_print

import 'package:iri/iri.dart';
import 'package:rdf_dart/rdf_dart.dart';

// Example demonstrating encoding various RDF concepts into N-Triples format.
void main() {
  // --- Define some common terms ---
  ex(String local) =>
      IRI('http://example.org/$local'); // Helper for example IRIs
  final name = IRINode(ex('name'));
  final knows = IRINode(ex('knows'));
  final age = IRINode(ex('age'));
  final alice = IRINode(ex('alice'));
  final bob = IRINode(ex('bob'));
  final charlie = BlankNode(); // Create a blank node for someone anonymous

  // --- Create a list of diverse triples ---
  final triples = <Triple>[
    // Simple statement: Alice knows Bob
    Triple(alice, knows, bob),

    // Literal statement: Alice's name is "Alice" (simple string)
    Triple(alice, name, Literal('Alice', XSD.string)), // Defaults to xsd:string
    // Literal with a language tag: Bob's name in French
    Triple(bob, name, Literal('Bob', RDF.langString, 'fr')),

    // Literal with a datatype: Alice's age is 30 (integer)
    Triple(alice, age, Literal('30', XSD.integer)),

    // Literal with a datatype: Bob is fictional (boolean)
    Triple(bob, IRINode(ex('isFictional')), Literal('true', XSD.boolean)),

    // Literal with characters needing escaping
    Triple(
      alice,
      IRINode(ex('comment')),
      Literal(r'This has a "quote" and a \ backslash.', XSD.string),
    ),

    // Blank node as subject: Someone knows Alice
    Triple(charlie, knows, alice),

    // Blank node as object: Alice knows someone
    Triple(alice, knows, charlie),

    // Reification: Stating that the triple "alice knows bob" is true
    // Note: RDF 1.2 recommends using rdf:reifies for this structure
    Triple(
      IRINode(ex('statement1')), // Subject identifying the reification
      IRINode(RDF.type), // Indicate this is a statement
      IRINode(
        IRI('http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement'),
      ), // The class of RDF statements
    ),
    Triple(
      IRINode(ex('statement1')),
      IRINode(RDF.subject), // The subject of the reified triple
      alice,
    ),
    Triple(
      IRINode(ex('statement1')),
      IRINode(RDF.predicate), // The predicate of the reified triple
      knows,
    ),
    Triple(
      IRINode(ex('statement1')),
      IRINode(RDF.object), // The object of the reified triple
      bob,
    ),

    // RDF-Star / Triple Term (RDF 1.2): Asserting something *about* a triple
    // Example: Charlie says that "alice knows bob"
    Triple(
      charlie, // Subject is the blank node 'charlie'
      IRINode(ex('says')), // Predicate
      TripleTerm(
        // Object is the triple "alice knows bob"
        Triple(alice, knows, bob),
      ),
    ),

    // Nested Triple Term: Alice says that (Charlie says that (alice knows bob))
    Triple(
      alice,
      IRINode(ex('says')),
      TripleTerm(
        Triple(
          charlie,
          IRINode(ex('says')),
          TripleTerm(Triple(alice, knows, bob)),
        ),
      ),
    ),
  ];

  // --- Encode the triples to N-Triples ---
  print('--- Encoding to N-Triples ---');
  // The nTriplesCodec handles converting the list of Triple objects
  // into the standard N-Triples string format, including correct
  // escaping and formatting for IRIs, blank nodes, literals, and triple terms.
  final nTriplesString = nTriplesCodec.encode(triples);
  print(nTriplesString);

  // --- Optional: Decode the N-Triples string back to triples ---
  print('\n--- Decoding N-Triples string back ---');
  try {
    final decodedTriples = nTriplesCodec.decode(nTriplesString);
    print('Successfully decoded ${decodedTriples.length} triples.');
    // You could optionally compare decodedTriples to the original 'triples' list,
    // but note that blank node identifiers might differ after a round trip.
    // decodedTriples.forEach(print); // Uncomment to print each decoded triple
  } on FormatException catch (e) {
    print('Error decoding N-Triples: $e');
  }
}
