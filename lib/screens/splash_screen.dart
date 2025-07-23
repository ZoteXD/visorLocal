// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:nodrive/data/manga_service.dart';
import 'package:nodrive/screens/manga_list_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Precargamos los mangas mientras mostramos el splash
    await MangaService.getAvailableMangas();
    
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MangaListScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'appLogo',
              child: Image.asset(
                'assets/icon/logo_Enchilada.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enchilada Scan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}