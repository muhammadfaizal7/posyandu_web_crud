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
              backgroundColor: Colors.pink[50],
              title: const Text("Pilih Bulan & Tahun",
                  style: TextStyle(color: Colors.deepPurple)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: tempMonth,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text("Bulan ${index + 1}"),
                      );
                    }),
                    onChanged: (value) {
                      setDialogState(() {
                        tempMonth = value!;
                      });
                    },
                  ),
                  DropdownButton<int>(
                    value: tempYear,
                    items: [2024, 2025, 2026].map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text("Tahun $year"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        tempYear = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = tempMonth;
                        _selectedYear = tempYear;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Tampilkan")),
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
              backgroundColor: Colors.pink[50],
              title: const Text("Tambah Jadwal Vaksin",
                  style: TextStyle(color: Colors.deepPurple)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: posyanduController,
                    decoration: const InputDecoration(labelText: "Posyandu"),
                  ),
                  TextField(
                    controller: jenisVaksinController,
                    decoration:
                        const InputDecoration(labelText: "Jenis Vaksin"),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    tileColor: Colors.pink[100],
                    title: Text(
                      "Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(selectedDate)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.calendar_today),
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent),
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
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD81B60),
        title: const Text("Jadwal Imunisasi"),
        actions: [
          IconButton(
              icon: const Icon(Icons.filter_alt), onPressed: _showFilterDialog),
          IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RiwayatVaksinPage()),
                );
              }),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _jadwalVaksinCollection
            .where("bulan", isEqualTo: _selectedMonth)
            .where("tahun", isEqualTo: _selectedYear)
            .where("status_vaksin", isEqualTo: "Belum")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Tidak ada jadwal vaksin",
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12.0),
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              String formattedDate = data["tanggal_vaksin"] != null
                  ? DateFormat('dd MMM yyyy, HH:mm')
                      .format((data["tanggal_vaksin"] as Timestamp).toDate())
                  : "Tidak ada tanggal";

              return Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.lightBlueAccent,
                    child: Icon(Icons.vaccines, color: Colors.white),
                  ),
                  title: Text(data["posyandu"],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Jenis: ${data["jenis_vaksin"]}",
                          style: const TextStyle(fontSize: 14)),
                      Text("Tanggal: $formattedDate",
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "done",
                        child: Text("Sudah Dilakukan"),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == "done") {
                        _updateStatusVaksin(document.id);
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: _tambahJadwalVaksin,
        child: const Icon(Icons.add),
      ),
    );
  }
}
