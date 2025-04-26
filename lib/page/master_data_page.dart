import 'package:flutter/material.dart';
import 'package:posyandu_web_crud/page/master_data/data_balita.dart';
import 'package:posyandu_web_crud/page/master_data/data_ibuhamil.dart';

class MasterDataPage extends StatelessWidget {
  const MasterDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD81B60),
        title: const Text("Master Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Data:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),
            _buildMasterDataCard(
              title: "Data Balita",
              description: "Lihat dan kelola data balita yang terdaftar.",
              icon: Icons.child_care,
              color: Colors.pinkAccent.shade100,
              context: context,
              targetPage: const DataBalitaPage(),
            ),
            const SizedBox(height: 20),
            _buildMasterDataCard(
              title: "Data Ibu Hamil",
              description: "Lihat dan kelola data ibu hamil yang terdaftar.",
              icon: Icons.pregnant_woman,
              color: Colors.pink.shade200,
              context: context,
              targetPage: const DataIbuHamilPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterDataCard({
    required String title,
    required String description,
    required IconData icon,
    required BuildContext context,
    required Widget targetPage,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
