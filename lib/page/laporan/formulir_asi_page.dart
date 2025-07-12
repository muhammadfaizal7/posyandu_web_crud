import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  // List nama bulan dalam bahasa Indonesia
  final List<String> _namaBulan = [
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

  Future<void> _showFilterDialog() async {
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Filter Bulan & Tahun",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: tempMonth,
              decoration: InputDecoration(
                labelText: "Bulan",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.calendar_month),
              ),
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(_namaBulan[index]),
                );
              }),
              onChanged: (value) => tempMonth = value!,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: tempYear,
              decoration: InputDecoration(
                labelText: "Tahun",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text("Terapkan"),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch data from Firestore based on filter
      final QuerySnapshot snapshot = await _formulirAsi
          .where("bulan", isEqualTo: _selectedMonth)
          .where("tahun", isEqualTo: _selectedYear)
          .get();

      // Create PDF document
      final pdf = pw.Document();

      // Table headers
      final headers = [
        'No',
        'Nama Anak',
        'Tanggal Lahir',
        'Bulan 0',
        'Bulan 1',
        'Bulan 2',
        'Bulan 3',
        'Bulan 4',
        'Bulan 5',
        'Bulan 6',
        'Periode',
      ];

      // Prepare data for the table
      final List<List<String>> data = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final docData = snapshot.docs[i].data() as Map<String, dynamic>;
        final asiStatus = List<bool>.from(docData['asiStatus'] ?? []);

        final List<String> row = [
          (i + 1).toString(),
          docData['namaAnak'] ?? '-',
          docData['tanggalLahir'] ?? '-',
        ];

        // Status ASI per bulan
        for (int j = 0; j < 7; j++) {
          final status =
              j < asiStatus.length ? (asiStatus[j] ? 'Ya' : 'Tidak') : 'Tidak';
          row.add(status);
        }
        row.add('${_namaBulan[_selectedMonth - 1]} $_selectedYear');
        data.add(row);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat:
              PdfPageFormat.a4.landscape, // Use landscape for more columns
          build: (pw.Context context) {
            return [
              pw.Center(
                child: pw.Text(
                  'Formulir ASI (${_namaBulan[_selectedMonth - 1]} $_selectedYear)',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: headers,
                data: data,
                border: pw.TableBorder.all(color: PdfColors.black),
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.pink400),
                cellAlignment: pw.Alignment.center,
                cellStyle: const pw.TextStyle(fontSize: 10),
                columnWidths: {
                  0: const pw.FixedColumnWidth(20), // No
                  1: const pw.FixedColumnWidth(100), // Nama Anak
                  2: const pw.FixedColumnWidth(70), // Tanggal Lahir
                  3: const pw.FixedColumnWidth(40), // Bulan 0
                  4: const pw.FixedColumnWidth(40), // Bulan 1
                  5: const pw.FixedColumnWidth(40), // Bulan 2
                  6: const pw.FixedColumnWidth(40), // Bulan 3
                  7: const pw.FixedColumnWidth(40), // Bulan 4
                  8: const pw.FixedColumnWidth(40), // Bulan 5
                  9: const pw.FixedColumnWidth(40), // Bulan 6
                  10: const pw.FixedColumnWidth(70), // Periode
                },
              ),
            ];
          },
        ),
      );

      // Close loading indicator
      Navigator.pop(context);

      // Preview PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PDF berhasil dibuat dan ditampilkan"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading indicator if there's an error
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saat export PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _hapusData(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Hapus Data",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _formulirAsi.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
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
            title: Text(
              docId == null ? "Tambah Data ASI" : "Edit Data ASI",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _dataBalita.orderBy('nama').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final docs = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: selectedNama,
                        decoration: InputDecoration(
                          labelText: "Nama Anak",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.child_care),
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cake, color: Colors.pink),
                        const SizedBox(width: 8),
                        const Text("Tanggal Lahir: "),
                        Text(
                          selectedTanggal.isEmpty
                              ? "Pilih nama anak"
                              : selectedTanggal,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedTanggal.isEmpty
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Status ASI per Bulan (0–6)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: List.generate(7, (i) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: asiStatus[i]
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Bulan $i",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Text(
                                asiStatus[i] ? "Ya" : "Tidak",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      asiStatus[i] ? Colors.green : Colors.red,
                                ),
                              ),
                              Switch(
                                value: asiStatus[i],
                                onChanged: (val) {
                                  setStateDialog(() => asiStatus[i] = val);
                                },
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
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
                onPressed: () async {
                  if (selectedNama == null || selectedTanggal.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Nama anak dan tanggal lahir wajib diisi"),
                        backgroundColor: Colors.red,
                      ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Data berhasil ditambahkan"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    await _formulirAsi.doc(docId).update(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Data berhasil diperbarui"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
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
        title: const Text(
          "Formulir ASI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_alt),
            tooltip: "Filter",
          ),
          IconButton(
            onPressed: _exportToPdf, // Changed to export to PDF
            icon: const Icon(Icons.picture_as_pdf), // Changed icon
            tooltip: "Export ke PDF", // Changed tooltip
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink, Colors.pink.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Periode: ${_namaBulan[_selectedMonth - 1]} $_selectedYear",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                StreamBuilder<QuerySnapshot>(
                  stream: _formulirAsi
                      .where("bulan", isEqualTo: _selectedMonth)
                      .where("tahun", isEqualTo: _selectedYear)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count =
                        snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Text(
                      "Total Data: $count",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // List data
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _formulirAsi
                  .where("bulan", isEqualTo: _selectedMonth)
                  .where("tahun", isEqualTo: _selectedYear)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada data untuk bulan ini",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final asiStatus = List<bool>.from(data['asiStatus'] ?? []);
                    final asiCount = asiStatus.where((status) => status).length;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.pink.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.pink,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          data['namaAnak'] ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.cake,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "Lahir: ${data['tanggalLahir'] ?? '-'}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.baby_changing_station,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "ASI: $asiCount dari 7 bulan",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: List.generate(asiStatus.length, (i) {
                                final isAsi = asiStatus[i];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAsi ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$i",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
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
                                asiBulan:
                                    List<bool>.from(data['asiStatus'] ?? []),
                              );
                            } else if (value == 'hapus') {
                              _hapusData(docs[index].id);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text("Edit"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'hapus',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text("Hapus"),
                                ],
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tambahAtauEditData(),
        label: const Text("Tambah Data"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
    );
  }
}
