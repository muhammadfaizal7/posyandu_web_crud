import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class DataIbuHamilPage extends StatefulWidget {
  const DataIbuHamilPage({super.key});

  @override
  _DataIbuHamilPageState createState() => _DataIbuHamilPageState();
}

class _DataIbuHamilPageState extends State<DataIbuHamilPage> {
  final CollectionReference _ibuHamilCollection =
      FirebaseFirestore.instance.collection("ibu_hamil");

  Future<void> _hapusIbuHamil(String docId) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Konfirmasi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD81B60),
          ),
        ),
        content: const Text(
          "Apakah Anda yakin ingin menghapus data ini?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _ibuHamilCollection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Data ibu hamil berhasil dihapus!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _tambahAtauEditIbuHamil({
    String? docId,
    String? nama,
    String? nik,
    String? golDarah,
    Timestamp? tanggalLahir,
    String? pendidikan,
    String? pekerjaan,
    String? alamat,
    String? telepon,
  }) {
    final TextEditingController namaController =
        TextEditingController(text: nama ?? "");
    final TextEditingController nikController =
        TextEditingController(text: nik ?? "");
    final TextEditingController golDarahController =
        TextEditingController(text: golDarah ?? "");
    final TextEditingController tanggalLahirController = TextEditingController(
      text: tanggalLahir != null
          ? DateFormat("yyyy-MM-dd").format(tanggalLahir.toDate())
          : "",
    );
    final TextEditingController pendidikanController =
        TextEditingController(text: pendidikan ?? "");
    final TextEditingController pekerjaanController =
        TextEditingController(text: pekerjaan ?? "");
    final TextEditingController alamatController =
        TextEditingController(text: alamat ?? "");
    final TextEditingController teleponController =
        TextEditingController(text: telepon ?? "");
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD81B60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              docId == null ? "Tambah Data Ibu Hamil" : "Edit Data Ibu Hamil",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: nikController,
                    label: "NIK",
                    icon: Icons.credit_card,
                    enabled: docId == null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: namaController,
                    label: "Nama Lengkap",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: golDarahController,
                    label: "Golongan Darah",
                    icon: Icons.bloodtype,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: tanggalLahirController,
                    label: "Tanggal Lahir (YYYY-MM-DD)",
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: pendidikanController,
                    label: "Pendidikan",
                    icon: Icons.school,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: pekerjaanController,
                    label: "Pekerjaan",
                    icon: Icons.work,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: alamatController,
                    label: "Alamat",
                    icon: Icons.home,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: teleponController,
                    label: "Nomor Telepon",
                    icon: Icons.phone,
                  ),
                  if (docId == null) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: passwordController,
                      label: "Password",
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD81B60),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                String nik = nikController.text.trim();
                if (nik.isEmpty || nik.contains(RegExp(r'[/.#\$[\]]'))) {
                  _showSnackBar("NIK tidak valid!", Colors.red);
                  return;
                }

                Timestamp tanggalLahirTimestamp;
                try {
                  tanggalLahirTimestamp = Timestamp.fromDate(
                      DateFormat("yyyy-MM-dd")
                          .parse(tanggalLahirController.text.trim()));
                } catch (_) {
                  _showSnackBar(
                      "Format tanggal tidak valid! Gunakan YYYY-MM-DD",
                      Colors.red);
                  return;
                }

                String hashedPassword =
                    docId == null && passwordController.text.isNotEmpty
                        ? sha256
                            .convert(utf8.encode(passwordController.text))
                            .toString()
                        : "";

                try {
                  if (docId == null) {
                    await _ibuHamilCollection.doc(nik).set({
                      "nik": nik,
                      "nama": namaController.text.trim(),
                      "gol_darah": golDarahController.text.trim(),
                      "tanggal_lahir": tanggalLahirTimestamp,
                      "pendidikan": pendidikanController.text.trim(),
                      "pekerjaan": pekerjaanController.text.trim(),
                      "alamat": alamatController.text.trim(),
                      "telepon": teleponController.text.trim(),
                      "password": hashedPassword,
                      "created_at": FieldValue.serverTimestamp(),
                    });
                  } else {
                    await _ibuHamilCollection.doc(docId).update({
                      "nama": namaController.text.trim(),
                      "gol_darah": golDarahController.text.trim(),
                      "tanggal_lahir": tanggalLahirTimestamp,
                      "pendidikan": pendidikanController.text.trim(),
                      "pekerjaan": pekerjaanController.text.trim(),
                      "alamat": alamatController.text.trim(),
                      "telepon": teleponController.text.trim(),
                    });
                  }

                  _showSnackBar(
                      docId == null
                          ? "Data berhasil ditambahkan!"
                          : "Data berhasil diperbarui!",
                      Colors.green);
                  Navigator.pop(context);
                } catch (e) {
                  _showSnackBar("Terjadi kesalahan: $e", Colors.red);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFD81B60)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD81B60)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD81B60), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD81B60),
        foregroundColor: Colors.white,
        title: const Text(
          "Data Ibu Hamil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              onPressed: () => _tambahAtauEditIbuHamil(),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _ibuHamilCollection
            .orderBy("created_at", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD81B60),
                strokeWidth: 3,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.pregnant_woman,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tidak ada data ibu hamil",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap tombol + untuk menambah data",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              String formattedDate = DateFormat("dd MMMM yyyy")
                  .format((data["tanggal_lahir"] as Timestamp).toDate());

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header dengan nama dan avatar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD81B60).withOpacity(0.1),
                            const Color(0xFFD81B60).withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD81B60), Color(0xFFE91E63)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.pregnant_woman,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["nama"] ?? "N/A",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD81B60)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "NIK: ${data["nik"] ?? "N/A"}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFD81B60),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildActionButton(
                            icon: Icons.edit,
                            color: Colors.orange,
                            onPressed: () {
                              _tambahAtauEditIbuHamil(
                                docId: document.id,
                                nama: data["nama"],
                                nik: data["nik"],
                                golDarah: data["gol_darah"],
                                tanggalLahir: data["tanggal_lahir"],
                                pendidikan: data["pendidikan"],
                                pekerjaan: data["pekerjaan"],
                                alamat: data["alamat"],
                                telepon: data["telepon"],
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete,
                            color: Colors.red,
                            onPressed: () => _hapusIbuHamil(document.id),
                          ),
                        ],
                      ),
                    ),
                    // Body dengan informasi detail
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: "Tanggal Lahir",
                            value: formattedDate,
                          ),
                          _buildInfoRow(
                            icon: Icons.bloodtype,
                            label: "Golongan Darah",
                            value: data["gol_darah"] ?? "N/A",
                          ),
                          _buildInfoRow(
                            icon: Icons.school,
                            label: "Pendidikan",
                            value: data["pendidikan"] ?? "N/A",
                          ),
                          _buildInfoRow(
                            icon: Icons.work,
                            label: "Pekerjaan",
                            value: data["pekerjaan"] ?? "N/A",
                          ),
                          _buildInfoRow(
                            icon: Icons.home,
                            label: "Alamat",
                            value: data["alamat"] ?? "N/A",
                          ),
                          _buildInfoRow(
                            icon: Icons.phone,
                            label: "Telepon",
                            value: data["telepon"] ?? "N/A",
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD81B60).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFD81B60),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
