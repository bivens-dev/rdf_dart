import 'dart:convert';

import 'package:rdf_dart/rdf_dart.dart';

/// {@template ntriples_parser}
/// A parser for the N-Triples format.
///
/// This class extends [Converter] to parse N-Triples strings into a Set of
/// [Triple] objects. It supports IRIs, blank nodes, and literals with
/// optional language tags and datatypes.
///
/// The parser follows the N-Triples specification from W3C:
/// https://www.w3.org/TR/n-triples/
/// {@endtemplate}
final class NTriplesParser extends Converter<String, Set<Triple>> {
  /// {@macro ntriples_parser}
  const NTriplesParser();

  @override
  Set<Triple> convert(String input) {
    // Initialize an empty set to store the parsed triples.
    final result = <Triple>{};
    // Split the input string into individual lines.
    final lines = LineSplitter.split(input);
    // Iterate over each line.
    for (final line in lines) {
      // Trim leading and trailing whitespace from the line.
      final trimmedLine = line.trim();
      // Skip empty lines and comments (lines starting with '#').
      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
        continue;
      }
      try {
        // Parse the line and get the triple (or null).
        final triple = _parseLine(trimmedLine);
        // If the triple is not null add it to the result.
        if (triple != null) {
          result.add(triple);
        }
      } on NTriplesParseException catch (e) {
        // If a parsing error occurs, re-throw the exception with additional context.
        throw NTriplesParseException(
          'Error parsing line: $line - ${e.message}',
        );
      }
    }
    // Return the set of parsed triples.
    return result;
  }

  /// Parses a single line of N-Triples input.
  ///
  /// This method parses a single, trimmed, non-comment line of N-Triples
  /// input. It splits the line into components (subject, predicate, object),
  /// parses each component, and returns a [Triple] object.
  ///
  /// Returns `null` if the line is only `.`.
  ///
  /// Throws a [NTriplesParseException] if the line is invalid.
  Triple? _parseLine(String line) {
    // Check if the line is only a period, it is a valid line but does not generate a triple.
    if (line == '.') {
      return null;
    }
    // Check if the line ends with a period. If not, it's an invalid line.
    if (!line.endsWith('.')) {
      throw NTriplesParseException('Missing period at the end of the line.');
    }

    // Remove the trailing period from the line to simplify further processing.
    final lineWithoutPeriod = line.substring(0, line.length - 1);

    // Initialize the list of components.
    final components = <String>[];
    // Initialize the variables needed to correctly handle literal.
    var inLiteral = false;
    var startComponent = 0;
    // Iterate over the line to handle the case of literal
    for (var i = 0; i < lineWithoutPeriod.length; i++) {
      // Check if it is the beginning or the end of a literal.
      if (lineWithoutPeriod[i] == '"' &&
          (i == 0 || lineWithoutPeriod[i - 1] != r'\')) {
        inLiteral = !inLiteral;
      }
      // Check if we are out of a literal and if the character is a space.
      if (!inLiteral && lineWithoutPeriod[i] == ' ') {
        // Add the component.
        components.add(lineWithoutPeriod.substring(startComponent, i).trim());
        // Update the start of the next component.
        startComponent = i + 1;
      }
    }
    // Add the last component.
    components.add(lineWithoutPeriod.substring(startComponent).trim());

    // Check if there are exactly three components (subject, predicate, object).
    if (components.length != 3) {
      throw NTriplesParseException(
        'Incorrect number of components (expected 3, got ${components.length}).',
      );
    }

    // Parse the subject, predicate, and object components.
    final subject = _parseSubject(components[0]);
    final predicate = _parsePredicate(components[1]);
    final object = _parseObject(components[2]);

    // Return the created triple.
    return Triple(subject, predicate, object);
  }

  /// Parses the subject component of an N-Triples line.
  ///
  /// The subject can be an [IRI] or a [BlankNode].
  ///
  /// Throws a [NTriplesParseException] if the subject is invalid.
  RdfTerm _parseSubject(String component) {
    if (component.startsWith('<')) {
      // Subject is an IRI.
      if (!component.endsWith('>')) {
        throw NTriplesParseException('Invalid IRI: missing ">".');
      }
      final iriValue = component.substring(1, component.length - 1);
      return IRI(iriValue);
    } else if (component.startsWith('_:')) {
      // Subject is a Blank Node.
      final blankNodeId = component.substring(2);
      if (blankNodeId.isEmpty) {
        throw NTriplesParseException('Invalid blank node identifier.');
      }
      return BlankNode(blankNodeId);
    } else {
      // Subject is invalid.
      throw NTriplesParseException(
        'Invalid subject: not an IRI or blank node.',
      );
    }
  }

  /// Parses the predicate component of an N-Triples line.
  ///
  /// The predicate must be an [IRI].
  ///
  /// Throws a [NTriplesParseException] if the predicate is invalid.
  IRI _parsePredicate(String component) {
    if (!component.startsWith('<') || !component.endsWith('>')) {
      throw NTriplesParseException('Invalid predicate: not an IRI.');
    }
    // Take the value between the brackets
    final iriValue = component.substring(1, component.length - 1);
    return IRI(iriValue);
  }

  /// Parses the object component of an N-Triples line.
  ///
  /// The object can be an [IRI], a [BlankNode], or a [Literal].
  ///
  /// Throws a [NTriplesParseException] if the object is invalid.
  RdfTerm _parseObject(String component) {
    if (component.startsWith('<') && component.endsWith('>')) {
      // Object is an IRI.
      final iriValue = component.substring(1, component.length - 1);
      return IRI(iriValue);
    } else if (component.startsWith('_:')) {
      // Object is a Blank Node.
      final blankNodeId = component.substring(2);
      if (blankNodeId.isEmpty) {
        throw NTriplesParseException('Invalid blank node identifier.');
      }
      return BlankNode(blankNodeId);
    } else if (component.startsWith('"') && component.endsWith('"')) {
      // Object is a Literal.
      var literalValue = component.substring(1, component.length - 1);
      String? language;
      IRI? datatype;

      // Check for language tag (e.g., "hello"@en).
      final languageSplit = literalValue.split('@');
      if (languageSplit.length == 2) {
        literalValue = languageSplit[0];
        language = languageSplit[1];
      }

      // Check for datatype (e.g., "123"^^<http://example.com/integer>).
      final datatypeSplit = literalValue.split('^^');
      if (datatypeSplit.length == 2) {
        literalValue = datatypeSplit[0];
        final datatypeString = datatypeSplit[1];
        // Check if the datatype is an IRI
        if (!datatypeString.startsWith('<') || !datatypeString.endsWith('>')) {
          throw NTriplesParseException('Invalid datatype.');
        }
        datatype = IRI(datatypeString.substring(1, datatypeString.length - 1));
      } else {
        // If no datatype is specified, the default is xsd:string.
        datatype = IRI('http://www.w3.org/2001/XMLSchema#string');
      }

      return Literal(literalValue, datatype, language);
    } else {
      // Object is invalid.
      throw NTriplesParseException(
        'Invalid object: not an IRI, blank node, or literal.',
      );
    }
  }
}

/// {@template ntriples_parse_exception}
/// Exception thrown when an error occurs during N-Triples parsing.
///
/// This exception is thrown by the [NTriplesParser] when it encounters
/// invalid syntax or other errors while parsing N-Triples input. The
/// [message] property contains a detailed error message.
/// {@endtemplate}
class NTriplesParseException implements Exception {
  /// A message describing the error.
  final String message;

  /// {@macro ntriples_parse_exception}
  const NTriplesParseException([this.message = '']);
}
