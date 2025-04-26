import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormulirAsiPage extends StatefulWidget {
  const FormulirAsiPage({super.key});

  @override
  State<FormulirAsiPage> createState() => _FormulirAsiPageState();
}

class _FormulirAsiPageState extends State<FormulirAsiPage> {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection("formulir_asi");

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final List<int> _tahunList = [2023, 2024, 2025, 2026];

  Future<void> _showFilterDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        int tempMonth = _selectedMonth;
        int tempYear = _selectedYear;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Filter Bulan & Tahun"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: tempMonth,
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
                onChanged: (value) => tempMonth = value!,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: tempYear,
                decoration: const InputDecoration(
                  labelText: "Tahun",
                  border: OutlineInputBorder(),
                ),
                items: _tahunList.map((year) {
                  return DropdownMenuItem(value: year, child: Text("$year"));
                }).toList(),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
        );
      },
    );
  }

  Future<void> _hapusData(String docId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Data"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _collection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil dihapus.")),
      );
    }
  }

  void _tambahAtauEditData({
    String? docId,
    String? provinsi,
    String? kabupaten,
    String? puskesmas,
    String? desa,
    String? posyandu,
    int? bulan,
    int? tahun,
    String? namaAnak,
    String? tanggalLahir,
    int? umurBayi,
  }) {
    final TextEditingController provinsiController =
        TextEditingController(text: provinsi);
    final TextEditingController kabupatenController =
        TextEditingController(text: kabupaten);
    final TextEditingController puskesmasController =
        TextEditingController(text: puskesmas);
    final TextEditingController desaController =
        TextEditingController(text: desa);
    final TextEditingController posyanduController =
        TextEditingController(text: posyandu);
    final TextEditingController namaAnakController =
        TextEditingController(text: namaAnak);
    final TextEditingController tanggalLahirController =
        TextEditingController(text: tanggalLahir);
    final TextEditingController umurBayiController = TextEditingController(
        text: umurBayi != null ? umurBayi.toString() : "");
    int selectedBulan = bulan ?? _selectedMonth;
    int selectedTahun = tahun ?? _selectedYear;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(docId == null ? "Tambah Data ASI" : "Edit Data ASI"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildInputField(provinsiController, "Provinsi"),
                _buildInputField(kabupatenController, "Kabupaten"),
                _buildInputField(puskesmasController, "Puskesmas"),
                _buildInputField(desaController, "Desa/Kelurahan"),
                _buildInputField(posyanduController, "Nama Posyandu"),
                DropdownButtonFormField<int>(
                  value: selectedBulan,
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
                  onChanged: (val) =>
                      setStateDialog(() => selectedBulan = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedTahun,
                  decoration: const InputDecoration(
                    labelText: "Tahun",
                    border: OutlineInputBorder(),
                  ),
                  items: _tahunList.map((year) {
                    return DropdownMenuItem(value: year, child: Text("$year"));
                  }).toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedTahun = val!),
                ),
                _buildInputField(namaAnakController, "Nama Anak"),
                TextField(
                  controller: tanggalLahirController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Tanggal Lahir",
                    border: OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: tanggalLahir != null
                          ? DateFormat('dd-MM-yyyy').parse(tanggalLahir)
                          : DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      tanggalLahirController.text =
                          DateFormat('dd-MM-yyyy').format(pickedDate);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  umurBayiController,
                  "Umur Bayi (bulan)",
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              onPressed: () async {
                final data = {
                  "provinsi": provinsiController.text,
                  "kabupaten": kabupatenController.text,
                  "puskesmas": puskesmasController.text,
                  "desa": desaController.text,
                  "posyandu": posyanduController.text,
                  "bulan": selectedBulan,
                  "tahun": selectedTahun,
                  "namaAnak": namaAnakController.text,
                  "tanggalLahir": tanggalLahirController.text,
                  "umurBayi": int.tryParse(umurBayiController.text) ?? 0,
                };

                if (docId == null) {
                  await _collection.add(data);
                } else {
                  await _collection.doc(docId).update(data);
                }
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Formulir ASI"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_alt_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tambahAtauEditData(),
        label: const Text("Tambah Data"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _collection
            .where("bulan", isEqualTo: _selectedMonth)
            .where("tahun", isEqualTo: _selectedYear)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada data bulan ini 🍼"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.pinkAccent,
                    child: Text(
                      data['namaAnak']?.substring(0, 1).toUpperCase() ?? "-",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    data['namaAnak'] ?? "-",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${data['desa'] ?? '-'}, ${data['posyandu'] ?? '-'}"),
                        const SizedBox(height: 4),
                        Text("Umur Bayi: ${data['umurBayi'] ?? '-'} bulan"),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _tambahAtauEditData(
                          docId: docs[index].id,
                          provinsi: data['provinsi'],
                          kabupaten: data['kabupaten'],
                          puskesmas: data['puskesmas'],
                          desa: data['desa'],
                          posyandu: data['posyandu'],
                          bulan: data['bulan'],
                          tahun: data['tahun'],
                          namaAnak: data['namaAnak'],
                          tanggalLahir: data['tanggalLahir'],
                          umurBayi: data['umurBayi'],
                        );
                      } else if (value == 'hapus') {
                        _hapusData(docs[index].id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'hapus', child: Text('Hapus')),
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
