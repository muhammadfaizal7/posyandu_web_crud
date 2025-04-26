import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class DataBalitaPage extends StatefulWidget {
  const DataBalitaPage({super.key});

  @override
  _DataBalitaPageState createState() => _DataBalitaPageState();
}

class _DataBalitaPageState extends State<DataBalitaPage> {
  final CollectionReference _balitaCollection =
      FirebaseFirestore.instance.collection("balita");

  Future<void> _hapusBalita(String docId) async {
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
      await _balitaCollection.doc(docId).delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Data balita dihapus!")));
    }
  }

  void _tambahAtauEditBalita({
    String? docId,
    String? nama,
    String? nik,
    Timestamp? tanggalLahir,
    String? namaIbu,
  }) {
    final TextEditingController namaController =
        TextEditingController(text: nama);
    final TextEditingController nikController =
        TextEditingController(text: nik);
    final TextEditingController tanggalLahirController = TextEditingController(
      text: tanggalLahir != null
          ? DateFormat("yyyy-MM-dd").format(tanggalLahir.toDate())
          : "",
    );
    final TextEditingController namaIbuController =
        TextEditingController(text: namaIbu);
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          title: Text(
            docId == null ? "Tambah Data Balita" : "Edit Data Balita",
            style: const TextStyle(color: Colors.deepPurple),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nikController,
                    decoration: const InputDecoration(labelText: "NIK")),
                TextField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: "Nama")),
                TextField(
                    controller: tanggalLahirController,
                    decoration: const InputDecoration(
                        labelText: "Tanggal Lahir (YYYY-MM-DD)")),
                TextField(
                    controller: namaIbuController,
                    decoration: const InputDecoration(labelText: "Nama Ibu")),
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
                  DateTime parsedDate = DateFormat("yyyy-MM-dd")
                      .parse(tanggalLahirController.text);
                  tanggalLahirTimestamp = Timestamp.fromDate(parsedDate);
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Format tanggal tidak valid! (YYYY-MM-DD)")));
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
                    await _balitaCollection.doc(nik).set({
                      "nik": nik,
                      "nama": namaController.text.trim(),
                      "password": hashedPassword,
                      "tanggal_lahir": tanggalLahirTimestamp,
                      "nama_ibu": namaIbuController.text.trim(),
                      "created_at": FieldValue.serverTimestamp(),
                    });
                  } else {
                    await _balitaCollection.doc(docId).update({
                      "nama": namaController.text.trim(),
                      "tanggal_lahir": tanggalLahirTimestamp,
                      "nama_ibu": namaIbuController.text.trim(),
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
        title: const Text("Data Balita Posyandu Anggrek Merah"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _tambahAtauEditBalita(),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _balitaCollection
            .orderBy("created_at", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("Belum ada data balita",
                    style: TextStyle(color: Colors.grey)));
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
                            radius: 24,
                            backgroundColor: Colors.pinkAccent[100],
                            child: const Icon(Icons.child_care,
                                size: 28, color: Colors.white),
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
                              _tambahAtauEditBalita(
                                docId: document.id,
                                nik: data["nik"],
                                nama: data["nama"],
                                tanggalLahir: data["tanggal_lahir"],
                                namaIbu: data["nama_ibu"],
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusBalita(document.id),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text("Tanggal Lahir: $formattedDate",
                          style: const TextStyle(fontSize: 14)),
                      Text("Nama Ibu: ${data["nama_ibu"]}",
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
