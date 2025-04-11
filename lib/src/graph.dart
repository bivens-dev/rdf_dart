import 'package:rdf_dart/rdf_dart.dart';

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

  /// Takes a RDF Full graph and converts it to an RDF Classic graph
  static Graph classicize(Graph fullGraph) {
    // 1. Let Gₒ be an empty RDF graph.
    final g = Graph();

    // 2. Let M be an empty map from triple terms to blank nodes.
    final m = <TripleTerm, BlankNode>{};

    // 3. Let inputKind be null.
    String? inputKind;

    // 4. For each triple (s, p, o) in Gᵢ:
    for (final triple in fullGraph.triples) {
      // 4.1 If s is a blank node, p is rdf:type and o is rdf:TripleTerm, then:
      if (triple.subject is BlankNode &&
          triple.predicate ==
              IRITerm(RDF.type.toString()) &&
          triple.object ==
              IRITerm(
                RDF.tripleTerm.toString(),
              )) {
        // 4.1.1 If inputKind is "full" then exit with an error.
        if (inputKind == 'full') {
          throw Exception('Input graph is not classicizable');
        } else {
          // 4.1.2 Otherwise, set inputKind to "classic".
          inputKind = 'classic';
        }
      }

      var tripleToAdd = triple;

      // 4.2 If o is a triple term, then:
      if (triple.object is TripleTerm) {
        // 4.2.1 If inputKind is "classic" then exit with an error.
        if (inputKind == 'classic') {
          throw Exception('Input graph is not classicizable');
        } else {
          // 4.2.2 Otherwise, set inputKind to "full".
          inputKind = 'full';
        }

        // 4.2.3 Let b, M' and G' be the result of invoking classicize-triple-term
        // passing o as t and M as Mi.
        final (b, mPrime, gPrime) = _classicizeTripleTerm(
          triple.object as TripleTerm,
          m,
        );

        // 4.2.4 Merge M' into M.
        m.addAll(mPrime);

        // 4.2.5 Merge G' into Gₒ.
        g.addAll(gPrime.triples);

        // 4.2.6 Set o to b.
        tripleToAdd = Triple(triple.subject, triple.predicate, b);
      }

      // 4.3 Add the triple (s, p, o) to Gₒ.
      g.add(tripleToAdd);
    }

    // Return Gₒ.
    return g;
  }

  /// This algorithm is responsible for incrementally populating the mapping M and
  /// the graph G used internally by the classicize algorithm. It receives a
  /// triple term as input and processes it recursively (in case its object is
  /// itself a triple term). It returns, among other things, the blank node minted
  /// to replace the triple term in the transformed Classic RDF graph.
  ///
  /// This algorithm expects two input variables: a triple term t, and a map Mᵢ
  /// from triple terms to blank nodes. It returns a blank node b, a
  /// map Mₒ from triple terms to blank nodes, and a Classic RDF graph G.
  static (BlankNode, Map<TripleTerm, BlankNode>, Graph) _classicizeTripleTerm(
    TripleTerm t,
    Map<TripleTerm, BlankNode> m,
  ) {
    // 1. Let Mₒ be an empty map.
    final m0 = <TripleTerm, BlankNode>{};

    // 2. Let G be an empty RDF graph.
    final g = Graph();

    // 3. Let b be the blank node associated with t in Mᵢ, if any.
    var b = m[t];

    // 4. Otherwise:
    if (b == null) {
      // 4.1 Let s, p and o be the subject, predicate and object of t, respectively.
      final s = t.triple.subject;
      final p = t.triple.predicate;
      var o = t.triple.object;

      // 4.2 If o is a triple term, then:
      if (o is TripleTerm) {
        // 4.2.1 Let b', M' and G' be the result of invoking classicize-triple-term passing o as t and Mᵢ.
        final result = _classicizeTripleTerm(o, m);
        final b1 = result.$1;
        final m1 = result.$2;
        final g1 = result.$3;

        // 4.2.2 Set o to b'.
        o = b1;

        // 4.2.3 Merge M' into Mₒ.
        m0.addAll(m1);

        // 4.2.4 Merge G' into G.
        g.triples.addAll(g1.triples);
      }

      // 4.3 Let b be a fresh blank node.
      b = BlankNode();

      // 4.4 Add the association (t, b) to Mₒ.
      m0.addEntries([MapEntry<TripleTerm, BlankNode>(t, b)]);

      // 4.5 Add the triples (b, rdf:type, rdf:TripleTerm),
      // (b, rdf:ttSubject, s), (b, rdf:ttPredicate, p),
      // and (b, rdf:ttObject, o) in G.
      g.add(
        Triple(
          b,
          IRITerm(RDF.type.toString()),
          IRITerm(RDF.tripleTerm.toString()),
        ),
      );
      g.add(
        Triple(
          b,
          IRITerm(RDF.ttSubject.toString()),
          s,
        ),
      );
      g.add(
        Triple(
          b,
          IRITerm(RDF.ttPredicate.toString()),
          p,
        ),
      );
      g.add(
        Triple(
          b,
          IRITerm(RDF.ttObject.toString()),
          o,
        ),
      );
    }

    // 5. Return b, Mₒ and G.
    return (b, m0, g);
  }

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
