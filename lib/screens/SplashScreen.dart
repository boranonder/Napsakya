import 'package:flutter/material.dart';
import 'dart:async';

import 'package:napsakya/main.dart';  // Timer kullanımı için

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 3 saniye sonra ana sayfaya yönlendirme
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          settings: RouteSettings(name: '/home'),
          pageBuilder: (context, animation, secondaryAnimation) {
            return Container(
              color: Colors.black, // Geçiş sırasında siyah arka plan
              child: MyHomePage(title: 'Home Page'),
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Sağdan sola kaydırma
            const end = Offset.zero;
            var tween = Tween(begin: begin, end: end);

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    });



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24, // Arka plan rengi
      body: Center(
        child: Image.asset('images/NapsakyaLogo.jpg', width: 200, height: 200), // Uygulamanın logosu
      ),
    );
  }
}
