import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:posyandu_web_crud/firebase_options.dart';
import 'package:posyandu_web_crud/page/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD Posyandu',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          // 🔥 Menampilkan indikator loading selama Firebase diinisialisasi
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ❌ Menampilkan pesan error jika Firebase gagal diinisialisasi
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  "Gagal menginisialisasi Firebase: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            );
          }

          // ✅ Jika berhasil, lanjutkan ke halaman utama
          print("✅ Firebase Initialized Successfully!");
          return const WelcomePage();
        },
      ),
    );
  }
}
