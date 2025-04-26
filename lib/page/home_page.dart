import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pemeriksaan_balita_page.dart';
import 'vaksin_imunisasi_page.dart';
import 'periksa_kehamilan_page.dart';
import 'laporan_page.dart';
import 'master_data_page.dart';
import 'welcome_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int balitaCount = 0;
  int ibuHamilCount = 0;
  int jadwalVaksinCount = 1;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    try {
      final balita =
          await FirebaseFirestore.instance.collection('balita').count().get();
      final ibuHamil = await FirebaseFirestore.instance
          .collection('ibu_hamil')
          .count()
          .get();
      final jadwalVaksin = await FirebaseFirestore.instance
          .collection('jadwal_vaksinasi')
          .count()
          .get();

      setState(() {
        balitaCount = balita.count!;
        ibuHamilCount = ibuHamil.count!;
        jadwalVaksinCount = jadwalVaksin.count!;
      });
    } catch (e) {
      print('Fetch count error: $e');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const WelcomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      drawer: isDesktop ? null : _buildDrawer(),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFA76DB8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDesktop),
                  const SizedBox(height: 20),
                  _buildHighlights(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Builder(
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isDesktop)
                IconButton(
                  icon: const Icon(Icons.menu, size: 30),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              const SizedBox(width: 10),
              const Text("E-PosyanduKu",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          _buildProfile(),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') _logout();
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Text("Akun", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage("images/posyandu_logo.png")),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlights() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildHighlightCard(
              "Jumlah Balita", balitaCount, Icons.child_care, Colors.pink),
          _buildHighlightCard("Jumlah Ibu Hamil", ibuHamilCount,
              Icons.pregnant_woman, Colors.deepPurple),
          _buildHighlightCard("Jadwal Vaksin", jadwalVaksinCount,
              Icons.event_available, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(
      String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8A2387), Color(0xFFE94057)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
              child: const Text("Menu",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            _menuItem("Pemeriksaan Balita", const PemeriksaanBalitaPage()),
            _menuItem("Vaksin dan Imunisasi", const VaksinImunisasiPage()),
            _menuItem("Periksa Kehamilan", const PeriksaKehamilanPage()),
            _menuItem("Laporan", const LaporanPage()),
            _menuItem("Master Data", const MasterDataPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8A2387), Color(0xFFE94057)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _menuButton("Pemeriksaan Balita", const PemeriksaanBalitaPage()),
          _menuButton("Vaksin dan Imunisasi", const VaksinImunisasiPage()),
          _menuButton("Periksa Kehamilan", const PeriksaKehamilanPage()),
          _menuButton("Layanan Kesehatan", const LaporanPage()),
          _menuButton("Master Data", const MasterDataPage()),
        ],
      ),
    );
  }

  Widget _menuItem(String title, Widget page) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _menuButton(String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
