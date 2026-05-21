// Flutter에서 UI를 만들기 위해 필요한 패키지 불러오기
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 앱이 시작되면 가장 먼저 실행되는 함수
void main() {
  // runApp() : Flutter 앱을 화면에 표시하라는 명령
  runApp(const CheckListApp());
}

// 변하지 않는 화면 구조를 가진 최상위 위젯 (앱 전체 틀)
class CheckListApp extends StatelessWidget {
  // 생성자 : key는 위젯 고유 식별자 (필수는 아님, 관례)
  const CheckListApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp : 앱의 기본 틀, 테마, 라우팅 등을 설정하는 가장 중요한 위젯
    return MaterialApp(
      // 오른쪽 위에 뜨는 DEBUG 배너 제거
      debugShowCheckedModeBanner: false,

      // 앱이 처음 켜졌을 때 보여줄 화면을 지정
      home: const CheckListPage(),
    );
  }
}

// 체크리스트 화면은 "변하는 데이터"가 있으므로 StatefulWidget 사용
class CheckListPage extends StatefulWidget {
  const CheckListPage({super.key});

  // State 객체 생성 → 실제로 데이터와 화면을 관리하는 클래스 연결
  @override
  State<CheckListPage> createState() => _CheckListPageState();
}

// 실질적으로 체크리스트 데이터 + UI를 관리하는 클래스
class _CheckListPageState extends State<CheckListPage> {
  // TextField에 적힌 내용을 읽기 위해 필요한 컨트롤러
  final TextEditingController controller = TextEditingController();

  // 체크리스트 모든 항목을 저장하는 리스트
  // Map 형태로 "text", "done" 두 개의 값 저장
  List<Map<String, dynamic>> tasks = [];

  // 앱 시작 시 저장된 데이터 불러오기
  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // 로컬 저장소에서 불러오기
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('tasks');
    if (saved != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(saved));
      });
    }
  }

  // 로컬 저장소에 저장
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(tasks));
  }

  // 할 일 추가하는 함수
  void addTask() {
    // 입력값이 공백이면 추가하지 않도록 체크
    if (controller.text.trim().isEmpty) return;

    // setState : UI 업데이트하라고 Flutter에게 알려주는 명령
    setState(() {
      // 리스트에 새로운 할 일(Map) 추가
      tasks.add({
        "text": controller.text, // 입력한 문자열 저장
        "done": false,           // 처음에는 체크되지 않은 상태(false)
      });
    });

    // 텍스트 입력창 비우기
    controller.clear();
    saveTasks(); // 추가 후 저장
  }

  // 체크박스를 눌렀을 때 실행되는 함수
  void toggleDone(int index) {
    setState(() {
      // true ↔ false 형태로 반전시킴
      tasks[index]["done"] = !tasks[index]["done"];
    });
    saveTasks(); // 추가 후 저장
  }

  // 삭제 버튼을 눌렀을 때 실행되는 함수
  void deleteTask(int index) {
    setState(() {
      // index번째 항목 삭제
      tasks.removeAt(index);
    });
    saveTasks(); // 추가 후 저장
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold : 화면 전체의 기본 구조(앱바, 바디 등) 제공
    return Scaffold(
      // 전체 화면 배경색
      backgroundColor: const Color(0xFFFFF0F0),

      // 상단 앱바 영역
      appBar: AppBar(
        backgroundColor: const Color(0xffff8fb1),

        // 제목 텍스트
        title: const Text(
          "체크리스트",
          style: TextStyle(
            fontSize: 22,            // 글자 크기
            fontWeight: FontWeight.bold, // 굵은 글씨
          ),
        ),

        // 제목 가운데 정렬
        centerTitle: true,
      ),

      // 앱 화면의 본문(body)
      body: Column(
        // Column : 위에서 아래 방향으로 위젯 배치
        children: [
          // 입력창과 버튼을 감싸는 여백 영역
          Padding(
            padding: const EdgeInsets.all(16), // 상하좌우 16px 여백
            child: Row(
              // Row : 가로 방향으로 배치
              children: [
                // TextField가 가능한 공간을 모두 차지하게 함
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: true,

                    onSubmitted: (_) => addTask(),
                    // keyboardType: TextInputType.text,
                    // textInputAction: TextInputAction.done,

                    decoration: const InputDecoration(
                      hintText: "할 일 적기",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // 텍스트필드와 버튼 사이 간격 10px
                const SizedBox(width: 10),

                // "추가" 버튼
                ElevatedButton(
                  onPressed: addTask, // 버튼 누르면 addTask 실행
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffff8fb1), // 버튼 색
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, // 좌우 패딩
                      vertical: 14,   // 상하 패딩
                    ),
                  ),
                  child: const Text("추가"),
                ),
              ],
            ),
          ),

          // 리스트뷰가 남은 화면 전체를 차지하도록 Expanded 사용
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length, // 리스트 길이만큼 생성
              itemBuilder: (context, index) {
                // index번째 리스트 항목 UI 만들기
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16, // 좌우 16px
                    vertical: 6,    // 상하 6px
                  ),

                  // 박스 꾸미기
                  decoration: BoxDecoration(
                    color: Colors.white, // 배경 하얗게
                    borderRadius: BorderRadius.circular(12), // 둥글게
                  ),

                  // 체크박스 + 텍스트 + 삭제 버튼 한 줄씩 배치
                  child: ListTile(
                    // 왼쪽 체크박스
                    leading: Checkbox(
                      value: tasks[index]["done"],
                      onChanged: (_) => toggleDone(index),
                      activeColor: const Color(0xffff8fb1),
                      side: const BorderSide(
                        color: Color(0xffff8fb1),
                        width: 2,
                      ),
                    ),

                    // 중앙 텍스트
                    title: Text(
                      tasks[index]["text"], // 할 일 내용
                      style: TextStyle(
                        fontSize: 16,
                        decoration: tasks[index]["done"]
                            ? TextDecoration.lineThrough // 체크되면 줄 긋기
                            : null,
                        color: tasks[index]["done"]
                            ? Colors.grey // 완료된 글자 색
                            : Colors.black, // 미완료 글자 색
                      ),
                    ),

                    // 오른쪽 X 삭제 버튼
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.pink),
                      onPressed: () => deleteTask(index), // 눌렀을 때 삭제
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
