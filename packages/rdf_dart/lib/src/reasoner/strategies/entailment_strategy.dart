import 'package:rdf_dart/src/model/graph.dart'; 
import 'package:rdf_dart/src/reasoner/strategies/entailment_options.dart';

/// Defines the interface for different entailment strategies in RDF.
/// Entailment is the process of inferring new RDF triples from existing ones
/// based on a set of rules.
abstract class EntailmentStrategy {
  /// Checks if graph `graph1` entails graph `graph2`.
  /// Entailment means that `graph2` logically follows from `graph1`
  /// according to the rules of this specific entailment strategy.
  ///
  /// - [graph1]: The first RDF graph.
  /// - [graph2]: The second RDF graph.
  /// - [options]: Optional [EntailmentOptions] to customize the entailment check.
  ///
  /// Returns `true` if `graph1` entails `graph2`, `false` otherwise.
  bool entails(Graph graph1, Graph graph2, {EntailmentOptions? options});

  /// Returns a new graph containing `graph1` plus all triples entailed from `graph1`
  /// under this specific entailment regime.
  /// This process is also known as "forward chaining" or "saturation".
  ///
  /// - [graph1]: The RDF graph to materialize.
  /// - [options]: Optional [EntailmentOptions] to customize the materialization process.
  ///
  /// Returns a new [Graph] instance with the entailed triples.
  Graph materialize(Graph graph1, {EntailmentOptions? options});

  /// Checks if graph `graph` is consistent under this entailment regime.
  /// Consistency means that the graph does not contain any contradictions
  /// according to the rules of this entailment strategy.
  /// For Simple Entailment, any graph is consistent.
  /// For D-Entailment and RDFS, inconsistencies can arise (e.g., ill-typed literals, rdfs:domain violations).
  ///
  /// - [graph]: The RDF graph to check for consistency.
  /// - [options]: Optional [EntailmentOptions] to customize the consistency check.
  ///
  /// Returns `true` if the `graph` is consistent, `false` otherwise.
  bool isConsistent(Graph graph, {EntailmentOptions? options});
}
