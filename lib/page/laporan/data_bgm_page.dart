import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart'; // Import for PDF generation
import 'package:pdf/widgets.dart' as pw; // Alias for PDF widgets
import 'package:printing/printing.dart'; // Import for printing/previewing PDF

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

  List<Map<String, dynamic>> _balitaList = [];

  @override
  void initState() {
    super.initState();
    _fetchBalitaList();
  }

  Future<void> _fetchBalitaList() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('balita').get();

      final list = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'nama': doc['nama'],
                'tanggal_lahir': doc['tanggal_lahir'],
              })
          .toList();

      list.sort((a, b) => (a['nama'] as String).compareTo(b['nama'] as String));

      setState(() {
        _balitaList = list;
      });
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal mengambil data balita: ${e.message}"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Terjadi kesalahan: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showFilterDialog() async {
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              items: List.generate(
                  12,
                  (index) => DropdownMenuItem(
                      value: index + 1, child: Text(_namaBulan[index]))),
              onChanged: (val) {
                if (val != null) {
                  tempMonth = val;
                }
              },
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
              items: _tahunOptions
                  .map((year) =>
                      DropdownMenuItem(value: year, child: Text("$year")))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  tempYear = val;
                }
              },
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
    // Declaring controllers inside StatefulBuilder to make them reactive
    // and correctly updated by setDialogState.
    // Initializing them outside for clarity.
    String tempTanggalLahir = tanggalLahir ?? "";
    String tempUsia = usia ?? "";

    String? selectedNamaAnak = namaAnak;
    String? selectedKeterangan = keterangan;
    int? selectedBulan = bulan ?? _selectedMonth;
    int? selectedTahun = tahun ?? _selectedYear;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final TextEditingController tanggalLahirController =
              TextEditingController(text: tempTanggalLahir);
          final TextEditingController usiaController =
              TextEditingController(text: tempUsia);
          final TextEditingController bbController = TextEditingController(
              text: beratBadan != null ? beratBadan.toString() : "");
          final TextEditingController tbController = TextEditingController(
              text: tinggiBadan != null
                  ? tinggiBadan.toString()
                  : ""); // Corrected typo here

          // Set selection to end of text
          tanggalLahirController.selection = TextSelection.fromPosition(
              TextPosition(offset: tanggalLahirController.text.length));
          usiaController.selection = TextSelection.fromPosition(
              TextPosition(offset: usiaController.text.length));
          bbController.selection = TextSelection.fromPosition(
              TextPosition(offset: bbController.text.length));
          tbController.selection = TextSelection.fromPosition(
              TextPosition(offset: tbController.text.length));

          return AlertDialog(
            backgroundColor: const Color(0xFFFFF0F5),
            title: Text(
              docId == null ? "Tambah Data BGM" : "Edit Data BGM",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedNamaAnak,
                    decoration: InputDecoration(
                      labelText: "Nama Anak",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.child_care),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _balitaList
                        .map((balita) => DropdownMenuItem(
                              value: balita['nama'] as String,
                              child: Text(balita['nama'] as String),
                              onTap: () {
                                final tglLahirRaw = balita['tanggal_lahir'];
                                DateTime tglLahir;
                                if (tglLahirRaw is Timestamp) {
                                  tglLahir = tglLahirRaw.toDate();
                                } else if (tglLahirRaw is String) {
                                  try {
                                    tglLahir = DateFormat('yyyy-MM-dd')
                                        .parse(tglLahirRaw);
                                  } catch (e) {
                                    // Fallback to a default or error handling
                                    tglLahir = DateTime.now();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Gagal memparsing tanggal lahir: $e"),
                                            backgroundColor: Colors.orange),
                                      );
                                    }
                                  }
                                } else {
                                  tglLahir = DateTime.now(); // Fallback
                                }

                                final now = DateTime.now();
                                int years = now.year - tglLahir.year;
                                int months = now.month - tglLahir.month;
                                int days = now.day - tglLahir.day;

                                if (days < 0) {
                                  months--;
                                  days += DateTime(now.year, now.month, 0).day;
                                }
                                if (months < 0) {
                                  years--;
                                  months += 12;
                                }

                                String ageText = '';
                                if (years > 0) {
                                  ageText += '$years tahun ';
                                }
                                if (months > 0) {
                                  ageText += '$months bulan';
                                } else if (years == 0 && months == 0) {
                                  ageText = '$days hari';
                                }

                                setDialogState(() {
                                  tempTanggalLahir =
                                      DateFormat('dd-MM-yyyy').format(tglLahir);
                                  tempUsia = ageText.trim();
                                  tanggalLahirController.text =
                                      tempTanggalLahir; // Update controller text
                                  usiaController.text =
                                      tempUsia; // Update controller text
                                });
                              },
                            ))
                        .toList(),
                    onChanged: (val) => setDialogState(() {
                      selectedNamaAnak = val;
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tanggalLahirController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Tanggal Lahir",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.cake),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usiaController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Usia",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.baby_changing_station),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bbController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Berat Badan (kg)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.monitor_weight),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tbController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Tinggi Badan (cm)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.height),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedKeterangan,
                    decoration: InputDecoration(
                      labelText: "Keterangan",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.info_outline),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _keteranganOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedKeterangan = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedBulan,
                    decoration: InputDecoration(
                      labelText: "Bulan",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.calendar_month),
                    ),
                    items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                            value: index + 1, child: Text(_namaBulan[index]))),
                    onChanged: (val) =>
                        setDialogState(() => selectedBulan = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedTahun,
                    decoration: InputDecoration(
                      labelText: "Tahun",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _tahunOptions
                        .map((year) =>
                            DropdownMenuItem(value: year, child: Text("$year")))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedTahun = val),
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
                  if (selectedNamaAnak == null ||
                      tanggalLahirController.text.isEmpty ||
                      usiaController.text.isEmpty ||
                      bbController.text.isEmpty ||
                      tbController.text.isEmpty ||
                      selectedKeterangan == null ||
                      selectedBulan == null ||
                      selectedTahun == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Mohon lengkapi semua data!"),
                          backgroundColor: Colors.red));
                    }
                    return;
                  }

                  final data = {
                    "nama_anak": selectedNamaAnak,
                    "tanggal_lahir": tanggalLahirController.text,
                    "usia": usiaController.text,
                    "berat_badan": double.tryParse(bbController.text),
                    "tinggi_badan": double.tryParse(tbController.text),
                    "keterangan": selectedKeterangan,
                    "bulan": selectedBulan,
                    "tahun": selectedTahun,
                    "created_at": FieldValue.serverTimestamp(),
                  };

                  try {
                    if (docId == null) {
                      await _collection.add(data);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Data berhasil ditambahkan."),
                                backgroundColor: Colors.green));
                      }
                    } else {
                      await _collection.doc(docId).update(data);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Data berhasil diperbarui."),
                                backgroundColor: Colors.green));
                      }
                    }
                    if (mounted) Navigator.pop(context);
                  } on FirebaseException catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Gagal menyimpan data: ${e.message}"),
                            backgroundColor: Colors.red),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Terjadi kesalahan: $e"),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Simpan"),
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _hapusData(String docId) async {
    bool? confirm = await showDialog(
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
              child: const Text("Batal")),
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
      try {
        await _collection.doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Data berhasil dihapus."),
                backgroundColor: Colors.green),
          );
        }
      } on FirebaseException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Gagal menghapus data: ${e.message}"),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Terjadi kesalahan: $e"),
                backgroundColor: Colors.red),
          );
        }
      }
    }
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
      final QuerySnapshot snapshot = await _collection
          .where("bulan", isEqualTo: _selectedMonth)
          .where("tahun", isEqualTo: _selectedYear)
          .orderBy("nama_anak", descending: false)
          .get();

      // Create PDF document
      final pdf = pw.Document();

      // Table headers for BGM data
      final headers = [
        'No',
        'Nama Anak',
        'Tanggal Lahir',
        'Usia',
        'BB (kg)',
        'TB (cm)',
        'Keterangan',
        'Periode',
      ];

      // Prepare data for the table
      final List<List<String>> data = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final docData = snapshot.docs[i].data() as Map<String, dynamic>;

        final List<String> row = [
          (i + 1).toString(),
          docData['nama_anak'] ?? '-',
          docData['tanggal_lahir'] ?? '-',
          docData['usia'] ?? '-',
          (docData['berat_badan']?.toStringAsFixed(1) ?? '-') +
              ' kg', // Format BB
          (docData['tinggi_badan']?.toStringAsFixed(1) ?? '-') +
              ' cm', // Format TB
          docData['keterangan'] ?? '-',
          '${_namaBulan[_selectedMonth - 1]} $_selectedYear',
        ];
        data.add(row);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat:
              PdfPageFormat.a4.landscape, // Use landscape for wider table
          build: (pw.Context context) {
            return [
              pw.Center(
                child: pw.Text(
                  'Data Anak BGM / R / 2T (${_namaBulan[_selectedMonth - 1]} $_selectedYear)',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
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
                cellStyle: const pw.TextStyle(
                    fontSize: 9), // Smaller font for more data
                columnWidths: {
                  0: const pw.FixedColumnWidth(20), // No
                  1: const pw.FixedColumnWidth(100), // Nama Anak
                  2: const pw.FixedColumnWidth(70), // Tanggal Lahir
                  3: const pw.FixedColumnWidth(60), // Usia
                  4: const pw.FixedColumnWidth(60), // BB
                  5: const pw.FixedColumnWidth(60), // TB
                  6: const pw.FixedColumnWidth(60), // Keterangan
                  7: const pw.FixedColumnWidth(70), // Periode
                },
              ),
            ];
          },
        ),
      );

      // Close loading indicator
      if (mounted) Navigator.pop(context);

      // Preview PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PDF berhasil dibuat dan ditampilkan"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if there's an error
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saat export PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text(
          "Data Anak BGM / R / 2T",
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
            tooltip: "Filter Data",
          ),
          IconButton(
            onPressed: _exportToPdf, // Tombol baru untuk ekspor PDF
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export ke PDF",
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
                  stream: _collection
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
              stream: _collection
                  .where("bulan", isEqualTo: _selectedMonth)
                  .where("tahun", isEqualTo: _selectedYear)
                  .orderBy("nama_anak",
                      descending: false) // Order by name for consistency
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Terjadi kesalahan: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                          "Belum ada data untuk periode ini.",
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
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
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
                          data["nama_anak"] ?? "-",
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
                                Text("Lahir: ${data["tanggal_lahir"] ?? "-"}"),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.timelapse,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("Usia: ${data["usia"] ?? "-"}"),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.scale,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                    "BB: ${data["berat_badan"]?.toStringAsFixed(1) ?? "-"} kg, TB: ${data["tinggi_badan"]?.toStringAsFixed(1) ?? "-"} cm"),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.assignment_turned_in,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                    "Keterangan: ${data["keterangan"] ?? "-"}"),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                    "Bulan: ${_namaBulan[(data["bulan"] ?? 1) - 1]}, Tahun: ${data["tahun"] ?? "-"}"),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _tambahAtauEditData(
                                docId: doc.id,
                                namaAnak: data["nama_anak"],
                                tanggalLahir: data["tanggal_lahir"],
                                usia: data["usia"],
                                beratBadan: data["berat_badan"],
                                tinggiBadan: data["tinggi_badan"],
                                keterangan: data["keterangan"],
                                bulan: data["bulan"],
                                tahun: data["tahun"],
                              );
                            } else if (value == 'hapus') {
                              _hapusData(doc.id);
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
