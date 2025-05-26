import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormulirAsiPage extends StatefulWidget {
  const FormulirAsiPage({super.key});

  @override
  State<FormulirAsiPage> createState() => _FormulirAsiPageState();
}

class _FormulirAsiPageState extends State<FormulirAsiPage> {
  final CollectionReference _formulirAsi =
      FirebaseFirestore.instance.collection("formulir_asi");
  final CollectionReference _dataBalita =
      FirebaseFirestore.instance.collection("balita");

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final List<int> _tahunList = [2023, 2024, 2025, 2026];

  Future<void> _showFilterDialog() async {
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Filter Bulan & Tahun"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: tempMonth,
              decoration: const InputDecoration(labelText: "Bulan"),
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text("Bulan ${index + 1}"),
                );
              }),
              onChanged: (value) => tempMonth = value!,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: tempYear,
              decoration: const InputDecoration(labelText: "Tahun"),
              items: _tahunList
                  .map((year) =>
                      DropdownMenuItem(value: year, child: Text("$year")))
                  .toList(),
              onChanged: (value) => tempYear = value!,
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
              setState(() {
                _selectedMonth = tempMonth;
                _selectedYear = tempYear;
              });
              Navigator.pop(context);
            },
            child: const Text("Terapkan"),
          ),
        ],
      ),
    );
  }

  Future<void> _hapusData(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Data"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _formulirAsi.doc(docId).delete();
    }
  }

  void _tambahAtauEditData({
    String? docId,
    String? namaAnak,
    String? tanggalLahir,
    List<bool>? asiBulan,
  }) {
    final List<bool> asiStatus = List.generate(7, (i) => asiBulan?[i] ?? false);
    String? selectedNama = namaAnak;
    String selectedTanggal = tanggalLahir ?? "";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(docId == null ? "Tambah Data ASI" : "Edit Data ASI"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _dataBalita.orderBy('nama').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const CircularProgressIndicator();
                      final docs = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: selectedNama,
                        decoration: const InputDecoration(
                          labelText: "Nama Anak",
                          border: OutlineInputBorder(),
                        ),
                        items: docs.map<DropdownMenuItem<String>>((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nama = data['nama'] as String? ?? "-";
                          final timestamp = data['tanggal_lahir'];
                          return DropdownMenuItem<String>(
                            value: nama,
                            child: Text(nama),
                            onTap: () {
                              if (timestamp is Timestamp) {
                                final formattedDate = DateFormat('dd-MM-yyyy')
                                    .format(timestamp.toDate());
                                setStateDialog(
                                    () => selectedTanggal = formattedDate);
                              } else {
                                setStateDialog(() => selectedTanggal = "");
                              }
                            },
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setStateDialog(() => selectedNama = val),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("Tanggal Lahir: "),
                      Text(selectedTanggal),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Status ASI per Bulan (0–6)"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (i) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("$i"),
                          Checkbox(
                            value: asiStatus[i],
                            onChanged: (val) {
                              setStateDialog(() => asiStatus[i] = val ?? false);
                            },
                          ),
                        ],
                      );
                    }),
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
                  if (selectedNama == null || selectedTanggal.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Nama anak dan tanggal lahir wajib diisi")),
                    );
                    return;
                  }

                  final data = {
                    "namaAnak": selectedNama,
                    "tanggalLahir": selectedTanggal,
                    "bulan": _selectedMonth,
                    "tahun": _selectedYear,
                    "asiStatus": asiStatus,
                  };

                  if (docId == null) {
                    await _formulirAsi.add(data);
                  } else {
                    await _formulirAsi.doc(docId).update(data);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulir ASI"),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
              onPressed: _showFilterDialog, icon: const Icon(Icons.filter_alt)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tambahAtauEditData(),
        label: const Text("Tambah Data"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _formulirAsi
            .where("bulan", isEqualTo: _selectedMonth)
            .where("tahun", isEqualTo: _selectedYear)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text("Belum ada data bulan ini"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final asiStatus = List<bool>.from(data['asiStatus'] ?? []);
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(data['namaAnak'] ?? "-"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tanggal Lahir: ${data['tanggalLahir'] ?? '-'}"),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: List.generate(asiStatus.length, (i) {
                          final symbol = asiStatus[i] ? '✓' : 'X';
                          return Chip(label: Text("Bulan $i: $symbol"));
                        }),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _tambahAtauEditData(
                          docId: docs[index].id,
                          namaAnak: data['namaAnak'],
                          tanggalLahir: data['tanggalLahir'],
                          asiBulan: List<bool>.from(data['asiStatus'] ?? []),
                        );
                      } else if (value == 'hapus') {
                        _hapusData(docs[index].id);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text("Edit")),
                      const PopupMenuItem(value: 'hapus', child: Text("Hapus")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
