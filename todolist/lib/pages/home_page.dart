import 'package:flutter/material.dart';
import 'package:todolist/utils/todo_list.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  DateTime? _selectedDate;

  List<Map<String, dynamic>> toDoList = [
    {'task': 'Learn Flutter', 'completed': false, 'date': DateTime.now()},
    {
      'task': 'Project Flutter',
      'completed': false,
      'date': DateTime.now().add(Duration(days: 5))
    },
    {
      'task': 'Project Jee',
      'completed': false,
      'date': DateTime.now().add(Duration(days: 10))
    },
  ];

  // Liste filtrée (initialisée avec toutes les tâches)
  List<Map<String, dynamic>> filteredToDoList = [];

  @override
  void initState() {
    super.initState();
    filteredToDoList =
        List.from(toDoList); // Copie initiale de la liste complète
  }

  void checkBoxChanged(int index) {
    setState(() {
      filteredToDoList[index]['completed'] =
          !filteredToDoList[index]['completed'];
      _updateMainList();
    });
  }

  void saveNewTask() {
    if (_controller.text.trim().isNotEmpty && _selectedDate != null) {
      setState(() {
        final newTask = {
          'task': _controller.text.trim(),
          'completed': false,
          'date': _selectedDate!,
        };
        toDoList.add(newTask);
        filteredToDoList = List.from(toDoList);
        _controller.clear();
        _selectedDate = null;
      });
    }
  }

  void deleteTask(int index) {
    setState(() {
      toDoList.removeWhere(
          (task) => task['task'] == filteredToDoList[index]['task']);
      filteredToDoList.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Color getTaskColor(DateTime taskDate) {
    final now = DateTime.now();
    final difference = taskDate.difference(now).inDays;

    if (difference <= 3) {
      return Colors.red.shade700;
    } else if (difference <= 7) {
      return Colors.orange.shade600;
    } else {
      return Colors.green.shade400;
    }
  }

  // Met à jour la liste principale après modification dans la liste filtrée
  void _updateMainList() {
    toDoList = List.from(filteredToDoList);
  }

  // Met à jour la liste filtrée en fonction de la recherche
  void _filterTasks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredToDoList = List.from(toDoList);
      } else {
        filteredToDoList = toDoList
            .where((task) =>
                task['task'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade300,
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTasks,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search tasks...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Liste des tâches
          Expanded(
            child: ListView.builder(
              itemCount: filteredToDoList.length,
              itemBuilder: (BuildContext context, int index) {
                return TodoList(
                  taskName: filteredToDoList[index]['task'],
                  taskCompleted: filteredToDoList[index]['completed'],
                  taskDate: filteredToDoList[index]['date'],
                  taskColor: getTaskColor(filteredToDoList[index]['date']),
                  onChanged: (value) => checkBoxChanged(index),
                  deleteFunction: (value) => deleteTask(index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add a new todo item',
                    filled: true,
                    fillColor: Colors.deepPurple.shade200,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context),
            ),
            FloatingActionButton(
              onPressed: saveNewTask,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
