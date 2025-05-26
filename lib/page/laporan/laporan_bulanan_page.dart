import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanBulananPage extends StatefulWidget {
  const LaporanBulananPage({super.key});

  @override
  State<LaporanBulananPage> createState() => _LaporanBulananPageState();
}

class _LaporanBulananPageState extends State<LaporanBulananPage> {
  final _formKey = GlobalKey<FormState>();

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final _tahunList = [2023, 2024, 2025, 2026];

  final _tanggalPenimbanganController = TextEditingController();
  final _tanggalPelaporanController = TextEditingController();

  final List<String> pertanyaanList = [
    '1. Jumlah semua balita yang ada dalam kelompok penimbangan bulan ini (S)',
    '2. Jumlah balita yang terdaftar dan mempunyai KMS bulan ini (K)',
    '3. Jumlah balita yang naik berat badannya bulan ini (N)',
    '4. Jumlah balita yang tidak naik berat badannya bulan ini (T)',
    '5. Jumlah balita yang ditimbang bulan ini tapi tidak di timbang bulan lalu (O)',
    '6. Jumlah balita yang pertama kali di timbang bulan ini (B)',
    '7. Jumlah semua balita yang ditimbang bulan ini (3+4+5+6) (D)',
    '8. Jumlah balita yang tidak hadir di kelompok penimbangan pada bulan ini (1-7) (-)',
    '9. Jumlah balita yang berat badannya berada di bawah garis merah bulan ini (BGM)',
    '10. Jumlah balita yang berat badannya berada di bawah garis titik-titik dan di atas garis merah bulan ini (R)',
    '11. Jumlah balita yang 2 kali tidak naik berat badannya bulan ini (2T)',
    '12. Jumlah balita yang mendapat vitamin A bulan ini (A)',
    '13. Jumlah balita yang ditimbang bulan ini mencapai umur 36 bulan (S.36)',
    '14. Jumlah balita yang mencapai umur 36 bulan pada bulan ini dengan berat badan 11,5 kg atau lebih (L)',
  ];

  final pertanyaanControllers = List.generate(
    14,
    (_) => List.generate(6, (_) => TextEditingController()),
  );

  final bahanList = ['KMS Baru', 'Oralit', 'Vitamin A', 'Tablet FE'];
  final kategoriList = [
    'Sisa Bulan Lalu',
    'Diterima Bulan Ini',
    'Diberikan Bulan Ini',
    'Sisa Akhir Bulan Ini'
  ];

  final persediaanControllers = List.generate(
    4,
    (_) => List.generate(4, (_) => TextEditingController()),
  );

  String? _editingDocId;

