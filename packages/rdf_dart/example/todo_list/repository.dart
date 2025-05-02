import 'dart:io';

import 'package:iri/iri.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/canonicalization/canonicalization_algorithm.dart';

import 'task.dart';
import 'task_list.dart';

// Define vocabulary terms consistently
// ignore: avoid_classes_with_only_static_members
class Schema {
  static final IRINode type = IRINode(RDF.type);
  static final IRINode name = IRINode(IRI('https://schema.org/name'));
  static final IRINode description = IRINode(
    IRI('https://schema.org/description'),
  );
  static final IRINode itemList = IRINode(IRI('https://schema.org/ItemList'));
  static final IRINode itemListElement = IRINode(
    IRI('https://schema.org/itemListElement'),
  );
  static final IRINode listItem = IRINode(IRI('https://schema.org/ListItem'));
  static final IRINode item = IRINode(IRI('https://schema.org/item'));
  // Define a Task type IRI (can be schema:Thing or something more specific)
  static final IRINode task = IRINode(
    IRI('https://schema.org/Thing'),
  ); // Or e.g., app:Task
  static final IRINode itemListOrder = IRINode(
    IRI('https://schema.org/itemListOrder'),
  );
  static final IRINode itemListUnordered = IRINode(
    IRI('https://schema.org/ItemListUnordered'),
  );
}

abstract class DataRepository {
  Future<List<TaskList>> loadData();
  Future<void> saveData(List<TaskList> taskLists);
  Future<void> export(List<TaskList> taskLists); 

  // Rehydration logic using Graph querying
  static List<TaskList> createTaskListsFromGraph(Graph graph) {
    final taskLists = <TaskList>[];
    final tasks = <IRINode, Task>{}; // Map IRI -> Task

    // 1. Find and hydrate all Tasks first
    final taskSubjects = graph.subjects(
      predicate: Schema.type,
      object: Schema.task,
    );
    for (final taskSubject in taskSubjects) {
      if (taskSubject is IRINode) {
        // Ensure it's an IRI as expected
        try {
          final task = Task.fromGraph(graph, taskSubject);
          tasks[taskSubject] = task;
        } on Exception catch (e) {
          stderr.writeln('Failed to hydrate task ${taskSubject.value}: $e');
          // Decide how to handle partial failures - skip task?
        }
      } else {
        stderr.writeln(
          'Warning: Found non-IRI subject for a Task type: $taskSubject',
        );
      }
    }

    // 2. Find and hydrate TaskLists, linking Tasks
    final taskListSubjects = graph.subjects(
      predicate: Schema.type,
      object: Schema.itemList,
    );
    for (final taskListSubject in taskListSubjects) {
      if (taskListSubject is IRINode) {
        // Ensure it's an IRI as expected
        try {
          // Pass the map of already hydrated tasks
          final taskList = TaskList.fromGraph(graph, taskListSubject, tasks);
          taskLists.add(taskList);
        } on Exception catch (e) {
          stderr.writeln(
            'Failed to hydrate task list ${taskListSubject.value}: $e',
          );
        }
      } else {
        stderr.writeln(
          'Warning: Found non-IRI subject for an ItemList type: $taskListSubject',
        );
      }
    }

    return taskLists;
  }
}

class FilesystemRepository implements DataRepository {
  final String _fileName = 'todos.nt'; // Keep filename consistent

  @override
  Future<List<TaskList>> loadData() async {
    final content = await _loadFile(_fileName);
    if (content == null || content.trim().isEmpty) {
      return []; // Return empty list if file doesn't exist or is empty
    }
    try {
      final graph = Graph();
      graph.addAll(nTriplesCodec.decoder.convert(content));
      return DataRepository.createTaskListsFromGraph(graph);
    } on FormatException catch (e) {
      stderr.writeln('Error parsing N-Triples file: $e');
      return [];
    } on Exception catch (e) {
      stderr.writeln('An unexpected error occurred during data loading: $e');
      return [];
    }
  }

  @override
  Future<void> saveData(List<TaskList> taskLists) async {
    final graph = Graph();
    for (final taskList in taskLists) {
      // Add all triples for the list (including its tasks) to the graph
      graph.addAll(taskList.toTriples());
    }
    // Convert the graph's triples to N-Triples string
    // Note: Encoder might directly support Graph in future,
    // for now convert triples Set to List.
    final serializedState = nTriplesCodec.encoder.convert(
      graph.triples.toList(),
    );
    await _saveFile(_fileName, serializedState);
  }

  // --- Private Helper Methods ---

  Future<String?> _loadFile(String fileName) async {
    try {
      final file = File(fileName);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null; // File doesn't exist
    } on IOException catch (e) {
      stderr.writeln('Error reading file $fileName: $e');
      return null; // Or throw a custom RepositoryIOException
    }
  }

  Future<void> _saveFile(String fileName, String content) async {
    try {
      final file = File(fileName);
      await file.writeAsString(content);
    } on IOException catch (e) {
      stderr.writeln('Error writing file $fileName: $e');
    }
  }
  
  @override
  Future<void> export(List<TaskList> taskLists) async {
    final dataset = Dataset();
    for (final taskList in taskLists) {
      // Add all triples for the list (including its tasks) to the default graph
      dataset.defaultGraph.addAll(taskList.toTriples());
    }
    final canonicalizer = Canonicalizer.create(CanonicalizationAlgorithm.rdfc10);
    final canonicalDataset = canonicalizer.canonicalize(dataset);
    await _saveFile('todos.nq', canonicalDataset);
  }
}

class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);
  @override
  String toString() => 'RepositoryException: $message';
}
