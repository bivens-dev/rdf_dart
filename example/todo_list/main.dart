import 'dart:io';

import 'package:rdf_dart/rdf_dart.dart';

import 'repository.dart';
import 'task.dart';
import 'task_list.dart';

void main() async {
  final application = TodoApp(
    dataRepository: FilesystemRepository(),
    taskLists: TodoApp.createSeedData(),
  );

  await application.saveData();
  await application.loadData();
  application.displayTaskLists();
  await application.exportData();
}

class TodoApp {
  final DataRepository dataRepository;
  List<TaskList> taskLists;

  TodoApp({required this.dataRepository, required this.taskLists});

  /// Load the various lists and task from the disk
  Future<void> loadData() async {
    _log('\nLoading data...');
    taskLists = await dataRepository.loadData();
    _log('Data loaded.');
  }

  /// Save the data to disk
  Future<void> saveData() async {
    _log('Saving data...');
    await dataRepository.saveData(taskLists);
    _log('Data saved.');
  }

  /// Save the data in the official canonical dataset format
  Future<void> exportData() async {
    _log('Exporting data...');
    await dataRepository.export(taskLists);
    _log('Data exported.');
  }

  void displayTaskLists() {
    _log('\n--- Task Lists ---');
    if (taskLists.isEmpty) {
      _log('No task lists found.');
    } else {
      for (final list in taskLists) {
        stdout.writeln(
          'Task List: ${list.name} (${list.id}) has ${list.tasks.length} tasks',
        );
        for (final task in list.tasks) {
          stdout.writeln(
            '  Task: ${task.name} (${task.id}) - ${task.description}',
          );
        }
      }
      stdout.writeln('------------------------');
    }
  }

  void _log(String message) {
    stdout.writeln(message);
  }

  static List<TaskList> createSeedData() {
    // Helper function to create app IRIs
    IRITerm taskIRI(String id) => IRITerm(IRI('app:task/$id'));
    IRITerm listIRI(String id) => IRITerm(IRI('app:list/$id'));

    // Create some task lists using IRIs
    final taskList1 = TaskList(id: listIRI('work'), name: 'Work Tasks');
    final taskList2 = TaskList(
      id: listIRI('personal'),
      name: 'Personal Tasks',
      description: 'For personal use only',
    );

    // Create some tasks using IRIs
    final task1 = Task(
      id: taskIRI('task1'),
      name: 'Write code',
      description: 'Implement new feature',
    );
    final task2 = Task(
      id: taskIRI('task2'),
      name: 'Buy groceries',
      description: 'Milk, eggs, bread',
    );
    final task3 = Task(
      id: taskIRI('task3'),
      name: 'Exercise',
      description: 'Run for 30 minutes',
    );

    // Add tasks to task lists
    taskList1.addTask(task1);
    taskList1.addTask(task2);
    taskList2.addTask(task3);

    return [taskList1, taskList2];
  }
}
