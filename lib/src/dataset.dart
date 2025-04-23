import 'package:rdf_dart/src/graph.dart';
import 'package:rdf_dart/src/iri_term.dart';
import 'package:rdf_dart/src/subject_type.dart';

/// Represents an RDF Dataset, which is a collection of RDF graphs.
///
/// An RDF Dataset consists of a default graph and zero or more named graphs.
/// The default graph is an unnamed graph that contains a set of triples.
/// Named graphs are graphs that are associated with an IRI (Internationalized
/// Resource Identifier). Each named graph contains a set of triples and can be
/// accessed by its associated IRI.
///
/// This class provides methods to manage the default graph and named graphs within
/// the dataset.
class Dataset {
  /// The default graph of the dataset.
  ///
  /// This graph contains a set of triples that are not associated with any
  /// named graph.
  final Graph defaultGraph;

  /// The named graphs of the dataset.
  ///
  /// This map associates an [SubjectTerm] with a [Graph], where the [IRITerm] or
  /// the [BlankNode] is the name of the graph and the Graph is the set of
  /// triples associated with that name.
  final Map<SubjectTerm, Graph> namedGraphs;

  /// Creates a new empty Dataset.
  ///
  /// The dataset is initialized with an empty [defaultGraph] and an empty
  /// set of [namedGraphs].
  Dataset() : defaultGraph = Graph(), namedGraphs = {};

  /// Adds a named graph to the dataset.
  ///
  /// The [name] is the IRI that identifies the named graph, and [graph] is the
  /// graph to add to the dataset.
  ///
  /// If a named graph with the same [name] already exists, it will be
  /// replaced by the new graph.
  ///
  /// Example:
  /// ```dart
  /// final dataset = Dataset();
  /// final graph = Graph();
  /// final name = IRI('http://example.com/graph');
  /// dataset.addNamedGraph(name, graph);
  /// ```
  void addNamedGraph(SubjectTerm name, Graph graph) {
    namedGraphs[name] = graph;
  }

  /// Removes a named graph from the dataset.
  ///
  /// The [name] is the IRI that identifies the named graph to remove.
  ///
  /// If no named graph with the given [name] exists, this method does nothing.
  ///
  /// Example:
  /// ```dart
  /// final dataset = Dataset();
  /// final name = IRI('http://example.com/graph');
  /// // Add the graph first
  /// dataset.addNamedGraph(name, Graph());
  /// // remove the graph
  /// dataset.removeNamedGraph(name);
  /// ```
  void removeNamedGraph(SubjectTerm name) {
    namedGraphs.remove(name);
  }
}
