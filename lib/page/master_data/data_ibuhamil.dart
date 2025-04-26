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
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus")),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _ibuHamilCollection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data ibu hamil dihapus!")));
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
          backgroundColor: Colors.pink[50],
          title: Text(
              docId == null ? "Tambah Data Ibu Hamil" : "Edit Data Ibu Hamil",
              style: const TextStyle(color: Colors.deepPurple)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nikController,
                    enabled: docId == null,
                    decoration: const InputDecoration(labelText: "NIK")),
                TextField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: "Nama")),
                TextField(
                    controller: golDarahController,
                    decoration:
                        const InputDecoration(labelText: "Golongan Darah")),
                TextField(
                    controller: tanggalLahirController,
                    decoration: const InputDecoration(
                        labelText: "Tanggal Lahir (YYYY-MM-DD)")),
                TextField(
                    controller: pendidikanController,
                    decoration: const InputDecoration(labelText: "Pendidikan")),
                TextField(
                    controller: pekerjaanController,
                    decoration: const InputDecoration(labelText: "Pekerjaan")),
                TextField(
                    controller: alamatController,
                    decoration: const InputDecoration(labelText: "Alamat")),
                TextField(
                    controller: teleponController,
                    decoration: const InputDecoration(labelText: "Telepon")),
                if (docId == null)
                  TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password")),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent[100]),
              onPressed: () async {
                String nik = nikController.text.trim();
                if (nik.isEmpty || nik.contains(RegExp(r'[/.#\$[\]]'))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("NIK tidak valid!")));
                  return;
                }

                Timestamp tanggalLahirTimestamp;
                try {
                  tanggalLahirTimestamp = Timestamp.fromDate(
                      DateFormat("yyyy-MM-dd")
                          .parse(tanggalLahirController.text.trim()));
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Format tanggal tidak valid! Gunakan YYYY-MM-DD")));
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

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(docId == null
                          ? "Data berhasil ditambahkan!"
                          : "Data berhasil diperbarui!")));
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Terjadi kesalahan: $e")));
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD81B60),
        title: const Text("Data Ibu Hamil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _tambahAtauEditIbuHamil(),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _ibuHamilCollection
            .orderBy("created_at", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Tidak ada data ibu hamil",
                  style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              String formattedDate = DateFormat("dd MMMM yyyy")
                  .format((data["tanggal_lahir"] as Timestamp).toDate());

              return Card(
                color: Colors.white,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.pink[200],
                            radius: 24,
                            child: const Icon(Icons.female,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data["nama"],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("NIK: ${data["nik"]}",
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.purple),
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
                          IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusIbuHamil(document.id)),
                        ],
                      ),
                      const Divider(height: 20),
                      Text("Tanggal Lahir: $formattedDate",
                          style: const TextStyle(fontSize: 14)),
                      Text("Golongan Darah: ${data["gol_darah"]}",
                          style: const TextStyle(fontSize: 14)),
                      Text("Pendidikan: ${data["pendidikan"]}",
                          style: const TextStyle(fontSize: 14)),
                      Text("Pekerjaan: ${data["pekerjaan"]}",
                          style: const TextStyle(fontSize: 14)),
                      Text("Alamat: ${data["alamat"]}",
                          style: const TextStyle(fontSize: 14)),
                      Text("Telepon: ${data["telepon"]}",
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
