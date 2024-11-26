import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartassistant/detailiqc.dart';
import 'package:smartassistant/tambahiqc.dart';

class IQCPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IQC',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('iqc_data').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Tidak ada data tersedia.'));
          }

          // Mengambil data dari Firestore
          final data = snapshot.data!.docs;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Berikut ini adalah data Quality Control di Area III',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20.0,
                    columns: [
                      DataColumn(label: Text('No')),
                      DataColumn(label: Text('Tanggal')),
                      DataColumn(label: Text('Shift')),
                      DataColumn(label: Text('Nama Produk')),
                      DataColumn(label: Text('Jumlah Produk (Ton)')),
                      DataColumn(label: Text('Asal Produk')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(
                      data.length,
                      (index) {
                        final item = data[index];
                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(item['tanggal'] ?? '')),
                            DataCell(Text(item['shift'] ?? '')),
                            DataCell(Text(item['nama_produk'] ?? '')),
                            DataCell(Text(item['jumlah_produk'] ?? '')),
                            DataCell(Text(item['asal_produk'] ?? '')),
                            DataCell(
                              IconButton(
                                icon:
                                    Icon(Icons.more_vert, color: Colors.orange),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailIQCPage(
                                                documentId: item.id,
                                              )));
                                  // Tambahkan aksi untuk setiap data di sini
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahIQCPage()),
          );
        },
        label: Text('Tambah Laporan'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
