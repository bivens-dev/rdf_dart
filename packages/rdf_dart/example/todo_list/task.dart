import 'package:meta/meta.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'repository.dart'; // For Schema constants

@immutable
class Task {
  // Use IRINode for ID
  final IRINode id;
  final String name;
  final String description;

  Task({required this.id, required this.name, required this.description});

  // Factory to create Task from Graph data
  factory Task.fromGraph(Graph graph, IRINode subject) {
    // Use graph.object to find the single name literal
    final nameLiteral = graph.object(subject, Schema.name);
    // Use graph.object to find the single description literal
    final descriptionLiteral = graph.object(subject, Schema.description);

    // Basic validation
    if (nameLiteral == null || nameLiteral is! Literal) {
      throw RepositoryException(
        'Task ${subject.value} missing or invalid name',
      );
    }
    if (descriptionLiteral == null || descriptionLiteral is! Literal) {
      throw RepositoryException(
        'Task ${subject.value} missing or invalid description',
      );
    }

    // Assume literals are simple strings for this example
    final name = nameLiteral.value;
    final description = descriptionLiteral.value;

    return Task(
      id: subject,
      name: name.toString(),
      description: description.toString(),
    );
  }

  // Generate triples using the IRINode ID as the subject
  Set<Triple> toTriples() {
    final triples = <Triple>{};
    triples.addAll({
      Triple(id, Schema.type, Schema.task), // Use IRI id as subject
      Triple(id, Schema.name, Literal(name, XSD.string)),
      Triple(id, Schema.description, Literal(description, XSD.string)),
    });
    return triples;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id; // Primarily identify by ID

  @override
  int get hashCode => id.hashCode;
}
