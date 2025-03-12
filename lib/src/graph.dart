import 'package:rdf_dart/src/triple.dart';

/// Represents an RDF graph, which is a collection of RDF triples.
///
/// An RDF graph is a set of subject-predicate-object triples. The subject and
/// object of a triple can be an IRI or a blank node, while the predicate must
/// be an IRI.
///
/// This class provides methods to manage the triples within the graph, such as
/// adding, removing, and checking for the presence of triples.
class Graph {
  /// The set of triples in this graph.
  ///
  /// This set contains all the [Triple] objects that are part of this graph.
  final Set<Triple> _triples = {};

  /// Returns the set of triples in this graph.
  ///
  /// This getter provides read-only access to the triples in the graph.
  Set<Triple> get triples => Set.unmodifiable(_triples);

  /// Adds a [triple] to this graph.
  ///
  /// The triple is added to the set of triples in the graph. If the triple
  /// already exists in the graph, it will not be added again.
  ///
  /// Example:
  /// ```dart
  /// final graph = Graph();
  /// final subject = IRI('http://example.com/subject');
  /// final predicate = IRI('http://example.com/predicate');
  /// final object = IRI('http://example.com/object');
  /// final triple = Triple(subject, predicate, object);
  /// graph.add(triple);
  /// ```
  void add(Triple triple) {
    _triples.add(triple);
  }

  /// Adds all the [triples] in the given iterable to this graph.
  ///
  /// The triples are added to the set of triples in the graph. If a triple
  /// already exists in the graph, it will not be added again.
  ///
  /// Example:
  /// ```dart
  /// final graph = Graph();
  /// final subject = IRI('http://example.com/subject');
  /// final predicate = IRI('http://example.com/predicate');
  /// final object1 = IRI('http://example.com/object1');
  /// final object2 = IRI('http://example.com/object2');
  /// final triple1 = Triple(subject, predicate, object1);
  /// final triple2 = Triple(subject, predicate, object2);
  /// graph.addAll([triple1, triple2]);
  /// ```
  void addAll(Iterable<Triple> triples) {
    _triples.addAll(triples);
  }

  /// Removes a [triple] from this graph.
  ///
  /// If the triple is present in the graph, it is removed. If the triple is
  /// not present, this method does nothing.
  ///
  /// Example:
  /// ```dart
  /// final graph = Graph();
  /// final subject = IRI('http://example.com/subject');
  /// final predicate = IRI('http://example.com/predicate');
  /// final object = IRI('http://example.com/object');
  /// final triple = Triple(subject, predicate, object);
  /// graph.add(triple);
  /// graph.remove(triple);
  /// ```
  void remove(Triple triple) {
    _triples.remove(triple);
  }

  /// Checks if this graph contains the given [triple].
  ///
  /// Returns `true` if the triple is present in the graph, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final graph = Graph();
  /// final subject = IRI('http://example.com/subject');
  /// final predicate = IRI('http://example.com/predicate');
  /// final object = IRI('http://example.com/object');
  /// final triple = Triple(subject, predicate, object);
  /// graph.add(triple);
  /// print(graph.contains(triple)); // Output: true
  /// ```
  bool contains(Triple triple) {
    return _triples.contains(triple);
  }
}
