import 'package:flutter/material.dart';
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
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Berikut ini adalah data Quality Control di Area III',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Tabel Data
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Shift')),
                  DataColumn(label: Text('Nama Produk')),
                  DataColumn(label: Text('Jumlah Produk')),
                  DataColumn(label: Text('Asal Produk')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: List<DataRow>.generate(
                  10, // Ganti dengan jumlah data yang diinginkan
                  (index) => DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text('1/10/2024')),
                      DataCell(Text('Shift 1')),
                      DataCell(Text('PETROGANIK PREMIUM 40 KG')),
                      DataCell(Text('40 Ton')),
                      DataCell(Text('CV. ABCD')),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.more_vert, color: Colors.orange),
                          onPressed: () {
                            // Tambahkan aksi disini
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Informasi pagination
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Showing 1 to 10 of 121 entries',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Pagination control
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.chevron_left),
                ),
                Row(
                  children: List.generate(
                    5, // Jumlah halaman dalam pagination
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: index == 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.chevron_right),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      // Tombol Tambah Laporan
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahIQCPage()),
          );
          // Aksi untuk menambah laporan
        },
        label: Text('Tambah Laporan'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
      // Bottom Navigation Bar
    );
  }
}
