import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedMonth = DateTime.now().month;
  int balitaCount = 0, ibuCount = 0, vaksinCount = 0;
  List<Map<String, dynamic>> monthlyBalitaData = [];
  List<Map<String, dynamic>> monthlyIbuData = [];
  List<Map<String, dynamic>> monthlyVaksinData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyData(selectedMonth);
    _fetchYearlyData();
  }

  Future<void> _fetchMonthlyData(int month) async {
    setState(() => isLoading = true);
    try {
      final year = DateTime.now().year;

      // Query untuk pemeriksaan balita
      final balitaSnap = await FirebaseFirestore.instance
          .collection('pemeriksaan_balita')
          .where('bulan', isEqualTo: month)
          .where('tahun', isEqualTo: year)
          .get();

      // Query untuk pemeriksaan ibu
      QuerySnapshot ibuSnap;
      try {
        final ibuRawSnap = await FirebaseFirestore.instance
            .collection('pemeriksaan_fisik')
            .get();

        final filteredIbu = ibuRawSnap.docs.where((doc) {
          // ignore: unnecessary_cast
          final data = doc.data() as Map<String, dynamic>;

          final dynamicBulan = data['bulan'];
          final dynamicTahun = data['tahun'];

          // Pastikan nilai bisa dikonversi ke int
          final parsedBulan = int.tryParse(dynamicBulan.toString());
          final parsedTahun = int.tryParse(dynamicTahun.toString());

          return parsedBulan == month && parsedTahun == year;
        }).toList();

        ibuSnap = MockQuerySnapshot(filteredIbu);
      } catch (e) {
        print('Error parsing data pemeriksaan_fisik: $e');
        ibuSnap = MockQuerySnapshot([]);
      }

      // Query untuk vaksin
      final vaksinSnap = await FirebaseFirestore.instance
          .collection('jadwal_vaksin')
          .where('bulan', isEqualTo: month)
          .where('tahun', isEqualTo: year)
          .get();

      setState(() {
        balitaCount = balitaSnap.size;
        ibuCount = ibuSnap.size;
        vaksinCount = vaksinSnap.size;
      });

      print(
          'Data fetched - Balita: $balitaCount, Ibu: $ibuCount, Vaksin: $vaksinCount');
    } catch (e) {
      print('Error fetching monthly data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengambil data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchYearlyData() async {
    final year = DateTime.now().year;

    List<Map<String, dynamic>> balitaData = List.generate(
        12,
        (i) => {
              'month': i + 1,
              'count': 0,
              'monthName': DateFormat.MMMM('id').format(DateTime(0, i + 1)),
            });

    List<Map<String, dynamic>> ibuData = List.generate(
        12,
        (i) => {
              'month': i + 1,
              'count': 0,
              'monthName': DateFormat.MMMM('id').format(DateTime(0, i + 1)),
            });

    List<Map<String, dynamic>> vaksinData = List.generate(
        12,
        (i) => {
              'month': i + 1,
              'count': 0,
              'monthName': DateFormat.MMMM('id').format(DateTime(0, i + 1)),
            });

    try {
      // Fetch data balita
      final balitaSnap = await FirebaseFirestore.instance
          .collection('pemeriksaan_balita')
          .where('tahun', isEqualTo: year)
          .get();

      for (var doc in balitaSnap.docs) {
        final data = doc.data();
        final bulan = data['bulan'];
        if (bulan is int && bulan >= 1 && bulan <= 12) {
          balitaData[bulan - 1]['count'] += 1;
        }
      }

      // Fetch data ibu dengan handling error
      final ibuRawSnap = await FirebaseFirestore.instance
          .collection('pemeriksaan_fisik')
          .get();

      final filteredIbu = ibuRawSnap.docs.where((doc) {
        // ignore: unnecessary_cast
        final data = doc.data() as Map<String, dynamic>;
        final bulan = int.tryParse(data['bulan']?.toString() ?? '');
        final tahun = int.tryParse(data['tahun']?.toString() ?? '');

        return bulan != null &&
            tahun != null &&
            tahun == year &&
            bulan >= 1 &&
            bulan <= 12;
      });

      for (var doc in filteredIbu) {
        // ignore: unnecessary_cast
        final data = doc.data() as Map<String, dynamic>;
        final bulan = int.parse(data['bulan'].toString());
        ibuData[bulan - 1]['count'] = (ibuData[bulan - 1]['count'] as int) + 1;
      }

      // Fetch data vaksin
      final vaksinSnap = await FirebaseFirestore.instance
          .collection('jadwal_vaksin')
          .where('tahun', isEqualTo: year)
          .get();

      for (var doc in vaksinSnap.docs) {
        final data = doc.data();
        final bulan = data['bulan'];
        if (bulan is int && bulan >= 1 && bulan <= 12) {
          vaksinData[bulan - 1]['count'] += 1;
        }
      }

      setState(() {
        monthlyBalitaData = balitaData;
        monthlyIbuData = ibuData;
        monthlyVaksinData = vaksinData;
      });
    } catch (e) {
      print('Error fetching yearly data: $e');
    }
    print('monthlyIbuData: $monthlyIbuData');
  }

  Widget _buildLineChart(
      List<Map<String, dynamic>> data, String title, Color color) {
    if (data.isEmpty) return const SizedBox();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 35),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final bulan = value.toInt();
                          final monthData = data.firstWhere(
                            (e) => e['month'] == bulan,
                            orElse: () => {},
                          );
                          if (monthData.isNotEmpty) {
                            return Text(
                              monthData['monthName'].toString().substring(0, 3),
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: 12,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.map((e) {
                        final x = (e['month'] as int).toDouble();
                        final y = (e['count'] as int).toDouble();
                        return FlSpot(x, y);
                      }).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, int count, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 4),
              isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (!isDesktop)
              IconButton(
                icon: const Icon(Icons.menu, size: 30),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            const SizedBox(width: 8),
            const Text("Posyandu Anggrek Merah",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'logout') _logout();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'logout', child: Text('Logout')),
            const PopupMenuItem(value: 'refresh', child: Text('Refresh Data')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Akun", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage("images/posyandu_logo.png"),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
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
                children: [
                  _buildHeader(isDesktop),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _fetchMonthlyData(selectedMonth);
                          _fetchYearlyData();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                      DropdownButton<int>(
                        value: selectedMonth,
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(DateFormat.MMMM('id')
                                      .format(DateTime(0, m))),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedMonth = val);
                            _fetchMonthlyData(val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          GridView.count(
                            crossAxisCount: isDesktop ? 3 : 2,
                            childAspectRatio: isDesktop ? 1.5 : 1.2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildSummaryCard(
                                'Pemeriksaan Balita\nBulan Ini',
                                balitaCount,
                                Colors.pink,
                                Icons.child_care,
                              ),
                              _buildSummaryCard(
                                'Pemeriksaan Ibu\nBulan Ini',
                                ibuCount,
                                Colors.deepPurple,
                                Icons.pregnant_woman,
                              ),
                              _buildSummaryCard(
                                'Jadwal Vaksin\nBulan Ini',
                                vaksinCount,
                                Colors.teal,
                                Icons.healing,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLineChart(
                            monthlyBalitaData,
                            'Trend Pemeriksaan Balita (Tahun ${DateTime.now().year})',
                            Colors.pink,
                          ),
                          const SizedBox(height: 16),
                          _buildLineChart(
                            monthlyIbuData,
                            'Trend Pemeriksaan Ibu Hamil (Tahun ${DateTime.now().year})',
                            Colors.deepPurple,
                          ),
                          const SizedBox(height: 16),
                          _buildLineChart(
                            monthlyVaksinData,
                            'Trend Jadwal Vaksinasi (Tahun ${DateTime.now().year})',
                            Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8A2387), Color(0xFFE94057)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _buildSidebarButton(Icons.child_care, "Pemeriksaan Balita",
              const PemeriksaanBalitaPage()),
          _buildSidebarButton(
              Icons.healing, "Vaksin & Imunisasi", const VaksinImunisasiPage()),
          _buildSidebarButton(Icons.pregnant_woman, "Periksa Kehamilan",
              const PeriksaKehamilanPage()),
          _buildSidebarButton(Icons.assignment, "Laporan", const LaporanPage()),
          _buildSidebarButton(
              Icons.storage, "Master Data", const MasterDataPage()),
        ],
      ),
    );
  }

  Widget _buildSidebarButton(IconData icon, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Posyandu Anggrek Merah",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Menu Navigasi",
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.child_care, "Pemeriksaan Balita",
                const PemeriksaanBalitaPage()),
            _buildDrawerItem(Icons.healing, "Vaksin & Imunisasi",
                const VaksinImunisasiPage()),
            _buildDrawerItem(Icons.pregnant_woman, "Periksa Kehamilan",
                const PeriksaKehamilanPage()),
            _buildDrawerItem(Icons.assignment, "Laporan", const LaporanPage()),
            _buildDrawerItem(
                Icons.storage, "Master Data", const MasterDataPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}

// Mock class untuk handle QuerySnapshot ketika filtering manual
class MockQuerySnapshot implements QuerySnapshot {
  final List<QueryDocumentSnapshot> _docs;

  MockQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot> get docs => _docs;

  @override
  int get size => _docs.length;

  @override
  List<DocumentChange> get docChanges => throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
}
