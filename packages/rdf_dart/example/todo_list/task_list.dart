import 'dart:io';

import 'package:rdf_dart/rdf_dart.dart';
import 'repository.dart'; // For Schema constants
import 'task.dart';

class TaskList {
  // Use IRINode for ID
  final IRINode id;
  final String name;
  final String? description; // Optional description
  final Set<Task> _tasks = {};

  TaskList({required this.id, required this.name, this.description});

  // Factory to create TaskList from Graph data
  factory TaskList.fromGraph(
    Graph graph,
    IRINode subject,
    Map<IRINode, Task> allTasks,
  ) {
    final nameLiteral = graph.object(subject, Schema.name);
    // Description is optional, use graph.objects which returns Iterable
    final descriptionLiterals = graph.objects(
      subject: subject,
      predicate: Schema.description,
    );

    if (nameLiteral == null || nameLiteral is! Literal) {
      throw RepositoryException(
        'TaskList ${subject.value} missing or invalid name',
      );
    }

    final name = nameLiteral.value;
    // Take the first description found, if any
    final description =
        descriptionLiterals.whereType<Literal>().firstOrNull?.value;

    final taskList = TaskList(
      id: subject,
      name: name.toString(),
      description: description.toString(),
    );

    // Find associated tasks via ListItem structure
    final itemElementNodes = graph.objects(
      subject: subject,
      predicate: Schema.itemListElement,
    );
    for (final itemElementNode in itemElementNodes) {
      // The itemElementNode itself could be IRI or BNode, find the item linked from it
      if (itemElementNode is SubjectTerm) {
        // Must be SubjectTerm to be subject of next triple
        final itemNode = graph.object(itemElementNode, Schema.item);
        if (itemNode is IRINode) {
          // The item should be the Task's IRI
          final task = allTasks[itemNode]; // Look up pre-hydrated task
          if (task != null) {
            taskList.addTask(task);
          } else {
            // Optional: Warn if a linked task wasn't found/hydrated
            stderr.writeln(
              'Warning: TaskList ${subject.value} links to unknown task ${itemNode.value}',
            );
          }
        }
      }
    }
    return taskList;
  }

  // Generate triples using the IRINode ID
  Set<Triple> toTriples() {
    final triples = <Triple>{};
    triples.addAll({
      Triple(id, Schema.type, Schema.itemList), // Use IRI id as subject
      Triple(id, Schema.name, Literal(name, XSD.string)),
      Triple(
        id,
        Schema.itemListOrder,
        Schema.itemListUnordered,
      ), // Example list property
    });

    if (description != null) {
      triples.add(
        Triple(id, Schema.description, Literal(description!, XSD.string)),
      );
    }

    // Create triples for each task association
    for (final task in _tasks) {
      // Create an intermediate ListItem node (can be BlankNode or IRI)
      // Using BlankNode here as its identity might not be important externally
      final listItemNode = BlankNode(); // Auto-generates a unique ID

      triples.addAll({
        // Link TaskList -> ListItem
        Triple(id, Schema.itemListElement, listItemNode),
        // Define ListItem type
        Triple(listItemNode, Schema.type, Schema.listItem),
        // Link ListItem -> Task IRI
        Triple(listItemNode, Schema.item, task.id), // Use the Task's IRI
      });
      // Add the task's own triples
      triples.addAll(task.toTriples());
    }
    return triples;
  }

  // --- Task Management ---
  void addTask(Task task) {
    _tasks.add(task);
  }

  void removeTask(Task task) {
    _tasks.remove(task);
  }

  // Provide unmodifiable view of tasks
  Set<Task> get tasks => Set.unmodifiable(_tasks);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskList && runtimeType == other.runtimeType && id == other.id; // Primarily identify by ID

  @override
  int get hashCode => id.hashCode;
}
