import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanBulananPage extends StatefulWidget {
  const LaporanBulananPage({Key? key}) : super(key: key);

  @override
  State<LaporanBulananPage> createState() => _LaporanBulananPageState();
}

class _LaporanBulananPageState extends State<LaporanBulananPage> {
  final _formKey = GlobalKey<FormState>();

  // UMUM
  final _namaKelompokController = TextEditingController();
  final _desaController = TextEditingController();
  final _petugasController = TextEditingController();
  final _jumlahPendudukController = TextEditingController();
  final _kaderAktifController = TextEditingController();
  final _keteranganController = TextEditingController();

  // BULAN / TAHUN
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final _tahunList = [2023, 2024, 2025, 2026];

  // II. KEGIATAN PENIMBANGAN (13 Baris x 6 Kolom: Bayi, Baduta, Balita [L/P])
  final List<String> kegiatanLabels = [
    '1. Jumlah semua balita ... (S)',
    '2. Balita terdaftar & punya KMS',
    '3. Balita naik BB bulan ini (N)',
    '4. Balita tidak naik BB bulan ini',
    '5. Ditimbang tapi bukan di pos ini',
    '6. Ditimbang pertama kali bulan ini',
    '7. Total ditimbang bulan ini (3+4+5+6)',
    '8. Tidak hadir bulan ini',
    '9. BGM bulan ini',
    '10. BB < garis merah & titik-titik',
    '11. Dpt vit A (biru)',
    '12. Dpt vit A 2x setahun',
    '13. 36 bln dpt vit A + Fe (L)',
  ];

  final List<List<TextEditingController>> kegiatanControllers = List.generate(
      13, (_) => List.generate(6, (_) => TextEditingController()));

  // III. PERSEDIAAN (4 baris x 5 kolom)
  final List<List<TextEditingController>> persediaanControllers =
      List.generate(4, (_) => List.generate(5, (_) => TextEditingController()));

  @override
  void dispose() {
    _namaKelompokController.dispose();
    _desaController.dispose();
    _petugasController.dispose();
    _jumlahPendudukController.dispose();
    _kaderAktifController.dispose();
    _keteranganController.dispose();
    for (var row in kegiatanControllers) {
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

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    final kegiatanData = kegiatanControllers.map((row) {
      return row.map((ctrl) => ctrl.text).toList();
    }).toList();

    final persediaanData = persediaanControllers.map((row) {
      return row.map((ctrl) => ctrl.text).toList();
    }).toList();

    final data = {
      'namaKelompok': _namaKelompokController.text,
      'desa': _desaController.text,
      'petugas': _petugasController.text,
      'jumlahPenduduk': _jumlahPendudukController.text,
      'kaderAktif': _kaderAktifController.text,
      'keterangan': _keteranganController.text,
      'bulan': _selectedMonth,
      'tahun': _selectedYear,
      'kegiatanPenimbangan': kegiatanData,
      'persediaanBahan': persediaanData,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('laporan_bulanan').add(data);
      final pdf = await _generatePDF(kegiatanData, persediaanData);
      await Printing.layoutPdf(onLayout: (format) => pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan data")),
      );
    }
  }

  Future<pw.Document> _generatePDF(List<List<String>> kegiatanData,
      List<List<String>> persediaanData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'LAPORAN BULANAN KELOMPOK PENIMBANG',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('TGL PENIMBANGAN BULAN INI: ........10..........'),
          pw.SizedBox(height: 16),
          pw.Text('I. UMUM',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Bullet(text: 'a. Nama kelompok: ${_namaKelompokController.text}'),
          pw.Bullet(text: 'b. Desa/Kelurahan: ${_desaController.text}'),
          pw.Bullet(text: 'c. Petugas: ${_petugasController.text}'),
          pw.Bullet(
              text: 'd. Jumlah Penduduk: ${_jumlahPendudukController.text}'),
          pw.Bullet(text: 'e. Kader Aktif:\n   ${_kaderAktifController.text}'),
          pw.SizedBox(height: 16),
          pw.Text('II. KEGIATAN PENIMBANGAN',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: [
              'No',
              'Bayi L',
              'Bayi P',
              'Baduta L',
              'Baduta P',
              'Balita L',
              'Balita P'
            ],
            data: List.generate(kegiatanLabels.length, (i) {
              return [kegiatanLabels[i], ...kegiatanData[i]];
            }),
          ),
          pw.SizedBox(height: 16),
          pw.Text('III. PERSEDIAAN BAHAN-BAHAN',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: [
              'No',
              'Bahan',
              'Sisa Awal',
              'Diterima',
              'Dikeluarkan',
              'Sisa Akhir'
            ],
            data: List.generate(persediaanData.length, (i) {
              return ['${i + 1}', ...persediaanData[i]];
            }),
          ),
          pw.SizedBox(height: 16),
          pw.Text('IV. KETERANGAN YANG PERLU DILAPORKAN',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(_keteranganController.text),
          pw.SizedBox(height: 32),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(children: [
                pw.Text('Ketua Kelompok'),
                pw.SizedBox(height: 40),
                pw.Text('________________'),
              ]),
              pw.Column(children: [
                pw.Text('Penimbang'),
                pw.SizedBox(height: 40),
                pw.Text('________________'),
              ])
            ],
          )
        ],
      ),
    );

    return pdf;
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
            children: [
              _buildTextField(_namaKelompokController, 'Nama Kelompok'),
              _buildTextField(_desaController, 'Desa/Kelurahan'),
              _buildTextField(_petugasController, 'Petugas Lapangan'),
              _buildTextField(_jumlahPendudukController, 'Jumlah Penduduk',
                  isNumber: true),
              _buildTextField(_kaderAktifController, 'Jumlah Kader Aktif'),
              _buildTextField(_keteranganController, 'Keterangan', maxLines: 3),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(labelText: 'Bulan'),
                      items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                              value: i + 1, child: Text('${i + 1}'))),
                      onChanged: (v) => setState(() => _selectedMonth = v!),
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
                      onChanged: (v) => setState(() => _selectedYear = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('II. Kegiatan Penimbangan'),
              ...List.generate(kegiatanLabels.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kegiatanLabels[index]),
                    Row(
                      children: List.generate(6, (col) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: TextFormField(
                              controller: kegiatanControllers[index][col],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: [
                                  'Bayi L',
                                  'Bayi P',
                                  'Baduta L',
                                  'Baduta P',
                                  'Balita L',
                                  'Balita P'
                                ][col],
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        );
                      }),
                    )
                  ],
                );
              }),
              const SizedBox(height: 16),
              _buildSectionTitle('III. Persediaan Bahan'),
              ...List.generate(4, (i) {
                return Row(
                  children: List.generate(5, (j) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: persediaanControllers[i][j],
                          decoration: InputDecoration(
                            labelText: [
                              'Bahan',
                              'Sisa Awal',
                              'Diterima',
                              'Dikeluarkan',
                              'Sisa Akhir'
                            ][j],
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpanData,
                child: const Text('Simpan & Cetak PDF'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Wajib diisi' : null,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
