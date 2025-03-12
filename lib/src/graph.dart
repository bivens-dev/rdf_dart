import 'triple.dart';

class Graph {
  final Set<Triple> _triples = {};

  Set<Triple> get triples => _triples;

  void add(Triple triple) {
    _triples.add(triple);
  }

  void addAll(Iterable<Triple> triples) {
    _triples.addAll(triples);
  }

  void remove(Triple triple) {
    _triples.remove(triple);
  }

  bool contains(Triple triple) {
    return _triples.contains(triple);
  }
}
