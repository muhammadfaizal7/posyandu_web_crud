import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:posyandu_web_crud/firebase_options.dart';
import 'package:posyandu_web_crud/page/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🗓️ Inisialisasi locale untuk tanggal format (ID)
  await initializeDateFormatting('id', null);

  // 🚀 Jalankan Aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Posyandu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          // 🔄 Menampilkan loading saat inisialisasi Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ❌ Menampilkan error jika gagal inisialisasi
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Gagal inisialisasi Firebase:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
              ),
            );
          }

          // ✅ Firebase berhasil diinisialisasi
          print("✅ Firebase Initialized Successfully!");
          return const WelcomePage();
        },
      ),
    );
  }
}
