import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImunisasiObatPage extends StatefulWidget {
  const ImunisasiObatPage({super.key});

  @override
  _ImunisasiObatPageState createState() => _ImunisasiObatPageState();
}

class _ImunisasiObatPageState extends State<ImunisasiObatPage> {
  final CollectionReference _imunisasiObat =
      FirebaseFirestore.instance.collection('imunisasi_obat');
  final CollectionReference _ibuHamil =
      FirebaseFirestore.instance.collection('ibu_hamil');

  final TextEditingController tetanusToxoidController = TextEditingController();
  final TextEditingController tabletDarahController = TextEditingController();
  final TextEditingController suplementasiController = TextEditingController();

  String? selectedNIK;
  String? selectedNama;
  String? selectedBulan;
  String? selectedTahun;

  List<Map<String, dynamic>> ibuHamilList = [];

  final List<String> bulanList = List.generate(12, (i) => (i + 1).toString());
  final List<String> tahunList =
      List.generate(5, (i) => (DateTime.now().year + i).toString());

  // Consistent color scheme
  static const Color primaryColor = Color(0xFFD81B60);
  static const Color primaryLight = Color(0xFFFF5983);
  static const Color primaryDark = Color(0xFFA00037);
  static const Color backgroundColor = Color(0xFFFFF0F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    fetchIbuHamilData();
  }

  Future<void> fetchIbuHamilData() async {
    try {
      QuerySnapshot snapshot = await _ibuHamil.get();
      setState(() {
        ibuHamilList = snapshot.docs.map((doc) {
          return {
            "nik": doc["nik"],
            "nama": doc["nama"],
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching ibu hamil data: $e");
    }
  }

  Future<void> _deleteData(String docId) async {
    await _imunisasiObat.doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Data berhasil dihapus"),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _showForm(
      {String? docId, Map<String, dynamic>? existingData}) async {
    if (existingData != null) {
      selectedNIK = existingData["nik"];
      selectedNama = existingData["nama"];
      selectedBulan = existingData["bulan"];
      selectedTahun = existingData["tahun"];
      tetanusToxoidController.text = existingData["tetanus_toxoid"];
      tabletDarahController.text = existingData["tablet_darah"];
      suplementasiController.text = existingData["suplementasi"];
    } else {
      selectedNIK = null;
      selectedNama = null;
      selectedBulan = null;
      selectedTahun = null;
      tetanusToxoidController.clear();
      tabletDarahController.clear();
      suplementasiController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                docId == null
                    ? "Tambah Imunisasi & Obat"
                    : "Edit Imunisasi & Obat",
                style: const TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField(
                  child: DropdownButtonFormField<String>(
                    value: selectedNIK,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Pilih Ibu Hamil (NIK)",
                      labelStyle: TextStyle(color: textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: ibuHamilList.map((data) {
                      return DropdownMenuItem<String>(
                        value: data["nik"],
                        child: Text("${data["nik"]} - ${data["nama"]}"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedNIK = value;
                        selectedNama = ibuHamilList
                            .firstWhere((data) => data["nik"] == value)["nama"];
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  child: DropdownButtonFormField<String>(
                    value: selectedBulan,
                    decoration: const InputDecoration(
                      labelText: "Bulan",
                      labelStyle: TextStyle(color: textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: bulanList
                        .map((b) =>
                            DropdownMenuItem(value: b, child: Text("Bulan $b")))
                        .toList(),
                    onChanged: (val) => setState(() => selectedBulan = val),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  child: DropdownButtonFormField<String>(
                    value: selectedTahun,
                    decoration: const InputDecoration(
                      labelText: "Tahun",
                      labelStyle: TextStyle(color: textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: tahunList
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedTahun = val),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  child: TextField(
                    controller: tetanusToxoidController,
                    decoration: const InputDecoration(
                      labelText: "Pemberian Tetanus Toxoid (TT)",
                      labelStyle: TextStyle(color: textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  child: TextField(
                    controller: tabletDarahController,
                    decoration: const InputDecoration(
                      labelText: "Pemberian Tablet Tambah Darah",
                      labelStyle: TextStyle(color: textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  child: TextField(
                    controller: suplementasiController,
                    decoration: const InputDecoration(
                      labelText: "Suplementasi (Asam Folat, Kalsium, dll.)",
                      labelStyle: TextStyle(color: textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(docId == null ? "Simpan" : "Update"),
              onPressed: () async {
                Map<String, dynamic> formData = {
                  "nik": selectedNIK,
                  "nama": selectedNama,
                  "bulan": selectedBulan,
                  "tahun": selectedTahun,
                  "tetanus_toxoid": tetanusToxoidController.text,
                  "tablet_darah": tabletDarahController.text,
                  "suplementasi": suplementasiController.text,
                };

                if (docId == null) {
                  await _imunisasiObat.add(formData);
                } else {
                  await _imunisasiObat.doc(docId).update(formData);
                }

                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    String? tempBulan = selectedBulan;
    String? tempTahun = selectedTahun;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            const Text(
              "Filter Imunisasi & Obat",
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: tempBulan,
                decoration: const InputDecoration(
                  labelText: "Pilih Bulan",
                  labelStyle: TextStyle(color: textSecondary),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: bulanList
                    .map((b) =>
                        DropdownMenuItem(value: b, child: Text("Bulan $b")))
                    .toList(),
                onChanged: (val) => tempBulan = val,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: tempTahun,
                decoration: const InputDecoration(
                  labelText: "Pilih Tahun",
                  labelStyle: TextStyle(color: textSecondary),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: tahunList
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => tempTahun = val,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Tampilkan"),
            onPressed: () {
              setState(() {
                selectedBulan = tempBulan;
                selectedTahun = tempTahun;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // This function is not used in the original ImunisasiObatPage,
  // but included for consistency if expandable sections are desired later.
  // ignore: unused_element
  Widget _buildExpandableSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: primaryColor, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Imunisasi dan Pemberian Obat",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.filter_alt_outlined, color: Colors.white),
              ),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _imunisasiObat.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.folder_open,
                      size: 50,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Belum ada data imunisasi dan obat",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final bulan = data["bulan"];
            final tahun = data["tahun"];
            if (selectedBulan != null && selectedBulan != bulan) return false;
            if (selectedTahun != null && selectedTahun != tahun) return false;
            return true;
          }).toList();

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.folder_open,
                      size: 50,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Tidak ada data ditemukan untuk filter ini",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
              final docData = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        cardColor,
                        primaryColor.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.vaccines, // Icon untuk imunisasi/obat
                                color: primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${docData["nama"]}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    "NIK: ${docData["nik"]}",
                                    style: const TextStyle(
                                      color: textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "Bulan: ${docData["bulan"]}, Tahun: ${docData["tahun"]}",
                                    style: const TextStyle(
                                      color: textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                icon: Icons.medical_services,
                                label: "Tetanus Toxoid",
                                value: "${docData["tetanus_toxoid"]}",
                              ),
                              _buildInfoRow(
                                icon: Icons.bloodtype,
                                label: "Tablet Tambah Darah",
                                value: "${docData["tablet_darah"]}",
                              ),
                              _buildInfoRow(
                                icon: Icons.medication,
                                label: "Suplementasi",
                                value: "${docData["suplementasi"]}",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon:
                                    const Icon(Icons.edit, color: primaryColor),
                                onPressed: () => _showForm(
                                    docId: docId, existingData: docData),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteData(docId),
                              ),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text("Tambah Imunisasi & Obat"),
      ),
    );
  }
}
