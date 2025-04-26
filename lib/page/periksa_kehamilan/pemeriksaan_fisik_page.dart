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
    await _pemeriksaanFisik.doc(docId).delete();
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
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            docId == null
                ? "Tambah Pemeriksaan Fisik"
                : "Edit Pemeriksaan Fisik",
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
                    controller: beratBadanController,
                    decoration:
                        const InputDecoration(labelText: "Berat Badan (kg)")),
                TextField(
                    controller: tinggiBadanController,
                    decoration:
                        const InputDecoration(labelText: "Tinggi Badan (cm)")),
                TextField(
                    controller: tekananDarahController,
                    decoration: const InputDecoration(
                        labelText: "Tekanan Darah (mmHg)")),
                TextField(
                    controller: lingkarLenganController,
                    decoration: const InputDecoration(
                        labelText: "Lingkar Lengan Atas (cm)")),
                TextField(
                    controller: tinggiFundusController,
                    decoration: const InputDecoration(
                        labelText: "Tinggi Fundus Uteri (cm)")),
                TextField(
                    controller: denyutJantungController,
                    decoration: const InputDecoration(
                        labelText: "Denyut Jantung Janin (bpm)")),
                TextField(
                    controller: letakJaninController,
                    decoration:
                        const InputDecoration(labelText: "Letak Janin")),
                TextField(
                    controller: gerakanJaninController,
                    decoration:
                        const InputDecoration(labelText: "Gerakan Janin")),
                TextField(
                    controller: edemaController,
                    decoration:
                        const InputDecoration(labelText: "Edema (Bengkak)")),
                TextField(
                    controller: proteinUrinController,
                    decoration:
                        const InputDecoration(labelText: "Protein Urin")),
                TextField(
                    controller: gulaUrinController,
                    decoration: const InputDecoration(labelText: "Gula Urin")),
              ],
            ),
          ),
          actions: [
            TextButton(
                child: const Text("Batal"),
                onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              child: Text(docId == null ? "Simpan" : "Update"),
              onPressed: () async {
                Map<String, dynamic> formData = {
                  "nik": selectedNIK,
                  "nama": selectedNama,
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
                  await _pemeriksaanFisik.add(formData);
                } else {
                  await _pemeriksaanFisik.doc(docId).update(formData);
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
        title: const Text("Pemeriksaan Fisik"),
        backgroundColor: const Color(0xFFD81B60),
      ),
      body: StreamBuilder(
        stream: _pemeriksaanFisik.snapshots(),
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
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${docData["nama"]} (NIK: ${docData["nik"]})",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Text("🔹 Berat Badan: ${docData["berat_badan"]} kg"),
                      Text("🔹 Tinggi Badan: ${docData["tinggi_badan"]} cm"),
                      Text(
                          "🔹 Tekanan Darah: ${docData["tekanan_darah"]} mmHg"),
                      Text(
                          "🔹 Lingkar Lengan: ${docData["lingkar_lengan"]} cm"),
                      Text(
                          "🔹 Tinggi Fundus Uteri: ${docData["tinggi_fundus"]} cm"),
                      Text(
                          "🔹 Denyut Jantung Janin: ${docData["denyut_jantung"]} bpm"),
                      Text("🔹 Letak Janin: ${docData["letak_janin"]}"),
                      Text("🔹 Gerakan Janin: ${docData["gerakan_janin"]}"),
                      Text("🔹 Edema: ${docData["edema"]}"),
                      Text("🔹 Protein Urin: ${docData["protein_urin"]}"),
                      Text("🔹 Gula Urin: ${docData["gula_urin"]}"),
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
