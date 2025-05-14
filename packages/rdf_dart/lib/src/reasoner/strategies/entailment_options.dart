import 'package:iri/iri.dart';

/// Defines optional parameters that can be used to configure specific
/// entailment regimes.
///
/// Entailment regimes may have specific behaviors that can be fine-tuned
/// using these options. For example, D-Entailment relies on a set of
/// recognized datatypes.
class EntailmentOptions {
  /// A set of IRIs representing recognized datatypes.
  /// This is particularly crucial for D-Entailment, which uses these
  /// datatypes to determine the validity of RDF literals.
  final Set<IRI>? recognizedDatatypes;

  /// Creates an instance of [EntailmentOptions].
  ///
  /// [recognizedDatatypes] is an optional set of IRIs for recognized
  /// datatypes, primarily used in D-Entailment.
  EntailmentOptions({this.recognizedDatatypes});
}
