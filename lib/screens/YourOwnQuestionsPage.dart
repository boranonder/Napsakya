import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:napsakya/main.dart';

import '../database/database_helper.dart'; // Veritabanı yardımı için
import '../model/question.dart';

class YourOwnQuestionsPage extends StatefulWidget {
  const YourOwnQuestionsPage({Key? key}) : super(key: key);

  @override
  _YourOwnQuestionsPageState createState() => _YourOwnQuestionsPageState();
}

class _YourOwnQuestionsPageState extends State<YourOwnQuestionsPage> {
  List<Question> YourOwnQuestions = [];
  final TextEditingController _controller = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestionsFromDatabase(); // Veritabanından soruları yükleme
  }

  Future<void> _loadQuestionsFromDatabase() async {
    final dbHelper = DatabaseHelper.instance;
    List<Question> loadedQuestions = await dbHelper.getQuestionsByMode("YourOwnQuestions");

    setState(() {
      YourOwnQuestions = loadedQuestions;
      isLoading = false; // Sorular yüklendiğinde isLoading false olur.
    });
  }

  void _addQuestion() async {
    if (_controller.text.isNotEmpty) {
      final newQuestion = Question(
        text: _controller.text,
        isFav: false,
        mode: "YourOwnQuestions", // Kendi sorularınızın modu
      );

      setState(() {
        YourOwnQuestions.add(newQuestion);
        _controller.clear();
      });

      // Veritabanına ekleme
      await DatabaseHelper.instance.insertQuestion(newQuestion);
    }
  }

  void _deleteQuestion(int index) async {
    final questionToDelete = YourOwnQuestions[index];

    setState(() {
      YourOwnQuestions.removeAt(index);
    });

    // Veritabanından silme
    if (questionToDelete.id != null) {
      await DatabaseHelper.instance.deleteQuestion(questionToDelete.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Senin Soruların"),

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Yükleniyorsa göster
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: YourOwnQuestions.length,
              itemBuilder: (context, index) {
                return LongPressDraggable(
                  child: ListTile(
                    title: Text(
                      YourOwnQuestions[index].text,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Sil'),
                                  onTap: () {
                                    _deleteQuestion(index);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  feedback: Material(
                    child: Container(
                      margin: const EdgeInsets.only(top: 0.0),
                      color: Colors.white,
                      child: ListTile(
                        title: Text(
                          YourOwnQuestions[index].text,
                          style: const TextStyle(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 1.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: TextField(
                      controller: _controller,
                      maxLength: 130,
                      inputFormatters: [LengthLimitingTextInputFormatter(130)],
                      decoration: InputDecoration(
                        hintText: "Yeni soru ekle...",
                        hintStyle: const TextStyle(color: Colors.white),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2.0),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2.0),
                        ),
                        counterText: "${_controller.text.length} / 130",
                        counterStyle: const TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  color: Colors.white,
                  onPressed: _addQuestion,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, YourOwnQuestions);
              //main().showQuestions(context, "Senin Soruların", "YourOwnQuestions", yourOwnQuestions: true);
            },
            child: const Text(
              "Kaydet ve geri dön",
              style: TextStyle(color: Colors.white, fontSize: 19),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
