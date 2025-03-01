import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:napsakya/screens/SplashScreen.dart';
import 'package:napsakya/util/question_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'Screens/QuestionsPage.dart';
import 'Screens/YourOwnQuestionsPage.dart';
import 'database/database_helper.dart';
import 'model/question.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontFamily: 'SpicyRice', fontSize: 16),
          bodyText2: TextStyle(fontFamily: 'SpicyRice', fontSize: 14),
          headline1: TextStyle(fontFamily: 'SpicyRice', fontSize: 32, ),//fontWeight: FontWeight.bold),
          button: TextStyle(fontFamily: 'SpicyRice', fontSize: 18),
        ),
      ),
      // Başlangıçta SplashScreen'i gösteriyoruz
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(), // SplashScreen için rota
        '/home': (context) => MyHomePage(title: 'Home Page'), // Ana sayfa rotası
      },
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> favoriteQuestions = [""];


  @override
  void initState() {
    super.initState();
    _loadFavorites();
    WidgetsFlutterBinding.ensureInitialized(); // Veritabanı işlemleri başlatılmadan önce gerekli

    _addQuestionsToDatabase(); //
    print("Uygulama başlatılıyor");

  }


  Future<void> _addQuestionsToDatabase() async {
    try {
      final dbHelper = DatabaseHelper.instance;

      // Var olan soruları kontrol et
      final existingQuestions = await dbHelper.getQuestions();
      print('Veritabanında bulunan soru sayısı: ${existingQuestions.length}');

      // Eğer veritabanında sorular varsa yeni ekleme yapmadan çık
      if (existingQuestions.isNotEmpty) {
        print('Sorular zaten veritabanında mevcut, ekleme yapılmadı.');
        return;
      }

      // Soruları ve modlarını belirlemek için listeleri ve mod isimlerini tanımla
      Map<String, List<String>> questionCategories = {
        "fun": QuestionUtil.funQuestions,
        "group": QuestionUtil.groupQuestions,
        "serious": QuestionUtil.seriousQuestions,
        "couple": QuestionUtil.coupleQuestions,
        "date": QuestionUtil.dateQuestions,
        "selfKnowledge": QuestionUtil.selfKnowledgeQuestions
      };

      // Her kategoriye ait soruları ve mod bilgilerini ekle
      for (var entry in questionCategories.entries) {
        String mode = entry.key;
        List<String> questionsList = entry.value;

        for (String questionText in questionsList) {
          // Soru nesnesi oluştur
          Question question = Question(
            text: questionText,
            isFav: false,
            mode: mode,
          );

          // Veritabanına ekle ve işlemin sonucunu yazdır
          await dbHelper.insertQuestion(question);
          print('Veritabanına eklendi: $questionText - Mod: $mode');
        }
      }

      print('Tüm sorular veritabanına başarıyla eklendi!');
    } catch (e) {
      print("Veritabanına soru eklenirken hata oluştu: $e");
    }
  }

  String getModeForQuestion(String questionText) {
    if (QuestionUtil.funQuestions.contains(questionText)) {
      return "fun";
    } else if (QuestionUtil.groupQuestions.contains(questionText)) {
      return "group";
    } else if (QuestionUtil.seriousQuestions.contains(questionText)) {
      return "serious";
    } else if (QuestionUtil.coupleQuestions.contains(questionText)) {
      return "couple";
    } else if (QuestionUtil.dateQuestions.contains(questionText)) {
      return "date";
    } else if (QuestionUtil.selfKnowledgeQuestions.contains(questionText)) {
      return "selfKnowledge";
    } else {
      return "unknown";
    }
  }

  void _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteQuestions = prefs.getStringList('favoriteQuestions') ?? [];
    });
  }

  bool YourOwnQOption = false;


   showQuestions(BuildContext context, String title, String mode, {bool yourOwnQuestions = false}) async {
    List<Question> favoriteQuestions = [];

    if (mode == "favourite") {
      final dbHelper = DatabaseHelper.instance;
      favoriteQuestions = await dbHelper.getFavoriteQuestions();
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => QuestionsPage(
          title: title,
          YourOwnQOption: yourOwnQuestions,
          YourOwnQuestions: QuestionUtil.YourOwnQuestions,
          favoriteQuestions: favoriteQuestions.map((q) => q.text).toList(),
          mode: mode,
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
              color: Colors.black, // Arka plan rengi, beyaz flaşı azaltır
              child: child,
            ),
          );
        },


      ),
    );

   }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white24,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.white),
            onPressed: () async {
              await showQuestions(context, "Favori Soruların", "favourite");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: size.height * 0.30,
            width: size.width * 0.8,
            child: Container(
              margin: EdgeInsets.only(top: 30.0, left: 0.0, bottom: 00),
              child: Image.asset("images/NapsakyaLogo.jpg"),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: size.height * 0.00),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getModeButton(context, "Makara Modu", "fun"),
                getModeButton(context, "Ciddiyet Modu", "serious"),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getModeButton(context, "Kendini Tanıma Modu", "selfKnowledge"),
              getModeButton(context, "Grup Modu", "group"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getModeButton(context, "Date Modu", "date"),
              getModeButton(context, "Çift Modu", "couple"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.11,
                width: size.width * 0.90,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.01),
                  child: ElevatedButton(
                    child: Text(
                      "Kendi Sorularını Yaz!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        //fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Köşeleri daha dik yapmak için düşük bir değer girin
                      ),
                    ),
                    onPressed: () {
                      showQuestions(context, "Senin Soruların", "YourOwnQuestions", yourOwnQuestions: true);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Mod butonlarını oluşturma fonksiyonu
  Widget getModeButton(BuildContext context, String title, String mode) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.13,
      width: size.width * 0.45,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.01),
          child: ElevatedButton(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Köşeleri daha dik yapmak için düşük bir değer girin
              ),
            ),
            onPressed: () {
              showQuestions(context, title, mode);
            },
          ),

      ),
    );
  }
}