  @override
  void dispose() {
    _tanggalPenimbanganController.dispose();
    _tanggalPelaporanController.dispose();
    for (var row in pertanyaanControllers) {
      for (var ctrl in row) {
        ctrl.dispose();
      }
    }
    for (var row in persediaanControllers) {
      for (var ctrl in row) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  void _resetForm() {
    _editingDocId = null;
    _tanggalPelaporanController.clear();
    _tanggalPenimbanganController.clear();
    for (var row in pertanyaanControllers) {
      for (var ctrl in row) {
        ctrl.clear();
      }
    }
    for (var row in persediaanControllers) {
      for (var ctrl in row) {
        ctrl.clear();
      }
    }
  }

  void _loadDataForEdit(Map<String, dynamic> data, String docId) {
    try {
      _editingDocId = docId;
      _tanggalPelaporanController.text = data['tanggalPelaporan'] ?? '';
      _tanggalPenimbanganController.text = data['tanggalPenimbangan'] ?? '';

      final List kegiatanList = data['kegiatanPenimbangan'] ?? [];
      for (int i = 0; i < kegiatanList.length; i++) {
        final row = kegiatanList[i]['nilai'] as List<dynamic>;
        for (int j = 0; j < row.length; j++) {
          pertanyaanControllers[i][j].text = row[j].toString();
        }
      }

      final List persediaanList = data['persediaanBahan'] ?? [];
      for (int i = 0; i < persediaanList.length; i++) {
        final row = persediaanList[i]['stok'] as List<dynamic>;
        for (int j = 0; j < row.length; j++) {
          persediaanControllers[i][j].text = row[j].toString();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load data: $e')),
      );
    }
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final kegiatan = List.generate(pertanyaanControllers.length, (i) {
        return {
          'pertanyaan': pertanyaanList[i],
          'nilai': List.generate(
              6, (j) => int.tryParse(pertanyaanControllers[i][j].text) ?? 0),
        };
      });

      final persediaan = List.generate(persediaanControllers.length, (i) {
        return {
          'bahan': bahanList[i],
          'stok': List.generate(
              4, (j) => int.tryParse(persediaanControllers[i][j].text) ?? 0),
        };
      });

      final data = {
        'bulan': _selectedMonth,
        'tahun': _selectedYear,
        'tanggalPenimbangan': _tanggalPenimbanganController.text,
        'tanggalPelaporan': _tanggalPelaporanController.text,
        'kegiatanPenimbangan': kegiatan,
        'persediaanBahan': persediaan,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final coll = FirebaseFirestore.instance.collection('laporan_bulanan');

      if (_editingDocId != null) {
        await coll.doc(_editingDocId).update(data);
      } else {
        await coll.add(data);
      }

      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  Future<void> _hapusData(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('laporan_bulanan')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Bulanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(labelText: 'Bulan'),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('Bulan ${i + 1}'),
                        ),
                      ),
                      onChanged: (val) => setState(() => _selectedMonth = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(labelText: 'Tahun'),
                      items: _tahunList
                          .map((y) =>
                              DropdownMenuItem(value: y, child: Text('$y')))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedYear = val!),
                    ),
                  ),
                ],
              ),
              _buildTextField(
                  _tanggalPenimbanganController, 'Tanggal Penimbangan',
                  readOnly: true,
                  onTap: () => _pickDate(_tanggalPenimbanganController)),
              _buildTextField(_tanggalPelaporanController, 'Tanggal Pelaporan',
                  readOnly: true,
                  onTap: () => _pickDate(_tanggalPelaporanController)),
              const SizedBox(height: 16),
              const Text('II. Kegiatan Penimbangan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildPertanyaanSection(),
              const SizedBox(height: 16),
              const Text('III. Persediaan Bahan-Bahan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildPersediaanSection(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _simpanData,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    child: const Text('Simpan'),
                  ),
                  ElevatedButton(
                    onPressed: _resetForm,
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Data Tersimpan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('laporan_bulanan')
                    .where('bulan', isEqualTo: _selectedMonth)
                    .where('tahun', isEqualTo: _selectedYear)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(
                              "Pelaporan: ${data['tanggalPelaporan'] ?? '-'}"),
                          subtitle: Text(
                              "Penimbangan: ${data['tanggalPenimbangan'] ?? '-'}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _loadDataForEdit(data, docs[i].id);
                                  Scrollable.ensureVisible(
                                      _formKey.currentContext!);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _hapusData(docs[i].id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Wajib diisi' : null,
      ),
    );
  }

  Widget _buildPertanyaanSection() {
    final labels = [
      'Bayi L',
      'Bayi P',
      'Baduta L',
      'Baduta P',
      'Balita L',
      'Balita P'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(pertanyaanList.length, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pertanyaanList[index],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(6, (col) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: TextFormField(
                      controller: pertanyaanControllers[index][col],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: labels[col],
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
          ],
        );
      }),
    );
  }

  Widget _buildPersediaanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(bahanList.length, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bahanList[index],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(4, (col) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: TextFormField(
                      controller: persediaanControllers[index][col],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: kategoriList[col],
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
          ],
        );
      }),
    );
  }
}
