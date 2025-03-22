# RDF.dart: A Dart Library for Working with RDF

[![Pub Version](https://img.shields.io/pub/v/rdf_dart)](https://pub.dev/packages/rdf_dart)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

RDF.dart is a Dart library designed to make it easy to work with [RDF (Resource Description Framework)](https://www.w3.org/RDF/) data structures and concepts. It provides core data structures for representing RDF triples, graphs, datasets, and literals, along with utilities for managing datatypes and IRIs.

## Features

*   **Core RDF Data Structures:**
    *   `IRI`: Represents an Internationalized Resource Identifier (IRI).
    *   `Literal`: Represents an RDF literal with datatype and optional language tag.
    *   `BlankNode`: Represents an RDF blank node.
    *   `RdfTerm`:  Represent an abstract RDF term.
    *   `Triple`: Represents an RDF triple (subject, predicate, object).
    *   `Graph`: Represents a collection of RDF triples.
    *   `Dataset`: Represents a collection of named graphs.
*   **Datatype Handling:**
    *   A `DatatypeRegistry` for managing different datatypes and their parsers/formatters.
    *   Built-in support for common datatypes like `xsd:string`, `xsd:integer`, `xsd:double`, `xsd:dateTime`, and `xsd:boolean`.
    *   Extensible: Register your custom datatypes easily.
*   **IRI Validation:**
    * `IriValidator`: provide a way to validate IRI.
    * Parse an IRI string to get the different parts.
    * Check if an IRI is valid or not.
    * Check if a specific part of the IRI is valid or not.
*   **Error Handling:**
    *   Clear exceptions (e.g., `InvalidIRIException`, `FormatException`) for invalid data.
*  **Immutable**
    *  `Literal` objects are immutable.
* **Well tested**
    * The core features are well tested.

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
  final subject = IRI('http://example.org/subject');
  final predicate = IRI('http://example.org/predicate');
  final object = IRI('http://example.org/object');

  // Create a string literal
  final stringLiteral = Literal('Hello, world!', IRI('http://www.w3.org/2001/XMLSchema#string'));
  print(stringLiteral); // Output: "Hello, world!"

  // Create a triple
  final triple = Triple(subject, predicate, object);

  // Create a Dataset
  final dataset = Dataset();

  // Add the Triple to the Dataset
  dataset.defaultGraph.add(triple);
}
```

## Development

```bash
# Install dependencies
npm install || pip install -r requirements.txt
# Run tests
npm test || pytest
```
