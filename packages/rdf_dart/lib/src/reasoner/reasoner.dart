import 'package:rdf_dart/src/model/graph.dart';
import 'package:rdf_dart/src/reasoner/strategies/entailment_options.dart';
import 'package:rdf_dart/src/reasoner/strategies/entailment_strategy.dart';

/// The `Reasoner` class provides a way to perform reasoning tasks on RDF graphs.
/// It uses a specific `EntailmentStrategy` to determine entailment, materialize graphs,
/// and check for consistency.
class Reasoner {
  /// The `EntailmentStrategy` used by this reasoner.
  final EntailmentStrategy strategy;

  /// Creates a new `Reasoner` with the given `EntailmentStrategy`.
  ///
  /// The `strategy` parameter defines the rules and algorithms used for reasoning.
  Reasoner(this.strategy);

  /// Checks if graph `graph1` entails `graph2` under the configured strategy.
  ///
  /// Entailment means that `graph2` logically follows from `graph1` according
  /// to the rules of the `EntailmentStrategy`.
  ///
  /// - `graph1`: The first RDF graph.
  /// - `graph2`: The second RDF graph.
  /// - `options`: Optional `EntailmentOptions` to customize the entailment check.
  ///
  /// Returns `true` if `graph1` entails `graph2`, `false` otherwise.
  bool entails(Graph graph1, Graph graph2, {EntailmentOptions? options}) {
    return strategy.entails(graph1, graph2, options: options);
  }

  /// Materializes all triples entailed by `graph` under the configured strategy.
  ///
  /// Materialization involves adding all derivable triples to the graph according
  /// to the `EntailmentStrategy`.
  ///
  /// - `graph`: The RDF graph to materialize.
  /// - `options`: Optional `EntailmentOptions` to customize the materialization process.
  ///
  /// Returns a new `Graph` containing the original triples plus all entailed triples.
  Graph materialize(Graph graph, {EntailmentOptions? options}) {
    return strategy.materialize(graph, options: options);
  }

  /// Checks if graph `graph` is consistent under the configured strategy.
  ///
  /// Consistency means that the graph does not contain any contradictions
  /// according to the rules of the `EntailmentStrategy`.
  ///
  /// - `graph`: The RDF graph to check for consistency.
  /// - `options`: Optional `EntailmentOptions` to customize the consistency check.
  ///
  /// Returns `true` if the `graph` is consistent, `false` otherwise.
  bool isConsistent(Graph graph, {EntailmentOptions? options}) {
    return strategy.isConsistent(graph, options: options);
  }
}
