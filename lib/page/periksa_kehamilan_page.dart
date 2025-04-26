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
        "icon": Icons.pregnant_woman,
        "page": const DataKehamilanPage()
      },
      {
        "title": "Pemeriksaan Fisik",
        "icon": Icons.monitor_heart,
        "page": const PemeriksaanFisikPage()
      },
      {
        "title": "Imunisasi dan Pemberian Obat",
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => categories[index]["page"]),
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.pink.shade100,
                        child: Icon(
                          categories[index]["icon"],
                          color: Colors.pink,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        categories[index]["title"],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
