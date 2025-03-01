import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../model/question.dart';
import '../util/question_util.dart';
import 'YourOwnQuestionsPage.dart';

class QuestionsPage extends StatefulWidget {
  final List<String> favoriteQuestions;
  final String title;
  final bool YourOwnQOption;
  final List<String> YourOwnQuestions;
  final String mode;

  const QuestionsPage({
    super.key,
    required this.title,
    this.YourOwnQOption = false,
    required this.YourOwnQuestions,
    required this.favoriteQuestions,
    required this.mode,
  });

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  int currentIndex = 0;
  List<Question> questions = []; // Veritabanından gelen sorular burada tutulacak
  bool isLoading = true;
  bool isFavorite = false;
  List<String> YourOwnQuestions = [];

  @override
  void initState() {
    super.initState();
    print('initState başladı');
     // Mevcut sorular için veritabanından veya kaynaktan soruları yükle.

    YourOwnQuestions = List.from(widget.YourOwnQuestions);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestionsFromDatabase();
      print('Favori durumu kontrol ediliyor');
      checkFavoriteStatus(); // Favori durumu kontrol ediliyor
    }
    );


    if (widget.YourOwnQOption) {
      setState(() {
        widget.YourOwnQuestions.clear(); // Eski listeyi temizle
        widget.YourOwnQuestions.addAll(QuestionUtil.YourOwnQuestions); // En güncel listeyi ekle
        print('Loaded own questions: ${widget.YourOwnQuestions}');
      });
    }
  }



  void updateFavoriteStatus() {
    setState(() {
      isFavorite = questions.isNotEmpty && questions[currentIndex].isFav == 1;
    });
  }
  Future<void> checkFavoriteStatus() async {
    // Mevcut sorunun favori olup olmadığını veritabanından kontrol et
    print("checkFavoriteStatus çalışıyor.");

    final dbHelper = DatabaseHelper.instance;

    // Mevcut sorunun favori durumu olup olmadığını kontrol etmek
    bool isFav = (await dbHelper.getFavoriteQuestions()).any((q) => q.id == questions[currentIndex].id);

    setState(() {
      isFavorite = isFav;
    });
  }


  Future<void> _loadQuestionsFromDatabase() async {
    try {
      print('Veritabanı helper instance oluşturuluyor...');
      final dbHelper = DatabaseHelper.instance;
      print('Veritabanı helper instance oluşturuldu');
      if (widget.mode == "favourite") {
        questions = await dbHelper.getFavoriteQuestions();
        // Favori soruları çek
        print("Favori sorular yüklendi: ${questions.length}");
      } else {
        questions = await dbHelper.getQuestionsByMode(widget.mode);  // Normal mod soruları çek
        print("${widget.mode} modunda sorular yüklendi: ${questions.length}");
      }

      setState(() {
        updateFavoriteStatus();
        isLoading = false; // Veriler yüklendiğinde isLoading false olur.
      });
    } catch (e) {
      print("Hata: $e");
      setState(() {
        isLoading = false;
      });
    }
  }



  void nextQuestion() {
    setState(() {
      currentIndex = (currentIndex + 1) % questions.length;
      checkFavoriteStatus();
    });
  }

  void backQuestion() {
    setState(() {
      currentIndex = (currentIndex - 1) % questions.length;
      checkFavoriteStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white24,
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? Colors.red : Colors.white,
              onPressed: () async {
                if (questions.isNotEmpty) {
                  setState(() {
                    isFavorite = !isFavorite;
                    questions[currentIndex].isFav = isFavorite;  // isFav güncelleniyor

                    // Favori ise listeye ekle, favorilikten çıkarılıyorsa listeden kaldır
                    if (isFavorite) {
                      QuestionUtil.FavouriteQuestions.add(questions[currentIndex].text);  // Sorunun text'ini favorilere ekle
                    } else {
                      QuestionUtil.FavouriteQuestions.remove(questions[currentIndex].text);  // Sorunun text'ini favorilerden çıkar
                    }
                  });

                  // Veritabanını güncelle
                  await DatabaseHelper.instance.updateQuestion(questions[currentIndex]);
                }
              }

          ),



          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              if (questions.isNotEmpty) {
                Share.share('Bu soruyu paylaş: ${questions[currentIndex].text}');
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.white24,
      body: isLoading
          ? Center(child: CircularProgressIndicator()) :
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 0.0, left: 10.0, bottom: 5.0),
              child: Text(
                widget.title,
                style: TextStyle(color: Colors.white, fontSize: 30, ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 30.0),
              child: Text(
                "Soru ${currentIndex + 1} / ${questions.length}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
            Container(
              height: size.height * 0.34,
              width: size.width * 0.9,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.teal,
                  width: 5.0,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      child: Text(
                        questions.isNotEmpty ? questions[currentIndex].text : 'Eklenmiş soru yok',
                        style: TextStyle(fontSize: 22, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.04),
              child: SizedBox(
                height: size.height * 0.08,
                width: size.width * 0.45,
                child: ElevatedButton(
                  onPressed: nextQuestion,
                  child: Text(
                    "Geç",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Köşeleri daha dik yapmak için düşük bir değer girin
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: SizedBox(
                height: size.height * 0.08,
                width: size.width * 0.45,
                child: ElevatedButton(
                  onPressed: backQuestion,
                  child: Text(
                    "Geri",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Köşeleri daha dik yapmak için düşük bir değer girin
                    ),
                  ),
                ),
              ),
            ),
            if (widget.YourOwnQOption)
              Padding(
                padding: EdgeInsets.only(top: size.height * 0.02),
                child: SizedBox(
                  height: size.height * 0.08,
                  width: size.width * 0.45,
                  child: ElevatedButton(
                    onPressed: () async {
                      final updatedQuestions = await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => YourOwnQuestionsPage(
                            //YourOwnQuestions: widget.YourOwnQuestions,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // sağdan sola kaydırma
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: Container(
                                color: Colors.black, // Beyaz flaşı azaltmak için arka plan rengi
                                child: child,
                              ),
                            );
                          },

                        ),
                      );


                      if (updatedQuestions != null) {
                        setState(() {
                          // Kendi widget sorularını günceller
                          widget.YourOwnQuestions.clear();
                          widget.YourOwnQuestions.addAll(updatedQuestions);

                          // QuestionUtil'deki genel listeyi de günceller
                          QuestionUtil.YourOwnQuestions.clear();
                          QuestionUtil.YourOwnQuestions.addAll(updatedQuestions);
                        });
                      }
                    },
                    child: Text(
                      "Ekle/Çıkar",
                      style: TextStyle(color: Colors.white, fontSize: 19),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
