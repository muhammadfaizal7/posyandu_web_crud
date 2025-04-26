import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RiwayatVaksinPage extends StatelessWidget {
  const RiwayatVaksinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference _jadwalVaksinCollection =
        FirebaseFirestore.instance.collection("jadwal_vaksin");

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text("Riwayat Vaksin"),
        backgroundColor: const Color(0xFFD81B60),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _jadwalVaksinCollection
            .where("status_vaksin", isEqualTo: "Sudah")
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("Belum ada riwayat vaksin",
                    style: TextStyle(color: Colors.grey)));
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              String posyandu = data["posyandu"] ?? "Tidak ada data";
              String jenisVaksin = data["jenis_vaksin"] ?? "Tidak ada data";
              Timestamp? tanggalVaksin = data["tanggal_vaksin"];
              String formattedDate = tanggalVaksin != null
                  ? DateFormat('dd MMM yyyy, HH:mm')
                      .format(tanggalVaksin.toDate())
                  : "Tidak ada tanggal";

              return Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.greenAccent,
                        child: Icon(Icons.check_circle,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(posyandu,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Jenis Vaksin: $jenisVaksin",
                                style: const TextStyle(fontSize: 14)),
                            Text("Tanggal: $formattedDate",
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
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
