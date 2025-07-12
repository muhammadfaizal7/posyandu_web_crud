import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:posyandu_web_crud/page/vaksin_imunisasi/riwayat_vaksin_page.dart';

class JadwalVaksinPage extends StatefulWidget {
  const JadwalVaksinPage({super.key});

  @override
  _JadwalVaksinPageState createState() => _JadwalVaksinPageState();
}

class _JadwalVaksinPageState extends State<JadwalVaksinPage> {
  final CollectionReference _jadwalVaksinCollection =
      FirebaseFirestore.instance.collection("jadwal_vaksin");

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempMonth = _selectedMonth;
        int tempYear = _selectedYear;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.filter_alt,
                      color: Color(0xFFD81B60),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Pilih Bulan & Tahun",
                    style: TextStyle(
                      color: Color(0xFF263238),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: DropdownButton<int>(
                      value: tempMonth,
                      isExpanded: true,
                      underline: Container(),
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            DateFormat('MMMM', 'id_ID')
                                .format(DateTime(2024, index + 1)),
                            style: const TextStyle(
                              color: Color(0xFF495057),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                      onChanged: (value) {
                        setDialogState(() {
                          tempMonth = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: DropdownButton<int>(
                      value: tempYear,
                      isExpanded: true,
                      underline: Container(),
                      items: [2024, 2025, 2026].map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(
                            "Tahun $year",
                            style: const TextStyle(
                              color: Color(0xFF495057),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          tempYear = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6C757D),
                  ),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD81B60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = tempMonth;
                      _selectedYear = tempYear;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Tampilkan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateStatusVaksin(String docId) async {
    await _jadwalVaksinCollection.doc(docId).update({"status_vaksin": "Sudah"});
  }

  void _tambahJadwalVaksin() {
    TextEditingController posyanduController = TextEditingController();
    TextEditingController jenisVaksinController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFFD81B60),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Tambah Jadwal Vaksin",
                    style: TextStyle(
                      color: Color(0xFF263238),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: TextField(
                      controller: posyanduController,
                      decoration: const InputDecoration(
                        labelText: "Posyandu",
                        prefixIcon:
                            Icon(Icons.location_on, color: Color(0xFF6C757D)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: TextField(
                      controller: jenisVaksinController,
                      decoration: const InputDecoration(
                        labelText: "Jenis Vaksin",
                        prefixIcon:
                            Icon(Icons.vaccines, color: Color(0xFF6C757D)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.calendar_today,
                          color: Color(0xFF6C757D)),
                      title: Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(selectedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF495057),
                        ),
                      ),
                      subtitle: const Text(
                        "Ketuk untuk mengubah",
                        style: TextStyle(
                          color: Color(0xFF6C757D),
                          fontSize: 12,
                        ),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2026),
                        );
                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );
                          if (pickedTime != null) {
                            setDialogState(() {
                              selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6C757D),
                  ),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD81B60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    if (posyanduController.text.isEmpty ||
                        jenisVaksinController.text.isEmpty) return;

                    await _jadwalVaksinCollection.add({
                      "posyandu": posyanduController.text,
                      "jenis_vaksin": jenisVaksinController.text,
                      "tanggal_vaksin": Timestamp.fromDate(selectedDate),
                      "bulan": selectedDate.month,
                      "tahun": selectedDate.year,
                      "status_vaksin": "Belum",
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD81B60),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Jadwal Imunisasi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.filter_alt),
              ),
              onPressed: _showFilterDialog,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RiwayatVaksinPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card dengan informasi bulan/tahun
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFD81B60), const Color(0xFFE91E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD81B60).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Jadwal Bulan Ini",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${DateFormat('MMMM yyyy', 'id_ID').format(DateTime(_selectedYear, _selectedMonth))}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _jadwalVaksinCollection
                  .where("bulan", isEqualTo: _selectedMonth)
                  .where("tahun", isEqualTo: _selectedYear)
                  .where("status_vaksin", isEqualTo: "Belum")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF0277BD)),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE4EC),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Color(0xFFD81B60),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Tidak ada jadwal vaksin",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF495057),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Tambah jadwal vaksin baru dengan menekan tombol (+)",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6C757D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    String formattedDate = data["tanggal_vaksin"] != null
                        ? DateFormat('dd MMM yyyy, HH:mm').format(
                            (data["tanggal_vaksin"] as Timestamp).toDate())
                        : "Tidak ada tanggal";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE4EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.vaccines,
                            color: Color(0xFFD81B60),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          data["posyandu"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCE4EC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                data["jenis_vaksin"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFD81B60),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Color(0xFF6C757D),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton(
                            icon: const Icon(Icons.more_vert,
                                color: Color(0xFF6C757D)),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: "done",
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Color(0xFF2E7D32)),
                                    SizedBox(width: 8),
                                    Text("Sudah Dilakukan"),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == "done") {
                                _updateStatusVaksin(document.id);
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD81B60),
        foregroundColor: Colors.white,
        onPressed: _tambahJadwalVaksin,
        icon: const Icon(Icons.add),
        label: const Text("Tambah Jadwal"),
      ),
    );
  }
}
