import 'package:rdf_dart/src/graph.dart';
import 'package:rdf_dart/src/iri.dart';

class Dataset {
  final Graph defaultGraph = Graph();
  final Map<IRI, Graph> namedGraphs = {};

  void addNamedGraph(IRI name, Graph graph) {
    namedGraphs[name] = graph;
  }

  void removeNamedGraph(IRI name) {
    namedGraphs.remove(name);
  }
}
