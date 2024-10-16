import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/global.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      List<dynamic> savedTasks = jsonDecode(tasksString);
      setState(() {
        tasks =
            savedTasks.map((task) => Map<String, dynamic>.from(task)).toList();
      });
    }
  }

  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks));
  }

  void addTask(String task) {
    setState(() {
      tasks.add({'task': task, 'completed': false});
      saveTasks(); // Persist the task list
    });
    taskController.clear(); // Clear the input field after adding
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      saveTasks(); // Update the task list
    });
  }

  void toggleCompletion(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
      saveTasks(); // Update the task list
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "To-Do List",
          style: Global.size24,
        ),
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        backgroundColor: Color(0xffF5F5F5F5),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: taskController,
                      autocorrect: true,
                      enableInteractiveSelection: true,
                      style: Global.size16,
                      cursorColor: Colors.black,
                      cursorErrorColor: Colors.red,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter new task",
                        hintStyle: Global.size1606,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.black26,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (taskController.text.isNotEmpty) {
                        addTask(taskController.text);
                      }
                    },
                    child: Text('Add'),
                  )
                ],
              ),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks added yet.',
                          style: Global.size18black,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: false,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.all(10),
                            height: h * .1,
                            width: w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffF5F5F5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  checkColor: Colors.greenAccent,
                                  activeColor: Colors.white,
                                  value: tasks[index]['completed'],
                                  onChanged: (value) {
                                    toggleCompletion(index);
                                  },
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                FittedBox(
                                  fit: BoxFit.cover,
                                  child: Container(
                                    width: 180,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      tasks[index]['task'],
                                      style: tasks[index]['completed']
                                          ? Global.size18blackline
                                          : Global.size18black,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteTask(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
