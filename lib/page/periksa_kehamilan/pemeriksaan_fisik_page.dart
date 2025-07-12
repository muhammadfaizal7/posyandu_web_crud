import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PemeriksaanFisikPage extends StatefulWidget {
  const PemeriksaanFisikPage({super.key});

  @override
  _PemeriksaanFisikPageState createState() => _PemeriksaanFisikPageState();
}

class _PemeriksaanFisikPageState extends State<PemeriksaanFisikPage> {
  final CollectionReference _pemeriksaanFisik =
      FirebaseFirestore.instance.collection('pemeriksaan_fisik');
  final CollectionReference _ibuHamil =
      FirebaseFirestore.instance.collection('ibu_hamil');

  final TextEditingController beratBadanController = TextEditingController();
  final TextEditingController tinggiBadanController = TextEditingController();
  final TextEditingController tekananDarahController = TextEditingController();
  final TextEditingController lingkarLenganController = TextEditingController();
  final TextEditingController tinggiFundusController = TextEditingController();
  final TextEditingController denyutJantungController = TextEditingController();
  final TextEditingController letakJaninController = TextEditingController();
  final TextEditingController gerakanJaninController = TextEditingController();
  final TextEditingController edemaController = TextEditingController();
  final TextEditingController proteinUrinController = TextEditingController();
  final TextEditingController gulaUrinController = TextEditingController();

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
    final snapshot = await _ibuHamil.get();
    setState(() {
      ibuHamilList = snapshot.docs
          .map((doc) => {"nik": doc["nik"], "nama": doc["nama"]})
          .toList();
    });
  }

  Future<void> _deleteData(String docId) async {
    await _pemeriksaanFisik.doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: const Text("Data berhasil dihapus"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
  }

  Future<void> _showForm(
      {String? docId, Map<String, dynamic>? existingData}) async {
    if (existingData != null) {
      selectedNIK = existingData["nik"];
      selectedNama = existingData["nama"];
      selectedBulan = existingData["bulan"];
      selectedTahun = existingData["tahun"];
      beratBadanController.text = existingData["berat_badan"];
      tinggiBadanController.text = existingData["tinggi_badan"];
      tekananDarahController.text = existingData["tekanan_darah"];
      lingkarLenganController.text = existingData["lingkar_lengan"];
      tinggiFundusController.text = existingData["tinggi_fundus"];
      denyutJantungController.text = existingData["denyut_jantung"];
      letakJaninController.text = existingData["letak_janin"];
      gerakanJaninController.text = existingData["gerakan_janin"];
      edemaController.text = existingData["edema"];
      proteinUrinController.text = existingData["protein_urin"];
      gulaUrinController.text = existingData["gula_urin"];
    } else {
      selectedNIK = null;
      selectedNama = null;
      selectedBulan = null;
      selectedTahun = null;
      beratBadanController.clear();
      tinggiBadanController.clear();
      tekananDarahController.clear();
      lingkarLenganController.clear();
      tinggiFundusController.clear();
      denyutJantungController.clear();
      letakJaninController.clear();
      gerakanJaninController.clear();
      edemaController.clear();
      proteinUrinController.clear();
      gulaUrinController.clear();
    }

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
              child: Icon(
                docId == null ? Icons.add_circle : Icons.edit,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              docId == null
                  ? "Tambah Pemeriksaan Fisik"
                  : "Edit Pemeriksaan Fisik",
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
                  onChanged: (val) {
                    setState(() {
                      selectedNIK = val;
                      selectedNama = ibuHamilList
                          .firstWhere((e) => e["nik"] == val)["nama"];
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
                  items: bulanList.map((b) {
                    return DropdownMenuItem(value: b, child: Text("Bulan $b"));
                  }).toList(),
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
                  items: tahunList.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedTahun = val),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                child: TextField(
                  controller: beratBadanController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Berat Badan (kg)",
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
                  controller: tinggiBadanController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Tinggi Badan (cm)",
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
                  controller: tekananDarahController,
                  decoration: const InputDecoration(
                    labelText: "Tekanan Darah (mmHg)",
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
                  controller: lingkarLenganController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Lingkar Lengan Atas (cm)",
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
                  controller: tinggiFundusController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Tinggi Fundus Uteri (cm)",
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
                  controller: denyutJantungController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Denyut Jantung Janin (bpm)",
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
                  controller: letakJaninController,
                  decoration: const InputDecoration(
                    labelText: "Letak Janin",
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
                  controller: gerakanJaninController,
                  decoration: const InputDecoration(
                    labelText: "Gerakan Janin",
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
                  controller: edemaController,
                  decoration: const InputDecoration(
                    labelText: "Edema (Bengkak)",
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
                  controller: proteinUrinController,
                  decoration: const InputDecoration(
                    labelText: "Protein Urin",
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
                  controller: gulaUrinController,
                  decoration: const InputDecoration(
                    labelText: "Gula Urin",
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
            child: Text(docId == null ? "Simpan" : "Update"),
            onPressed: () async {
              final data = {
                "nik": selectedNIK,
                "nama": selectedNama,
                "bulan": selectedBulan,
                "tahun": selectedTahun,
                "berat_badan": beratBadanController.text,
                "tinggi_badan": tinggiBadanController.text,
                "tekanan_darah": tekananDarahController.text,
                "lingkar_lengan": lingkarLenganController.text,
                "tinggi_fundus": tinggiFundusController.text,
                "denyut_jantung": denyutJantungController.text,
                "letak_janin": letakJaninController.text,
                "gerakan_janin": gerakanJaninController.text,
                "edema": edemaController.text,
                "protein_urin": proteinUrinController.text,
                "gula_urin": gulaUrinController.text,
              };

              if (docId == null) {
                await _pemeriksaanFisik.add(data);
              } else {
                await _pemeriksaanFisik.doc(docId).update(data);
              }

              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    String? tempBulan = selectedBulan;
    String? tempTahun = selectedTahun;

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
                child: const Icon(Icons.filter_alt, color: primaryColor),
              ),
              const SizedBox(width: 12),
              const Text(
                "Filter Pemeriksaan",
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
        );
      },
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
          "Pemeriksaan Fisik",
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
        stream: _pemeriksaanFisik.snapshots(),
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
                    "Belum ada data pemeriksaan fisik",
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
                    padding: const EdgeInsets.all(16),
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
                                Icons.monitor_heart, // Icon pemeriksaan fisik
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
                                icon: Icons.scale,
                                label: "Berat Badan",
                                value: "${docData["berat_badan"]} kg",
                              ),
                              _buildInfoRow(
                                icon: Icons.height,
                                label: "Tinggi Badan",
                                value: "${docData["tinggi_badan"]} cm",
                              ),
                              _buildInfoRow(
                                icon: Icons.monitor_heart,
                                label: "Tekanan Darah",
                                value: "${docData["tekanan_darah"]} mmHg",
                              ),
                              _buildInfoRow(
                                icon: Icons.circle_outlined,
                                label: "Lingkar Lengan",
                                value: "${docData["lingkar_lengan"]} cm",
                              ),
                              _buildInfoRow(
                                icon: Icons.straighten,
                                label: "Tinggi Fundus Uteri",
                                value: "${docData["tinggi_fundus"]} cm",
                              ),
                              _buildInfoRow(
                                icon: Icons.favorite,
                                label: "Denyut Jantung Janin",
                                value: "${docData["denyut_jantung"]} bpm",
                              ),
                              _buildInfoRow(
                                icon: Icons.baby_changing_station,
                                label: "Letak Janin",
                                value: "${docData["letak_janin"]}",
                              ),
                              _buildInfoRow(
                                icon: Icons.motion_photos_on,
                                label: "Gerakan Janin",
                                value: "${docData["gerakan_janin"]}",
                              ),
                              _buildInfoRow(
                                icon: Icons.sick_outlined,
                                label: "Edema",
                                value: "${docData["edema"]}",
                              ),
                              _buildInfoRow(
                                icon: Icons.science,
                                label: "Protein Urin",
                                value: "${docData["protein_urin"]}",
                              ),
                              _buildInfoRow(
                                icon: Icons
                                    .local_cafe, // Ganti dengan icon yang lebih sesuai jika ada
                                label: "Gula Urin",
                                value: "${docData["gula_urin"]}",
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
        label: const Text("Tambah Pemeriksaan"),
      ),
    );
  }
}
