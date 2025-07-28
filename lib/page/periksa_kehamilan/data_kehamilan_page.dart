import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataKehamilanPage extends StatefulWidget {
  const DataKehamilanPage({super.key});

  @override
  State<DataKehamilanPage> createState() => _DataKehamilanPageState();
}

class _DataKehamilanPageState extends State<DataKehamilanPage> {
  final CollectionReference _dataKehamilan =
      FirebaseFirestore.instance.collection('data_kehamilan');
  final CollectionReference _ibuHamil =
      FirebaseFirestore.instance.collection('ibu_hamil');

  final TextEditingController tanggalPeriksaController =
      TextEditingController();
  final TextEditingController usiaKehamilanController = TextEditingController();
  final TextEditingController taksiranPersalinanController =
      TextEditingController();
  final TextEditingController keluhanController = TextEditingController();
  final TextEditingController riwayatPenyakitController =
      TextEditingController();
  final TextEditingController riwayatAlergiController = TextEditingController();

  String? selectedNIK;
  String? selectedNama;
  List<Map<String, dynamic>> ibuHamilList = [];

  String? gravida;
  String? para;
  String? abortus;

  String? selectedBulan;
  String? selectedTahun;

  final List<String> bulanList = List.generate(12, (i) => (i + 1).toString());
  final List<String> tahunList =
      List.generate(10, (index) => '${DateTime.now().year - index}');

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

  // Fungsi untuk mendapatkan tanggal saat ini dalam format YYYY-MM-DD
  String getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  Future<void> fetchIbuHamilData() async {
    final snapshot = await _ibuHamil.get();
    setState(() {
      ibuHamilList = snapshot.docs
          .map((doc) => {"nik": doc["nik"], "nama": doc["nama"]})
          .toList();
    });
  }

  Stream<QuerySnapshot> getFilteredDataStream() {
    return _dataKehamilan.snapshots();
  }

