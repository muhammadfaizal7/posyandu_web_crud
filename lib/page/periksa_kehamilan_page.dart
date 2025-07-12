import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posyandu_web_crud/page/periksa_kehamilan/data_kehamilan_page.dart';
import 'package:posyandu_web_crud/page/periksa_kehamilan/imunisasi_obat_page.dart';
import 'package:posyandu_web_crud/page/periksa_kehamilan/pemeriksaan_fisik_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Periksa Kehamilan',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const PeriksaKehamilanPage(),
    );
  }
}

class PeriksaKehamilanPage extends StatelessWidget {
  const PeriksaKehamilanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        "title": "Data Kehamilan",
        "description": "Data umum ibu hamil yang terdaftar.",
        "icon": Icons.pregnant_woman,
        "page": const DataKehamilanPage()
      },
      {
        "title": "Pemeriksaan Fisik",
        "description": "Catatan hasil pemeriksaan fisik ibu hamil.",
        "icon": Icons.monitor_heart,
        "page": const PemeriksaanFisikPage()
      },
      {
        "title": "Imunisasi dan Pemberian Obat",
        "description": "Riwayat imunisasi dan obat yang diberikan.",
        "icon": Icons.vaccines,
        "page": const ImunisasiObatPage()
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Periksa Kehamilan"),
        backgroundColor: const Color(0xFFD81B60),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFF0F5),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.pink.shade100,
                child: Icon(
                  categories[index]["icon"],
                  color: Colors.pink,
                  size: 28,
                ),
              ),
              title: Text(
                categories[index]["title"],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                categories[index]["description"],
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => categories[index]["page"]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
