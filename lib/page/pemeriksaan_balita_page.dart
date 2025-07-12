import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PemeriksaanBalitaPage extends StatefulWidget {
  const PemeriksaanBalitaPage({super.key});

  @override
  State<PemeriksaanBalitaPage> createState() => _PemeriksaanBalitaPageState();
}

class _PemeriksaanBalitaPageState extends State<PemeriksaanBalitaPage> {
  final CollectionReference _pemeriksaanCollection =
      FirebaseFirestore.instance.collection("pemeriksaan_balita");
  final CollectionReference _balitaCollection =
      FirebaseFirestore.instance.collection("balita");

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  static const Color primaryColor = Color(0xFFD81B60);
  static const Color primaryLight = Color(0xFFFF5983);
  static const Color primaryDark = Color(0xFFA00037);
  static const Color surfaceColor = Color(0xFFFFF8F9);
  static const Color cardColor = Color(0xFFFFFBFC);

  List<int> _availableYears() {
    final currentYear = DateTime.now().year;
    return [currentYear, currentYear + 1, currentYear + 2];
  }

  List<String> _monthNames = [
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: surfaceColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.filter_alt, color: primaryColor),
            ),
            const SizedBox(width: 12),
            const Text("Filter Pemeriksaan",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedMonth,
                decoration: const InputDecoration(
                  labelText: "Pilih Bulan",
                  labelStyle: TextStyle(color: primaryColor),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                dropdownColor: surfaceColor,
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text(_monthNames[index]),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  labelText: "Pilih Tahun",
                  labelStyle: TextStyle(color: primaryColor),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                dropdownColor: surfaceColor,
                items: _availableYears().map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text("$year"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value!;
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Tampilkan"),
          ),
        ],
      ),
    );
  }

  void _pilihBalitaDanTambahPemeriksaan() async {
    final balitaSnapshot = await _balitaCollection.orderBy("nama").get();

    if (balitaSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Tidak ada balita yang tersedia!"),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: surfaceColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.child_care, color: primaryColor),
            ),
            const SizedBox(width: 12),
            const Text("Pilih Balita",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: balitaSnapshot.docs.map((balita) {
                final data = balita.data() as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Text(
                        data["nama"][0].toUpperCase(),
                        style: const TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      data["nama"],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "NIK: ${data["nik"]}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: primaryColor, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      _tambahAtauEditPemeriksaan(
                        nik: data["nik"],
                        nama: data["nama"],
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _tambahAtauEditPemeriksaan({
    String? docId,
    String? nik,
    String? nama,
    double? tinggiBadan,
    double? beratBadan,
    double? lingkarKepala,
    int? bulan,
    int? tahun,
  }) {
    bulan ??= _selectedMonth;
    tahun ??= _selectedYear;

    final tinggiController =
        TextEditingController(text: tinggiBadan?.toString() ?? "");
    final beratController =
        TextEditingController(text: beratBadan?.toString() ?? "");
    final kepalaController =
        TextEditingController(text: lingkarKepala?.toString() ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: surfaceColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                docId == null ? Icons.add_circle : Icons.edit,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              docId == null ? "Tambah Pemeriksaan" : "Edit Pemeriksaan",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: primaryDark),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Text(
                          nama![0].toUpperCase(),
                          style: const TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              "NIK: $nik",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: primaryColor.withOpacity(0.3)),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: bulan,
                          decoration: const InputDecoration(
                            labelText: "Bulan",
                            labelStyle: TextStyle(color: primaryColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          dropdownColor: surfaceColor,
                          items: List.generate(12, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text(_monthNames[index]),
                            );
                          }),
                          onChanged: (value) {
                            bulan = value!;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: primaryColor.withOpacity(0.3)),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: tahun,
                          decoration: const InputDecoration(
                            labelText: "Tahun",
                            labelStyle: TextStyle(color: primaryColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          dropdownColor: surfaceColor,
                          items: _availableYears().map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text("$year"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            tahun = value!;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: tinggiController,
                  label: "Tinggi Badan",
                  suffix: "cm",
                  icon: Icons.height,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: beratController,
                  label: "Berat Badan",
                  suffix: "kg",
                  icon: Icons.monitor_weight,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: kepalaController,
                  label: "Lingkar Kepala",
                  suffix: "cm",
                  icon: Icons.face,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              if (tinggiController.text.isEmpty ||
                  beratController.text.isEmpty ||
                  kepalaController.text.isEmpty) return;

              final data = {
                "tinggi_badan": double.parse(tinggiController.text),
                "berat_badan": double.parse(beratController.text),
                "lingkar_kepala": double.parse(kepalaController.text),
              };

              if (docId == null) {
                await _pemeriksaanCollection.add({
                  ...data,
                  "nik": nik,
                  "nama": nama,
                  "bulan": bulan,
                  "tahun": tahun,
                  "created_at": FieldValue.serverTimestamp(),
                });
              } else {
                await _pemeriksaanCollection.doc(docId).update(data);
              }

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(docId == null
                    ? "Data berhasil ditambahkan!"
                    : "Data berhasil diperbarui!"),
                backgroundColor: primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: primaryColor),
          suffixText: suffix,
          suffixStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Future<void> _hapusPemeriksaan(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: surfaceColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text("Konfirmasi Hapus",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
          ],
        ),
        content: const Text(
            "Apakah Anda yakin ingin menghapus data pemeriksaan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _pemeriksaanCollection.doc(docId).delete();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Data pemeriksaan berhasil dihapus!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          "Pemeriksaan Balita",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.filter_alt, color: Colors.white),
              ),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    "Periode: ${_monthNames[_selectedMonth - 1]} $_selectedYear",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _pemeriksaanCollection
                  .where("bulan", isEqualTo: _selectedMonth)
                  .where("tahun", isEqualTo: _selectedYear)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada data pemeriksaan",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap tombol + untuk menambah data",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
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
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.05),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      primaryColor.withOpacity(0.1),
                                  child: Text(
                                    data["nama"][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data["nama"],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "NIK: ${data["nik"]}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: primaryColor, size: 20),
                                        onPressed: () =>
                                            _tambahAtauEditPemeriksaan(
                                          docId: doc.id,
                                          nik: data["nik"],
                                          nama: data["nama"],
                                          tinggiBadan: data["tinggi_badan"],
                                          beratBadan: data["berat_badan"],
                                          lingkarKepala: data["lingkar_kepala"],
                                          bulan: data["bulan"],
                                          tahun: data["tahun"],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                        onPressed: () =>
                                            _hapusPemeriksaan(doc.id),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.height,
                                    label: "Tinggi Badan",
                                    value: "${data["tinggi_badan"]} cm",
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.monitor_weight,
                                    label: "Berat Badan",
                                    value: "${data["berat_badan"]} kg",
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.face,
                                    label: "Lingkar Kepala",
                                    value: "${data["lingkar_kepala"]} cm",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
        onPressed: _pilihBalitaDanTambahPemeriksaan,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Tambah Data"),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
