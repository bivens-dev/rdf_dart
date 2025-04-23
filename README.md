# RDF.dart: A Dart Library for Working with RDF

[![Pub Version](https://img.shields.io/pub/v/rdf_dart)](https://pub.dev/packages/rdf_dart)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

RDF.dart is a Dart library designed to make it easy to work with [RDF (Resource Description Framework)](https://www.w3.org/RDF/) data structures and concepts. It provides core data structures for representing RDF triples, graphs, datasets, and literals, along with utilities for managing datatypes and IRIs.

## Features

*   **Core RDF 1.2 Data Structures:**
    *   `IRI`: Represents an Internationalized Resource Identifier string.
    *   `IRITerm`: Represents an IRI used as an RDF term (subject, predicate, object, or graph name).
    *   `Literal`: Represents an RDF literal with datatype and optional language tag.
    *   `BlankNode`: Represents an RDF blank node.
    *   `TripleTerm`: Represents an RDF triple used as an RDF term (subject or object) as defined in RDF 1.2.
    *   `RdfTerm`: The abstract base class for all RDF terms (`IRITerm`, `BlankNode`, `Literal`, `TripleTerm`).
    *   `Triple`: Represents an RDF triple (subject, predicate, object - where object can be any `RdfTerm`, including a `TripleTerm`).
    *   `Graph`: Represents a collection of RDF triples.
    *   `Dataset`: Represents a collection consisting of one default graph and zero or more named graphs.
*   **Datatype Handling:**
    *   Built-in support and validation for common XSD datatypes (e.g., `xsd:string`, `xsd:integer`, `xsd:double`, `xsd:dateTime`, `xsd:boolean`, `xsd:date`, `xsd:duration`, and more). See `XSD` class.
    *   Support for `rdf:langString`.
    *   *(Planned)* `DatatypeRegistry` for managing custom datatypes.
*   **IRI Validation & Parsing:**
    *   Robust IRI parsing based on RFC 3987.
    *   Validation checks for IRIs.
    *   Access to IRI components (scheme, authority, path, query, fragment).
*   **N-Triples & N-Quads Serialization/Deserialization:**
    *   Provides `nTriplesCodec` and `nQuadsCodec`, a streaming encoder/decoder compliant with the `dart:convert` Codec interface.
    *   Easily encode lists of `Triple` objects to N-Triples strings and decode N-Triples strings back into `Triple` objects.
    *   Easily encode `Dataset` objects to N-Quads strings and decode N-Quads strings back into `Dataset` objects.
    *   Integrates seamlessly with Dart's I/O streams for efficient processing of large files.
*   **Immutability:** Core data structures (`IRITerm`, `BlankNode`, `Literal`, `TripleTerm`, `Triple`, `IRI`) are immutable.
*   **Well-Tested:** Core features have comprehensive unit tests.

## Getting Started

1.  **Add the Dependency:**
    Open your `pubspec.yaml` file and add `rdf_dart` to your dependencies:

    ```yaml
    dependencies:
      rdf_dart: ^1.0.0 # Replace with the latest version
    ```

2.  **Install the Package:**
    Run this command in your terminal:

    ```bash
    dart pub get
    ```

3.  **Import the Library:**
    In your Dart code, import the `rdf_dart` library:

    ```dart
    import 'package:rdf_dart/rdf_dart.dart';
    ```

## Usage

Here's a simple example demonstrating how to create RDF objects:

```dart
import 'package:rdf_dart/rdf_dart.dart';

void main() {
  // Create some IRIs
  final subject = IRITerm(IRI('http://example.org/subject'));
  final predicate = IRITerm(IRI('http://example.org/predicate'));
  final object = IRITerm(IRI('http://example.org/object'));

  // Create a string literal
  final stringLiteral = Literal('Hello, world!', XSD.string);
  print(stringLiteral); // Output: "Hello, world!"

  // Create a triple
  final triple = Triple(subject, predicate, object);

  // Create a Dataset
  final dataset = Dataset();

  // Add the Triple to the Dataset
  dataset.defaultGraph.add(triple);

  // Encode the triple using the N-Triples codec
  final nTriplesString = nTriplesCodec.encode([triple]);
  print(nTriplesString);
  // Output: <http://example.org/subject> <http://example.org/predicate> <http://example.org/object> .

  // Decode the N-Triples string
  final decodedTriples = nTriplesCodec.decode(nTriplesString);
  print(decodedTriples.first == triple); // Output: true
}
```