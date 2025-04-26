import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PemeriksaanBalitaPage extends StatefulWidget {
  const PemeriksaanBalitaPage({super.key});

  @override
  _PemeriksaanBalitaPageState createState() => _PemeriksaanBalitaPageState();
}

class _PemeriksaanBalitaPageState extends State<PemeriksaanBalitaPage> {
  final CollectionReference _pemeriksaanCollection =
      FirebaseFirestore.instance.collection("pemeriksaan_balita");
  final CollectionReference _balitaCollection =
      FirebaseFirestore.instance.collection("balita");

  int _selectedMonth = 1;
  int _selectedYear = 2024;

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Filter Pemeriksaan",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedMonth,
                decoration: const InputDecoration(
                  labelText: "Pilih Bulan",
                  border: OutlineInputBorder(),
                ),
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text("Bulan ${index + 1}"),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  labelText: "Pilih Tahun",
                  border: OutlineInputBorder(),
                ),
                items: [2024, 2025, 2026].map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text("$year"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value!;
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
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text("Tampilkan")),
          ],
        );
      },
    );
  }

  void _pilihBalitaDanTambahPemeriksaan() async {
    QuerySnapshot balitaSnapshot = await _balitaCollection.get();

    if (balitaSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak ada balita yang tersedia!")));
      return;
    }

    List<DocumentSnapshot> balitaList = balitaSnapshot.docs;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Pilih Balita",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: balitaList.map((balita) {
                Map<String, dynamic> data =
                    balita.data() as Map<String, dynamic>;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(data["nama"],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("NIK: ${data["nik"]}"),
                    onTap: () {
                      Navigator.pop(context);
                      _tambahAtauEditPemeriksaan(
                          nik: data["nik"], nama: data["nama"]);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _tambahAtauEditPemeriksaan({
    String? docId,
    String? nik,
    String? nama,
    double? tinggiBadan,
    double? beratBadan,
    double? lingkarKepala,
    int? bulan,
    int? tahun,
  }) {
    bulan ??= _selectedMonth;
    tahun ??= _selectedYear;

    final TextEditingController tinggiBadanController =
        TextEditingController(text: tinggiBadan?.toString() ?? "");
    final TextEditingController beratBadanController =
        TextEditingController(text: beratBadan?.toString() ?? "");
    final TextEditingController lingkarKepalaController =
        TextEditingController(text: lingkarKepala?.toString() ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(docId == null ? "Tambah Pemeriksaan" : "Edit Pemeriksaan",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Balita: $nama\nNIK: $nik",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: bulan,
                  decoration: const InputDecoration(
                    labelText: "Bulan",
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text("Bulan ${index + 1}"),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      bulan = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: tahun,
                  decoration: const InputDecoration(
                    labelText: "Tahun",
                    border: OutlineInputBorder(),
                  ),
                  items: [2024, 2025, 2026].map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text("$year"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      tahun = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: tinggiBadanController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Tinggi Badan (cm)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: beratBadanController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Berat Badan (kg)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lingkarKepalaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Lingkar Kepala (cm)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (tinggiBadanController.text.isEmpty ||
                    beratBadanController.text.isEmpty ||
                    lingkarKepalaController.text.isEmpty) return;

                if (docId == null) {
                  await _pemeriksaanCollection.add({
                    "nik": nik,
                    "nama": nama,
                    "bulan": bulan,
                    "tahun": tahun,
                    "tinggi_badan": double.parse(tinggiBadanController.text),
                    "berat_badan": double.parse(beratBadanController.text),
                    "lingkar_kepala":
                        double.parse(lingkarKepalaController.text),
                    "created_at": FieldValue.serverTimestamp(),
                  });
                } else {
                  await _pemeriksaanCollection.doc(docId).update({
                    "tinggi_badan": double.parse(tinggiBadanController.text),
                    "berat_badan": double.parse(beratBadanController.text),
                    "lingkar_kepala":
                        double.parse(lingkarKepalaController.text),
                  });
                }

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(docId == null
                        ? "Data berhasil ditambahkan!"
                        : "Data berhasil diperbarui!")));

                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _hapusPemeriksaan(String docId) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Apakah Anda yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Hapus")),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _pemeriksaanCollection.doc(docId).delete();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data pemeriksaan dihapus!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pemeriksaan Balita"),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          )
        ],
      ),
      body: StreamBuilder(
        stream: _pemeriksaanCollection
            .where("bulan", isEqualTo: _selectedMonth)
            .where("tahun", isEqualTo: _selectedYear)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          return ListView(
            padding: const EdgeInsets.all(10),
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Card(
                color: Colors.lightGreen.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    "${data["nama"]} (NIK: ${data["nik"]})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      "Tinggi: ${data["tinggi_badan"]} cm\nBerat: ${data["berat_badan"]} kg\nLingkar Kepala: ${data["lingkar_kepala"]} cm"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.pinkAccent),
                          onPressed: () {
                            _tambahAtauEditPemeriksaan(
                                docId: document.id,
                                nik: data["nik"],
                                nama: data["nama"],
                                tinggiBadan: data["tinggi_badan"],
                                beratBadan: data["berat_badan"],
                                lingkarKepala: data["lingkar_kepala"],
                                bulan: data["bulan"],
                                tahun: data["tahun"]);
                          }),
                      IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            _hapusPemeriksaan(document.id);
                          }),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pilihBalitaDanTambahPemeriksaan,
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
