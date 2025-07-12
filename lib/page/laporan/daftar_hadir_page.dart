import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

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

  final List<String> _bulanNama = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember"
  ];

  Future<void> _showFilterDialog() async {
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.filter_alt, color: Colors.pink.shade600),
                const SizedBox(width: 8),
                const Text("Filter Data",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: tempMonth,
                      decoration: const InputDecoration(
                        labelText: "Bulan",
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(_bulanNama[index]),
                        );
                      }),
                      onChanged: (value) =>
                          setDialogState(() => tempMonth = value!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: tempYear,
                      decoration: const InputDecoration(
                        labelText: "Tahun",
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: _tahunList
                          .map((year) => DropdownMenuItem(
                              value: year, child: Text("$year")))
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => tempYear = value!),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal",
                    style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  setState(() {
                    _selectedMonth = tempMonth;
                    _selectedYear = tempYear;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Terapkan",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportToPDF() async {
    try {
      // Ambil data dari Firestore
      final querySnapshot = await _collection
          .where("bulan", isEqualTo: _selectedMonth)
          .where("tahun", isEqualTo: _selectedYear)
          .orderBy("created_at", descending: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak ada data untuk di-export")),
        );
        return;
      }

      // Buat dokumen PDF
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'DAFTAR HADIR POSYANDU',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Bulan ${_bulanNama[_selectedMonth - 1]} $_selectedYear',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Tanggal Export: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Tabel
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1),
                  5: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header tabel
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('No',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Nama Balita',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Nama Ortu',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Umur',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('ASI Eksklusif',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('KB Ortu',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),

                  // Data rows
                  ...querySnapshot.docs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value.data() as Map<String, dynamic>;

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${index + 1}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(data["nama_balita"] ?? '-'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(data["nama_ortu"] ?? '-'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(data["umur_kategori"] ?? '-'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              data["asi_eksklusif"] == true ? 'Ya' : 'Tidak'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(data["kb_ortu"] ?? '-'),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              // Footer
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Total Peserta: ${querySnapshot.docs.length} orang',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Keterangan:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                        '• ASI Eksklusif: pemberian ASI saja tanpa makanan/minuman lain'),
                    pw.Text('• KB: Keluarga Berencana'),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Tampilkan preview PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'Daftar_Hadir_Posyandu_${_bulanNama[_selectedMonth - 1]}_$_selectedYear.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saat export PDF: $e")),
      );
    }
  }

  Future<void> _hapusData(String docId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text("Hapus Data"),
          ],
        ),
        content: const Text(
            "Apakah Anda yakin ingin menghapus data ini? Data yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _collection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Data berhasil dihapus"),
          backgroundColor: Colors.green.shade600,
        ),
      );
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(
                docId == null ? Icons.add_circle : Icons.edit,
                color: Colors.pink.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                docId == null ? "Tambah Kehadiran" : "Edit Kehadiran",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Column(
                children: [
                  _buildInputField(
                    controller: namaOrtuController,
                    label: "Nama Orang Tua",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: namaBalitaController,
                    label: "Nama Balita",
                    icon: Icons.child_care,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    value: selectedUmur,
                    label: "Umur Balita",
                    icon: Icons.cake,
                    items: _umurKategori,
                    onChanged: (val) =>
                        setDialogState(() => selectedUmur = val),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: CheckboxListTile(
                      value: asi,
                      onChanged: (val) => setDialogState(() => asi = val!),
                      title: const Text("ASI Eksklusif 0-6 bulan"),
                      subtitle: const Text(
                          "Centang jika balita mendapat ASI eksklusif"),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    value: selectedKB,
                    label: "Metode KB Orang Tua",
                    icon: Icons.family_restroom,
                    items: _metodeKB,
                    onChanged: (val) => setDialogState(() => selectedKB = val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          value: selectedBulan,
                          label: "Bulan",
                          icon: Icons.calendar_month,
                          items:
                              List.generate(12, (index) => _bulanNama[index]),
                          values: List.generate(12, (index) => index + 1),
                          onChanged: (val) =>
                              setDialogState(() => selectedBulan = val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          value: selectedTahun,
                          label: "Tahun",
                          icon: Icons.calendar_today,
                          items: _tahunList.map((e) => e.toString()).toList(),
                          values: _tahunList,
                          onChanged: (val) =>
                              setDialogState(() => selectedTahun = val),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text("Batal", style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (namaOrtuController.text.isEmpty ||
                    namaBalitaController.text.isEmpty ||
                    selectedUmur == null ||
                    selectedKB == null ||
                    selectedBulan == null ||
                    selectedTahun == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mohon lengkapi semua data")),
                  );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(docId == null
                        ? "Data berhasil ditambahkan"
                        : "Data berhasil diupdate"),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
              },
              child:
                  const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.pink.shade600),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<String> items,
    List<T>? values,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.pink.shade600),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        items: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final val = values != null ? values[index] : item as T;
          return DropdownMenuItem<T>(value: val, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Daftar Hadir Posyandu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink.shade600,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            tooltip: "Filter Data",
          ),
          IconButton(
            onPressed: _exportToPDF,
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: "Export ke PDF",
          ),
          IconButton(
            onPressed: () => _tambahAtauEditData(),
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: "Tambah Data",
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink.shade600,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Periode: ${_bulanNama[_selectedMonth - 1]} $_selectedYear",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: _collection
                      .where("bulan", isEqualTo: _selectedMonth)
                      .where("tahun", isEqualTo: _selectedYear)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count =
                        snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Text(
                      "Total Peserta: $count orang",
                      style: TextStyle(
                        color: Colors.pink.shade100,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Data List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada data kehadiran",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap + untuk menambah data baru",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.pink.shade50,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.pink.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.child_care,
                                      color: Colors.pink.shade600,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data["nama_balita"] ?? "-",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          "Ortu: ${data["nama_ortu"] ?? "-"}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton(
                                    icon: Icon(Icons.more_vert,
                                        color: Colors.grey.shade600),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: const Row(
                                          children: [
                                            Icon(Icons.edit,
                                                color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: const Row(
                                          children: [
                                            Icon(Icons.delete,
                                                color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Hapus'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _tambahAtauEditData(
                                          docId: doc.id,
                                          namaOrtu: data["nama_ortu"],
                                          namaBalita: data["nama_balita"],
                                          umur: data["umur_kategori"],
                                          asiEksklusif:
                                              data["asi_eksklusif"] ?? false,
                                          kb: data["kb_ortu"],
                                          bulan: data["bulan"],
                                          tahun: data["tahun"],
                                        );
                                      } else if (value == 'delete') {
                                        _hapusData(doc.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildInfoChip(
                                    icon: Icons.cake,
                                    label: data["umur_kategori"] ?? "-",
                                    color: Colors.orange.shade600,
                                  ),
                                  _buildInfoChip(
                                    icon: Icons.health_and_safety,
                                    label: data["asi_eksklusif"] == true
                                        ? "ASI Eksklusif"
                                        : "Non ASI Eksklusif",
                                    color: data["asi_eksklusif"] == true
                                        ? Colors.green.shade600
                                        : Colors.red.shade600,
                                  ),
                                  _buildInfoChip(
                                    icon: Icons.family_restroom,
                                    label: "KB: ${data["kb_ortu"] ?? "-"}",
                                    color: Colors.blue.shade600,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 16,
                                            color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Ditambahkan",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      data["created_at"] != null
                                          ? DateFormat('dd/MM/yyyy HH:mm')
                                              .format((data["created_at"]
                                                      as Timestamp)
                                                  .toDate())
                                          : "-",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tambahAtauEditData(),
        backgroundColor: Colors.pink.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
