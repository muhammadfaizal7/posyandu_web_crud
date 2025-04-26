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
  List<Map<String, dynamic>> ibuHamilList = [];

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
      const SnackBar(
        content: Text("Data berhasil dihapus"),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _showForm(
      {String? docId, Map<String, dynamic>? existingData}) async {
    if (existingData != null) {
      selectedNIK = existingData["nik"];
      selectedNama = existingData["nama"];
      tetanusToxoidController.text = existingData["tetanus_toxoid"];
      tabletDarahController.text = existingData["tablet_darah"];
      suplementasiController.text = existingData["suplementasi"];
    } else {
      selectedNIK = null;
      selectedNama = null;
      tetanusToxoidController.clear();
      tabletDarahController.clear();
      suplementasiController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            docId == null ? "Tambah Imunisasi & Obat" : "Edit Imunisasi & Obat",
            style: const TextStyle(color: Colors.deepPurple),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedNIK,
                  decoration:
                      const InputDecoration(labelText: "Pilih Ibu Hamil (NIK)"),
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
                TextField(
                    controller: tetanusToxoidController,
                    decoration: const InputDecoration(
                        labelText: "Pemberian Tetanus Toxoid (TT)")),
                TextField(
                    controller: tabletDarahController,
                    decoration: const InputDecoration(
                        labelText: "Pemberian Tablet Tambah Darah")),
                TextField(
                    controller: suplementasiController,
                    decoration: const InputDecoration(
                        labelText: "Suplementasi (Asam Folat, Kalsium, dll.)")),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              child: Text(docId == null ? "Simpan" : "Update"),
              onPressed: () async {
                Map<String, dynamic> formData = {
                  "nik": selectedNIK,
                  "nama": selectedNama,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text("Imunisasi dan Pemberian Obat"),
        backgroundColor: const Color(0xFFD81B60),
      ),
      body: StreamBuilder(
        stream: _imunisasiObat.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada data"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docData = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medication, color: Colors.pink),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${docData["nama"]} (NIK: ${docData["nik"]})",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("🔹 Tetanus Toxoid: ${docData["tetanus_toxoid"]}"),
                      Text(
                          "🔹 Tablet Tambah Darah: ${docData["tablet_darah"]}"),
                      Text("🔹 Suplementasi: ${docData["suplementasi"]}"),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.deepPurple),
                            onPressed: () =>
                                _showForm(docId: docId, existingData: docData),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteData(docId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }
}
