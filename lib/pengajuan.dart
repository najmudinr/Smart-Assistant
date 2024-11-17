import 'package:flutter/material.dart';

class PengajuanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Daftar Disposisi AVP',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text('Tanggal'),
                    ),
                    DataColumn(
                      label: Text('Keterangan Disposisi'),
                    ),
                    DataColumn(
                      label: Text('Tujuan'),
                    ),
                    DataColumn(
                      label: Text('Surat'),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    10,
                    (int index) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text('1 Juli 2024')),
                        DataCell(Text(
                            index == 0 ? 'Mengikuti Kegiatan A' : 'Shift 1')),
                        DataCell(Text('Rifky Isyarah')),
                        DataCell(Text(index == 0
                            ? '111/09203/PG/2024'
                            : 'Gudang Multiguna 1')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Aksi untuk tombol tambah disposisi
          },
          backgroundColor: Colors.orange,
          icon: Icon(Icons.add),
          label: Text("Tambah Disposisi"),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
