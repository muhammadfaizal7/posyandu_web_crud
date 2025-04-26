import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataKehamilanPage extends StatefulWidget {
  const DataKehamilanPage({super.key});

  @override
  _DataKehamilanPageState createState() => _DataKehamilanPageState();
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
    await _dataKehamilan.doc(docId).delete();
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
      setState(() {
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
      });
    } else {
      setState(() {
        selectedNIK = null;
        selectedNama = null;
        tanggalPeriksaController.clear();
        usiaKehamilanController.clear();
        taksiranPersalinanController.clear();
        keluhanController.clear();
        riwayatPenyakitController.clear();
        riwayatAlergiController.clear();
        gravida = null;
        para = null;
        abortus = null;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            docId == null ? "Tambah Data Kehamilan" : "Edit Data Kehamilan",
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
                  controller: tanggalPeriksaController,
                  decoration:
                      const InputDecoration(labelText: "Tanggal Periksa"),
                ),
                TextField(
                  controller: usiaKehamilanController,
                  decoration: const InputDecoration(
                      labelText: "Usia Kehamilan (Minggu)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: taksiranPersalinanController,
                  decoration: const InputDecoration(
                      labelText: "Taksiran Persalinan (TP)"),
                ),
                DropdownButtonFormField<String>(
                  value: gravida,
                  decoration: const InputDecoration(labelText: "Gravida (G)"),
                  items: ["0", "1", "2", "3+"].map((val) {
                    return DropdownMenuItem<String>(
                        value: val, child: Text(val));
                  }).toList(),
                  onChanged: (value) => setState(() => gravida = value),
                ),
                DropdownButtonFormField<String>(
                  value: para,
                  decoration: const InputDecoration(labelText: "Para (P)"),
                  items: ["0", "1", "2", "3+"].map((val) {
                    return DropdownMenuItem<String>(
                        value: val, child: Text(val));
                  }).toList(),
                  onChanged: (value) => setState(() => para = value),
                ),
                DropdownButtonFormField<String>(
                  value: abortus,
                  decoration: const InputDecoration(labelText: "Abortus (A)"),
                  items: ["0", "1", "2", "3+"].map((val) {
                    return DropdownMenuItem<String>(
                        value: val, child: Text(val));
                  }).toList(),
                  onChanged: (value) => setState(() => abortus = value),
                ),
                TextField(
                  controller: keluhanController,
                  decoration:
                      const InputDecoration(labelText: "Keluhan Saat Ini"),
                  maxLines: 2,
                ),
                TextField(
                  controller: riwayatPenyakitController,
                  decoration: const InputDecoration(
                      labelText: "Riwayat Penyakit dalam Kehamilan"),
                  maxLines: 2,
                ),
                TextField(
                  controller: riwayatAlergiController,
                  decoration:
                      const InputDecoration(labelText: "Riwayat Alergi"),
                  maxLines: 2,
                ),
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
                  "tanggal_periksa": tanggalPeriksaController.text,
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
                  await _dataKehamilan.add(formData);
                } else {
                  await _dataKehamilan.doc(docId).update(formData);
                }

                Navigator.pop(context);
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
        title: const Text("Data Kehamilan"),
        backgroundColor: const Color(0xFFD81B60),
      ),
      body: StreamBuilder(
        stream: _dataKehamilan.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan"));
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
                          const Icon(Icons.female, color: Colors.pink),
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
                      Text("Tanggal Periksa: ${docData["tanggal_periksa"]}"),
                      Text(
                          "Usia Kehamilan: ${docData["usia_kehamilan"]} Minggu"),
                      Text(
                          "Taksiran Persalinan: ${docData["taksiran_persalinan"]}"),
                      Text("Gravida (G): ${docData["gravida"]}"),
                      Text("Para (P): ${docData["para"]}"),
                      Text("Abortus (A): ${docData["abortus"]}"),
                      Text("Keluhan: ${docData["keluhan"]}"),
                      Text("Riwayat Penyakit: ${docData["riwayat_penyakit"]}"),
                      Text("Riwayat Alergi: ${docData["riwayat_alergi"]}"),
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
