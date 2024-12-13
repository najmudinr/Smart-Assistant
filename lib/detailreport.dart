import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailReportPage extends StatelessWidget {
  final String documentId;

  const DetailReportPage({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    print("Document ID: $documentId");
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Report"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports') // Ganti sesuai nama koleksi Anda
            .doc(documentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.data() == null) {
            return const Center(
              child: Text("Data tidak tersedia atau dokumen tidak ditemukan."),
            );
          }

          // Ambil data dari snapshot
          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Ambil data dari Firestore fields
          final gudang = data['gudang'] ?? 'Gudang Tidak Tersedia';
          final foreman = data['foreman'] ?? 'Foreman Tidak Tersedia';
          final jamMulai = data['jamMulai'] ?? 'N/A';
          final jamSelesai = data['jamSelesai'] ?? 'N/A';
          final tanggal = data['tanggal'] ?? 'N/A';
          final produkList = data['produkList'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Report Antrian Truk",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Foreman : $foreman"),
                  Text("Tanggal: $tanggal"),
                  Text("Jam Mulai: $jamMulai - Jam Selesai: $jamSelesai"),
                  Text("Gudang: $gudang"),
                  SizedBox(height: 16),
                  Text(
                    "Antrian Truk Muat Akhir Shift:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[300]),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Produk", textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Awal", textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Masuk", textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child:
                                Text("Terlayani", textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Sisa", textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                      // Generate rows from produkList
                      for (var produk in produkList)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(produk['produk'] ?? '-'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text((produk['awal'] ?? 0).toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text((produk['masuk'] ?? 0).toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Text((produk['terlayani'] ?? 0).toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text((produk['sisa'] ?? 0).toString()),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
