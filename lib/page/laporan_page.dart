import 'package:flutter/material.dart';
import 'package:posyandu_web_crud/page/laporan/daftar_hadir_page.dart';
import 'package:posyandu_web_crud/page/laporan/laporan_bulanan_page.dart';
import 'package:posyandu_web_crud/page/laporan/formulir_asi_page.dart';
import 'package:posyandu_web_crud/page/laporan/data_bgm_page.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Posyandu"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildLaporanCard(
              context,
              title: "Daftar Hadir Pengunjung Posyandu",
              description:
                  "Laporan mengenai kehadiran pengunjung pada kegiatan posyandu.",
              icon: Icons.group,
              targetPage: const DaftarHadirPage(),
            ),
            const SizedBox(height: 16),
            _buildLaporanCard(
              context,
              title: "Laporan Bulanan Kelompok Penimbang",
              description:
                  "Rekap bulanan hasil penimbangan balita di posyandu.",
              icon: Icons.assignment,
              targetPage: const LaporanBulananPage(),
            ),
            const SizedBox(height: 16),
            _buildLaporanCard(
              context,
              title: "Formulir Pencatatan Pemberian ASI Eksklusif",
              description:
                  "Catatan pemberian ASI eksklusif pada bayi usia 0-6 bulan.",
              icon: Icons.baby_changing_station,
              targetPage: const FormulirAsiPage(),
            ),
            const SizedBox(height: 16),
            _buildLaporanCard(
              context,
              title: "Data Anak BGM R & T",
              description:
                  "Data anak-anak dengan Berat Badan Gizi Buruk (BGM) kategori Retardasi & Terapi.",
              icon: Icons.health_and_safety,
              targetPage: const DataBgmPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporanCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Widget targetPage,
  }) {
    return Card(
      elevation: 5,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.pink,
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
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
