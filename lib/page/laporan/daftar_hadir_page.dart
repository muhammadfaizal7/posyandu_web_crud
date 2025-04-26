import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DaftarHadirPage extends StatefulWidget {
  const DaftarHadirPage({super.key});

  @override
  State<DaftarHadirPage> createState() => _DaftarHadirPageState();
}

class _DaftarHadirPageState extends State<DaftarHadirPage> {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection("daftar_hadir");

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _umurKategori = [
    "0-11 bulan",
    "12-23 bulan",
    "24-59 bulan"
  ];
  final List<String> _metodeKB = [
    "Pil",
    "Suntik",
    "Implan",
    "IUD",
    "Kondom",
    "MOW",
    "MOP",
    "Tidak KB"
  ];
  final List<int> _tahunList = [2023, 2024, 2025, 2026];

  Future<void> _showFilterDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filter Bulan & Tahun"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedMonth,
                decoration: const InputDecoration(labelText: "Bulan"),
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                      value: index + 1, child: Text("Bulan ${index + 1}"));
                }),
                onChanged: (value) => setState(() => _selectedMonth = value!),
              ),
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(labelText: "Tahun"),
                items: _tahunList
                    .map((year) =>
                        DropdownMenuItem(value: year, child: Text("$year")))
                    .toList(),
                onChanged: (value) => setState(() => _selectedYear = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal")),
            ElevatedButton(
                onPressed: () => setState(() => Navigator.pop(context)),
                child: const Text("Terapkan")),
          ],
        );
      },
    );
  }

  Future<void> _hapusData(String docId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Data"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus")),
        ],
      ),
    );

    if (confirm == true) {
      await _collection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil dihapus.")));
    }
  }

  void _tambahAtauEditData({
    String? docId,
    String? namaOrtu,
    String? namaBalita,
    String? umur,
    bool asiEksklusif = false,
    String? kb,
    int? bulan,
    int? tahun,
  }) {
    final TextEditingController namaOrtuController =
        TextEditingController(text: namaOrtu);
    final TextEditingController namaBalitaController =
        TextEditingController(text: namaBalita);
    String? selectedUmur = umur;
    bool asi = asiEksklusif;
    String? selectedKB = kb;
    int? selectedBulan = bulan ?? _selectedMonth;
    int? selectedTahun = tahun ?? _selectedYear;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFFF0F5),
          title: Text(docId == null ? "Tambah Kehadiran" : "Edit Kehadiran"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: namaOrtuController,
                    decoration:
                        const InputDecoration(labelText: "Nama Orang Tua")),
                TextField(
                    controller: namaBalitaController,
                    decoration:
                        const InputDecoration(labelText: "Nama Balita")),
                DropdownButtonFormField<String>(
                  value: selectedUmur,
                  decoration: const InputDecoration(labelText: "Umur Balita"),
                  items: _umurKategori
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedUmur = val),
                ),
                CheckboxListTile(
                  value: asi,
                  onChanged: (val) => setDialogState(() => asi = val!),
                  title: const Text("ASI Eksklusif 0-6 bulan"),
                ),
                DropdownButtonFormField<String>(
                  value: selectedKB,
                  decoration:
                      const InputDecoration(labelText: "Metode KB Orang Tua"),
                  items: _metodeKB
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedKB = val),
                ),
                DropdownButtonFormField<int>(
                  value: selectedBulan,
                  decoration: const InputDecoration(labelText: "Bulan"),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                        value: index + 1, child: Text("Bulan ${index + 1}"));
                  }),
                  onChanged: (val) => setDialogState(() => selectedBulan = val),
                ),
                DropdownButtonFormField<int>(
                  value: selectedTahun,
                  decoration: const InputDecoration(labelText: "Tahun"),
                  items: _tahunList
                      .map((year) =>
                          DropdownMenuItem(value: year, child: Text("$year")))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedTahun = val),
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
                if (namaOrtuController.text.isEmpty ||
                    namaBalitaController.text.isEmpty ||
                    selectedUmur == null ||
                    selectedKB == null ||
                    selectedBulan == null ||
                    selectedTahun == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Isi semua data terlebih dahulu.")));
                  return;
                }

                final Map<String, dynamic> data = {
                  "nama_ortu": namaOrtuController.text,
                  "nama_balita": namaBalitaController.text,
                  "umur_kategori": selectedUmur,
                  "asi_eksklusif": asi,
                  "kb_ortu": selectedKB,
                  "bulan": selectedBulan,
                  "tahun": selectedTahun,
                  "created_at": FieldValue.serverTimestamp(),
                };

                if (docId == null) {
                  await _collection.add(data);
                } else {
                  await _collection.doc(docId).update(data);
                }

                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text("Daftar Hadir Posyandu"),
        backgroundColor: const Color(0xFFD81B60),
        actions: [
          IconButton(
              onPressed: _showFilterDialog, icon: const Icon(Icons.filter_alt)),
          IconButton(
              onPressed: () => _tambahAtauEditData(),
              icon: const Icon(Icons.add)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _collection
            .where("bulan", isEqualTo: _selectedMonth)
            .where("tahun", isEqualTo: _selectedYear)
            .orderBy("created_at", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada data kehadiran."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.pink.shade200,
                            child:
                                const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${data["nama_balita"]} (Ortu: ${data["nama_ortu"]})",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                              onPressed: () => _tambahAtauEditData(
                                    docId: doc.id,
                                    namaOrtu: data["nama_ortu"],
                                    namaBalita: data["nama_balita"],
                                    umur: data["umur_kategori"],
                                    asiEksklusif:
                                        data["asi_eksklusif"] ?? false,
                                    kb: data["kb_ortu"],
                                    bulan: data["bulan"],
                                    tahun: data["tahun"],
                                  ),
                              icon: const Icon(Icons.edit,
                                  color: Colors.deepPurple)),
                          IconButton(
                              onPressed: () => _hapusData(doc.id),
                              icon:
                                  const Icon(Icons.delete, color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Umur: ${data["umur_kategori"]}"),
                      Text(
                          "ASI Eksklusif: ${data["asi_eksklusif"] ? "✓" : "-"}"),
                      Text("KB Ortu: ${data["kb_ortu"]}"),
                      Text("Bulan: ${data["bulan"]}, Tahun: ${data["tahun"]}"),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
