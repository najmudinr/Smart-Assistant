import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailIQCPage extends StatelessWidget {
  final String documentId;

  const DetailIQCPage({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail IQC'),
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('iqc_data') // Pastikan nama koleksi sesuai
              .doc(documentId) // Gunakan ID dokumen
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Data tidak ditemukan.'));
            }

            // Mengambil data dokumen
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final List<dynamic> samplingData = data['sampling_data'] ?? [];
            final String userId = data['user_id'] ?? '';

            // Hitung jumlah sampling
            final int jumlahSampling = samplingData.length;

            // Hitung jumlah On Spec dan Off Spec
            final int jumlahOnSpec = samplingData
                .where((item) => item['keterangan'] == 'On Spec')
                .length;
            final int jumlahOffSpec = samplingData
                .where((item) => item['keterangan'] == 'Off Spec')
                .length;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users') // Koleksi Users
                  .doc(userId) // Dokumen berdasarkan user_id
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }

                // Ambil nama user jika data ada
                final userData = userSnapshot.data != null
                    ? userSnapshot.data!.data() as Map<String, dynamic>
                    : null;
                final String checkerName = userData?['name'] ?? 'Unknown';

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LAPORAN IQC',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Checker: $checkerName'),
                            Text('Shift: ${data['shift'] ?? 'N/A'}'),
                            Text(
                                'Nama Produk: ${data['nama_produk'] ?? 'N/A'}'),
                            Text(
                                'Jumlah Produk: ${data['jumlah_produk'] ?? 'N/A'}'),
                            Text(
                                'Asal Produk: ${data['asal_produk'] ?? 'N/A'}'),
                            Text('No PO: ${data['no_po'] ?? 'N/A'}'),
                            Text('Jumlah Sampling: $jumlahSampling'),
                            Text('Sampling On Spec: $jumlahOnSpec'),
                            Text('Sampling Off Spec: $jumlahOffSpec'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('No')),
                              DataColumn(label: Text('Kuantum')),
                              DataColumn(label: Text('Keterangan')),
                            ],
                            rows: List<DataRow>.generate(
                              samplingData.length,
                              (index) {
                                final item = samplingData[index];
                                final String kuantum =
                                    item['sampling'].toString();
                                final String keterangan =
                                    item['keterangan'] ?? 'N/A';

                                return DataRow(
                                  cells: [
                                    DataCell(Text('${index + 1}')),
                                    DataCell(Text(kuantum)),
                                    DataCell(Text(keterangan)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
