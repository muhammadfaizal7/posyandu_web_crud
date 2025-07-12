import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

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
  bool _isLoading = false;

  // Theme Colors untuk Posyandu Anggrek Merah
  static const Color primaryColor = Color(0xFFE91E63); // Pink/Merah Anggrek
  static const Color secondaryColor =
      Color(0xFF4CAF50); // Hijau untuk kesehatan
  static const Color accentColor = Color(0xFFFF9800); // Orange untuk aksen
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Color(0xFFFFFFFF);

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

  String _getNamaBulan(int month) {
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return bulan[month - 1];
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  void _resetForm() {
    setState(() {
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
    });
  }

  void _loadDataForEdit(Map<String, dynamic> data, String docId) {
    try {
      setState(() {
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
      });
    } catch (e) {
      _showSnackBar('Gagal memuat data: $e', isError: true);
    }
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

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
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final coll = FirebaseFirestore.instance.collection('laporan_bulanan');

      if (_editingDocId != null) {
        await coll.doc(_editingDocId).update(data);
        _showSnackBar('Data berhasil diperbarui');
      } else {
        await coll.add(data);
        _showSnackBar('Data berhasil disimpan');
      }

      _resetForm();
    } catch (e) {
      _showSnackBar('Gagal menyimpan data: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _hapusData(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('laporan_bulanan')
            .doc(docId)
            .delete();
        _showSnackBar('Data berhasil dihapus');
      } catch (e) {
        _showSnackBar('Gagal menghapus data: $e', isError: true);
      }
    }
  }

  Future<void> _generatePDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColors.pink100,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'POSYANDU ANGGREK MERAH',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.pink800,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'LAPORAN BULANAN',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Bulan: ${_getNamaBulan(data['bulan'])} ${data['tahun']}',
                  style: pw.TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Informasi Tanggal
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'I. INFORMASI TANGGAL',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.pink800,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                        'Tanggal Penimbangan: ${data['tanggalPenimbangan']}'),
                    pw.Text('Tanggal Pelaporan: ${data['tanggalPelaporan']}'),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Kegiatan Penimbangan
          pw.Text(
            'II. KEGIATAN PENIMBANGAN',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.pink800,
            ),
          ),
          pw.SizedBox(height: 10),

          ..._buildPDFTable(data['kegiatanPenimbangan']),

          pw.SizedBox(height: 20),

          // Persediaan Bahan
          pw.Text(
            'III. PERSEDIAAN BAHAN-BAHAN',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.pink800,
            ),
          ),
          pw.SizedBox(height: 10),

          ..._buildPDFPersediaanTable(data['persediaanBahan']),

          pw.SizedBox(height: 30),

          // Footer
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.pink50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Laporan ini dibuat secara otomatis oleh sistem Posyandu Anggrek Merah',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Tanggal Cetak: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name:
          'Laporan_Bulanan_${_getNamaBulan(data['bulan'])}_${data['tahun']}.pdf',
    );
  }

  List<pw.Widget> _buildPDFTable(List<dynamic> kegiatan) {
    const labels = [
      'Bayi L',
      'Bayi P',
      'Baduta L',
      'Baduta P',
      'Balita L',
      'Balita P'
    ];

    return kegiatan.map((item) {
      final pertanyaan = item['pertanyaan'] as String;
      final nilai = item['nilai'] as List<dynamic>;

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 15),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              pertanyaan,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                return pw.Container(
                  width: 70,
                  padding: const pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(labels[i], style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 2),
                      pw.Text(nilai[i].toString(),
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<pw.Widget> _buildPDFPersediaanTable(List<dynamic> persediaan) {
    return persediaan.map((item) {
      final bahan = item['bahan'] as String;
      final stok = item['stok'] as List<dynamic>;

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 15),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              bahan,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) {
                return pw.Container(
                  width: 100,
                  padding: const pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(kategoriList[i],
                          style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 2),
                      pw.Text(stok[i].toString(),
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : secondaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Laporan Bulanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan logo dan informasi posyandu
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'POSYANDU ANGGREK MERAH',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Melayani dengan Kasih Sayang',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Periode Laporan Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Text(
                                  'Periode Laporan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: DropdownButtonFormField<int>(
                                      value: _selectedMonth,
                                      decoration: const InputDecoration(
                                        labelText: 'Bulan',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                      ),
                                      items: List.generate(
                                        12,
                                        (i) => DropdownMenuItem(
                                          value: i + 1,
                                          child: Text(_getNamaBulan(i + 1)),
                                        ),
                                      ),
                                      onChanged: (val) =>
                                          setState(() => _selectedMonth = val!),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: DropdownButtonFormField<int>(
                                      value: _selectedYear,
                                      decoration: const InputDecoration(
                                        labelText: 'Tahun',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                      ),
                                      items: _tahunList
                                          .map((y) => DropdownMenuItem(
                                                value: y,
                                                child: Text('$y'),
                                              ))
                                          .toList(),
                                      onChanged: (val) =>
                                          setState(() => _selectedYear = val!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildStyledTextField(
                              _tanggalPenimbanganController,
                              'Tanggal Penimbangan',
                              Icons.scale,
                              readOnly: true,
                              onTap: () =>
                                  _pickDate(_tanggalPenimbanganController),
                            ),
                            const SizedBox(height: 16),
                            _buildStyledTextField(
                              _tanggalPelaporanController,
                              'Tanggal Pelaporan',
                              Icons.report,
                              readOnly: true,
                              onTap: () =>
                                  _pickDate(_tanggalPelaporanController),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Kegiatan Penimbangan Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: secondaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.monitor_weight,
                                    color: secondaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Text(
                                  'II. Kegiatan Penimbangan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildPertanyaanSection(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Persediaan Bahan Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.inventory,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Text(
                                  'III. Persediaan Bahan-Bahan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildPersediaanSection(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _simpanData,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _resetForm,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Data Tersimpan Section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.storage,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Text(
                                  'Data Tersimpan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('laporan_bulanan')
                                  .where('bulan', isEqualTo: _selectedMonth)
                                  .where('tahun', isEqualTo: _selectedYear)
                                  .orderBy('createdAt', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.red[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error,
                                            color: Colors.red[600]),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Error: ${snapshot.error}',
                                            style: TextStyle(
                                                color: Colors.red[600]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final docs = snapshot.data!.docs;

                                if (docs.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.inbox,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Belum ada data tersimpan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: docs.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    final data =
                                        docs[i].data() as Map<String, dynamic>;
                                    final isEditing =
                                        _editingDocId == docs[i].id;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: isEditing
                                            ? primaryColor.withOpacity(0.1)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isEditing
                                              ? primaryColor
                                              : Colors.grey[300]!,
                                          width: isEditing ? 2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        leading: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color:
                                                primaryColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Icon(
                                            isEditing
                                                ? Icons.edit
                                                : Icons.description,
                                            color: primaryColor,
                                          ),
                                        ),
                                        title: Text(
                                          "Laporan ${_getNamaBulan(data['bulan'])} ${data['tahun']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.scale,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Penimbangan: ${data['tanggalPenimbangan'] ?? '-'}",
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.report,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Pelaporan: ${data['tanggalPelaporan'] ?? '-'}",
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // PDF Button
                                            Container(
                                              decoration: BoxDecoration(
                                                color: accentColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.picture_as_pdf),
                                                color: accentColor,
                                                onPressed: () =>
                                                    _generatePDF(data),
                                                tooltip: 'Export PDF',
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Edit Button
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.edit),
                                                color: Colors.blue,
                                                onPressed: () {
                                                  _loadDataForEdit(
                                                      data, docs[i].id);
                                                  // Scroll to top of form
                                                  Scrollable.ensureVisible(
                                                    _formKey.currentContext!,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                  );
                                                },
                                                tooltip: 'Edit Data',
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Delete Button
                                            Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.red.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.delete),
                                                color: Colors.red,
                                                onPressed: () =>
                                                    _hapusData(docs[i].id),
                                                tooltip: 'Hapus Data',
                                              ),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Wajib diisi' : null,
      ),
    );
  }

  Widget _buildPertanyaanSection() {
    const labels = [
      'Bayi L',
      'Bayi P',
      'Baduta L',
      'Baduta P',
      'Balita L',
      'Balita P'
    ];

    const colors = [
      Colors.blue,
      Colors.pink,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(pertanyaanList.length, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pertanyaanList[index],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(6, (col) {
                  return Container(
                    width: (MediaQuery.of(context).size.width - 80) / 3 - 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors[col].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors[col].withOpacity(0.3)),
                      ),
                      child: TextFormField(
                        controller: pertanyaanControllers[index][col],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: labels[col],
                          labelStyle: TextStyle(
                            color: colors[col],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors[col],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPersediaanSection() {
    const colors = [
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
      Colors.red,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(bahanList.length, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors[index].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.medication,
                      size: 16,
                      color: colors[index],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    bahanList[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colors[index],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(4, (col) {
                  return Container(
                    width: (MediaQuery.of(context).size.width - 80) / 2 - 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors[index].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: colors[index].withOpacity(0.3)),
                      ),
                      child: TextFormField(
                        controller: persediaanControllers[index][col],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: kategoriList[col],
                          labelStyle: TextStyle(
                            color: colors[index],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors[index],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}