  Future<void> _deleteData(String docId) async {
    await _dataKehamilan.doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Data berhasil dihapus"),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Future<void> _showForm(
      {String? docId, Map<String, dynamic>? existingData}) async {
    if (existingData != null) {
      selectedNIK = existingData["nik"];
      selectedNama = existingData["nama"];
      tanggalPeriksaController.text = existingData["tanggal_periksa"];
      usiaKehamilanController.text = existingData["usia_kehamilan"];
      taksiranPersalinanController.text = existingData["taksiran_persalinan"];
      keluhanController.text = existingData["keluhan"];
      riwayatPenyakitController.text = existingData["riwayat_penyakit"];
      riwayatAlergiController.text = existingData["riwayat_alergi"];
      gravida = existingData["gravida"];
      para = existingData["para"];
      abortus = existingData["abortus"];
    } else {
      selectedNIK = null;
      selectedNama = null;
      // Otomatis isi dengan tanggal saat ini untuk data baru
      tanggalPeriksaController.text = getCurrentDate();
      usiaKehamilanController.clear();
      taksiranPersalinanController.clear();
      keluhanController.clear();
      riwayatPenyakitController.clear();
      riwayatAlergiController.clear();
      gravida = null;
      para = null;
      abortus = null;
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
              docId == null ? "Tambah Data Kehamilan" : "Edit Data Kehamilan",
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tanggalPeriksaController,
                        readOnly: true, // Buat field read-only
                        decoration: const InputDecoration(
                          labelText: "Tanggal Periksa",
                          labelStyle: TextStyle(color: textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon:
                              Icon(Icons.calendar_today, color: primaryColor),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh,
                            color: primaryColor, size: 20),
                        tooltip: "Perbarui ke tanggal hari ini",
                        onPressed: () {
                          setState(() {
                            tanggalPeriksaController.text = getCurrentDate();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                child: TextField(
                  controller: usiaKehamilanController,
                  decoration: const InputDecoration(
                    labelText: "Usia Kehamilan (Minggu)",
                    labelStyle: TextStyle(color: textSecondary),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                child: TextField(
                  controller: taksiranPersalinanController,
                  decoration: const InputDecoration(
                    labelText: "Taksiran Persalinan",
                    labelStyle: TextStyle(color: textSecondary),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      child: DropdownButtonFormField<String>(
                        value: gravida,
                        decoration: const InputDecoration(
                          labelText: "Gravida (G)",
                          labelStyle: TextStyle(color: textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        items: ["0", "1", "2", "3+"].map((val) {
                          return DropdownMenuItem(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) => setState(() => gravida = val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInputField(
                      child: DropdownButtonFormField<String>(
                        value: para,
                        decoration: const InputDecoration(
                          labelText: "Para (P)",
                          labelStyle: TextStyle(color: textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        items: ["0", "1", "2", "3+"].map((val) {
                          return DropdownMenuItem(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) => setState(() => para = val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInputField(
                      child: DropdownButtonFormField<String>(
                        value: abortus,
                        decoration: const InputDecoration(
                          labelText: "Abortus (A)",
                          labelStyle: TextStyle(color: textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        items: ["0", "1", "2", "3+"].map((val) {
                          return DropdownMenuItem(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) => setState(() => abortus = val),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputField(
                child: TextField(
                  controller: keluhanController,
                  decoration: const InputDecoration(
                    labelText: "Keluhan Saat Ini",
                    labelStyle: TextStyle(color: textSecondary),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                child: TextField(
                  controller: riwayatPenyakitController,
                  decoration: const InputDecoration(
                    labelText: "Riwayat Penyakit dalam Kehamilan",
                    labelStyle: TextStyle(color: textSecondary),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                child: TextField(
                  controller: riwayatAlergiController,
                  decoration: const InputDecoration(
                    labelText: "Riwayat Alergi",
                    labelStyle: TextStyle(color: textSecondary),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: 2,
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
              final tanggal = tanggalPeriksaController.text;
              final bulan = tanggal.length >= 7
                  ? int.parse(tanggal.substring(5, 7))
                      .toString() // hilangkan nol di depan
                  : '';

              final tahun = tanggal.length >= 4 ? tanggal.substring(0, 4) : '';

              final data = {
                "nik": selectedNIK,
                "nama": selectedNama,
                "tanggal_periksa": tanggal,
                "bulan": bulan,
                "tahun": tahun,
                "usia_kehamilan": usiaKehamilanController.text,
                "taksiran_persalinan": taksiranPersalinanController.text,
                "gravida": gravida,
                "para": para,
                "abortus": abortus,
                "keluhan": keluhanController.text,
                "riwayat_penyakit": riwayatPenyakitController.text,
                "riwayat_alergi": riwayatAlergiController.text,
              };

              if (docId == null) {
                await _dataKehamilan.add(data);
              } else {
                await _dataKehamilan.doc(docId).update(data);
              }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Data Kehamilan",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: getFilteredDataStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
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
                    "Tidak ada data ditemukan",
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
              final data = docs[index].data() as Map<String, dynamic>;
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
                                Icons.pregnant_woman,
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
                                    "${data["nama"]}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    "NIK: ${data["nik"]}",
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
                                icon: Icons.calendar_today,
                                label: "Tanggal Periksa",
                                value: "${data["tanggal_periksa"]}",
                              ),
                              _buildInfoRow(
                                icon: Icons.timer,
                                label: "Usia Kehamilan",
                                value: "${data["usia_kehamilan"]} Minggu",
                              ),
                              _buildInfoRow(
                                icon: Icons.event,
                                label: "Taksiran Persalinan",
                                value: "${data["taksiran_persalinan"]}",
                              ),
                              _buildInfoRow(
                                icon: Icons.medical_information,
                                label: "G-P-A",
                                value:
                                    "G: ${data["gravida"]}, P: ${data["para"]}, A: ${data["abortus"]}",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (data["keluhan"] != null &&
                            data["keluhan"].toString().isNotEmpty)
                          _buildExpandableSection(
                            title: "Keluhan",
                            content: "${data["keluhan"]}",
                            icon: Icons.sick,
                          ),
                        if (data["riwayat_penyakit"] != null &&
                            data["riwayat_penyakit"].toString().isNotEmpty)
                          _buildExpandableSection(
                            title: "Riwayat Penyakit",
                            content: "${data["riwayat_penyakit"]}",
                            icon: Icons.history,
                          ),
                        if (data["riwayat_alergi"] != null &&
                            data["riwayat_alergi"].toString().isNotEmpty)
                          _buildExpandableSection(
                            title: "Riwayat Alergi",
                            content: "${data["riwayat_alergi"]}",
                            icon: Icons.warning,
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
                                onPressed: () =>
                                    _showForm(docId: docId, existingData: data),
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
        label: const Text("Tambah Data"),
      ),
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
}
