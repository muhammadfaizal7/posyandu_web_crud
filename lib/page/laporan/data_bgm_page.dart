import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataBgmPage extends StatefulWidget {
  const DataBgmPage({super.key});

  @override
  State<DataBgmPage> createState() => _DataBgmPageState();
}

class _DataBgmPageState extends State<DataBgmPage> {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection("data_bgm");

  final List<String> _keteranganOptions = [
    "BGM",
    "R",
    "2T",
    "GB",
    "GK",
    "Stunting",
    "Wasting",
  ];
  final List<int> _tahunOptions = [2023, 2024, 2025, 2026];

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  Future<void> _showFilterDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Filter Bulan & Tahun"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: const InputDecoration(labelText: "Bulan"),
              items: List.generate(
                  12,
                  (index) => DropdownMenuItem(
                      value: index + 1, child: Text("Bulan ${index + 1}"))),
              onChanged: (val) => setState(() => _selectedMonth = val!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(labelText: "Tahun"),
              items: _tahunOptions
                  .map((year) =>
                      DropdownMenuItem(value: year, child: Text("$year")))
                  .toList(),
              onChanged: (val) => setState(() => _selectedYear = val!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Terapkan"),
          ),
        ],
      ),
    );
  }

  Future<void> _tambahAtauEditData({
    String? docId,
    String? namaAnak,
    String? tanggalLahir,
    String? usia,
    double? beratBadan,
    double? tinggiBadan,
    String? keterangan,
    int? bulan,
    int? tahun,
  }) async {
    final TextEditingController namaController =
        TextEditingController(text: namaAnak);
    final TextEditingController tanggalLahirController =
        TextEditingController(text: tanggalLahir);
    final TextEditingController usiaController =
        TextEditingController(text: usia);
    final TextEditingController bbController = TextEditingController(
        text: beratBadan != null ? beratBadan.toString() : "");
    final TextEditingController tbController = TextEditingController(
        text: tinggiBadan != null ? tinggiBadan.toString() : "");

    String? selectedKeterangan = keterangan;
    int? selectedBulan = bulan ?? _selectedMonth;
    int? selectedTahun = tahun ?? _selectedYear;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFFF0F5),
          title: Text(docId == null ? "Tambah Data BGM" : "Edit Data BGM"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama Anak",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tanggalLahirController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Tanggal Lahir",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2026),
                    );
                    if (picked != null) {
                      tanggalLahirController.text =
                          DateFormat('yyyy-MM-dd').format(picked);

                      int age = DateTime.now().year - picked.year;
                      if (DateTime.now().month < picked.month ||
                          (DateTime.now().month == picked.month &&
                              DateTime.now().day < picked.day)) {
                        age--;
                      }
                      setDialogState(() {
                        usiaController.text = "$age tahun";
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: usiaController,
                  decoration: const InputDecoration(
                    labelText: "Usia",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bbController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Berat Badan (kg)",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tbController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Tinggi Badan (cm)",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedKeterangan,
                  decoration: const InputDecoration(
                    labelText: "Keterangan",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _keteranganOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedKeterangan = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedBulan,
                  decoration: const InputDecoration(labelText: "Bulan"),
                  items: List.generate(
                      12,
                      (index) => DropdownMenuItem(
                          value: index + 1, child: Text("Bulan ${index + 1}"))),
                  onChanged: (val) => setDialogState(() => selectedBulan = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedTahun,
                  decoration: const InputDecoration(labelText: "Tahun"),
                  items: _tahunOptions
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
                if (namaController.text.isEmpty ||
                    tanggalLahirController.text.isEmpty ||
                    usiaController.text.isEmpty ||
                    bbController.text.isEmpty ||
                    tbController.text.isEmpty ||
                    selectedKeterangan == null ||
                    selectedBulan == null ||
                    selectedTahun == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lengkapi semua data!")));
                  return;
                }

                final data = {
                  "nama_anak": namaController.text,
                  "tanggal_lahir": tanggalLahirController.text,
                  "usia": usiaController.text,
                  "berat_badan": double.tryParse(bbController.text),
                  "tinggi_badan": double.tryParse(tbController.text),
                  "keterangan": selectedKeterangan,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text("Data Anak BGM / R / 2T"),
        backgroundColor: Colors.pink,
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
            return const Center(child: Text("Belum ada data anak BGM."));
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
                            child: const Icon(Icons.child_care,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${data["nama_anak"]}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          IconButton(
                              onPressed: () => _tambahAtauEditData(
                                    docId: doc.id,
                                    namaAnak: data["nama_anak"],
                                    tanggalLahir: data["tanggal_lahir"],
                                    usia: data["usia"],
                                    beratBadan: data["berat_badan"],
                                    tinggiBadan: data["tinggi_badan"],
                                    keterangan: data["keterangan"],
                                    bulan: data["bulan"],
                                    tahun: data["tahun"],
                                  ),
                              icon:
                                  const Icon(Icons.edit, color: Colors.purple)),
                          IconButton(
                              onPressed: () => _hapusData(doc.id),
                              icon:
                                  const Icon(Icons.delete, color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Tanggal Lahir: ${data["tanggal_lahir"]}"),
                      Text("Usia: ${data["usia"]}"),
                      Text(
                          "BB: ${data["berat_badan"]} kg, TB: ${data["tinggi_badan"]} cm"),
                      Text("Keterangan: ${data["keterangan"]}"),
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
