import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CheckListApp());
}

class CheckListApp extends StatelessWidget {
  const CheckListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CheckListPage(),
    );
  }
}

class CheckListPage extends StatefulWidget {
  const CheckListPage({super.key});

  @override
  State<CheckListPage> createState() => _CheckListPageState();
}

class _CheckListPageState extends State<CheckListPage> {
  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('tasks');
    if (saved != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(saved));
      });
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(tasks));
  }

  void addTask() {
    if (controller.text.trim().isEmpty) return;
    setState(() {
      tasks.add({
        "text": controller.text,
        "done": false,
      });
    });
    controller.clear();
    saveTasks();
  }

  void toggleDone(int index) {
    setState(() {
      tasks[index]["done"] = !tasks[index]["done"];
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
      appBar: AppBar(
        backgroundColor: const Color(0xffff8fb1),
        title: const Text(
          "체크리스트",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    onSubmitted: (_) => addTask(),
                    decoration: const InputDecoration(
                      hintText: "할 일 적기",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addTask,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xffff8fb1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    "추가",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: const Color(0xFFFFF0F0), // 드래그 중 카드 배경색
              ),
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: tasks.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = tasks.removeAt(oldIndex);
                    tasks.insert(newIndex, item);
                  });
                  saveTasks();
                },
                itemBuilder: (context, index) {
                  return Container(
                    key: ValueKey(tasks[index]["text"]),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: tasks[index]["done"],
                        onChanged: (_) => toggleDone(index),
                        activeColor: const Color(0xffff8fb1),
                        side: const BorderSide(
                          color: Color(0xffff8fb1),
                          width: 2,
                        ),
                      ),
                      title: Text(
                        tasks[index]["text"],
                        style: TextStyle(
                          fontSize: 16,
                          decoration: tasks[index]["done"]
                              ? TextDecoration.lineThrough
                              : null,
                          color: tasks[index]["done"]
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.pink),
                            onPressed: () => deleteTask(index),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle, color: Colors.pink),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}