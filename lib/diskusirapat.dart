import 'package:flutter/material.dart';
import 'package:smartassistant/detaildiskusirapat.dart';

class DiskusiRapatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Daftar Diskusi Rapat'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16),
            // List of discussion cards
            Expanded(
              child: ListView.builder(
                itemCount: 4, // Number of discussion cards
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rapat Bagian Gudang III',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Tanggal Pelaksanaan: 02 Agustus 2024'),
                            Row(
                              children: [
                                Text('Status: '),
                                Text(
                                  'In Progress',
                                  style: TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                            Text('Team Leader: Eri Pras'),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DetailDiskusiRapatPage()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.orange[200],
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Lihat Detail',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating action button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aksi ketika tombol 'Tambah Rapat' ditekan
        },
        backgroundColor: Colors.orange,
        icon: Icon(Icons.add),
        label: Text('Tambah Rapat'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
