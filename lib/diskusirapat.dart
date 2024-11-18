import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartassistant/detaildiskusirapat.dart';
import 'package:smartassistant/tambahdiskusirapat.dart';

class DiskusiRapatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Daftar Diskusi Rapat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            // List of discussion cards
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rapat') // Nama koleksi di Firestore
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Tidak ada diskusi rapat.'));
                  }

                  final data = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final rapat = data[index];
                      final rapatId = rapat.id; // ID dokumen
                      final rapatData = rapat.data() as Map<String, dynamic>;

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
                                  rapatData['topic'] ?? 'Judul tidak tersedia',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'Tanggal Pelaksanaan: ${rapatData['date'] ?? 'Tanggal tidak tersedia'}'),
                                // Row(
                                //   children: [
                                //     const Text('Status: '),
                                //     Text(
                                //       rapatData['status'] ?? 'Status tidak tersedia',
                                //       style: const TextStyle(color: Colors.orange),
                                //     ),
                                //   ],
                                // ),
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users') // Nama koleksi pengguna
                                      .doc(rapatData['teamLeaderId'])
                                      .get(),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text('Memuat...');
                                    }

                                    if (!userSnapshot.hasData ||
                                        !userSnapshot.data!.exists) {
                                      return const Text(
                                          'Team Leader: Tidak tersedia');
                                    }

                                    final userData = userSnapshot.data!.data()
                                        as Map<String, dynamic>;

                                    return Text(
                                      'Team Leader: ${userData['name'] ?? 'Tidak tersedia'}',
                                    );
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailDiskusiRapatPage(
                                            rapatId: rapatId, // Kirim ID rapat
                                            currentUserRole: '',
                                          ),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.orange[200],
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
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
          Navigator.push(context, 
          MaterialPageRoute(builder: (context) => TambahDiskusiPage()));
          // Aksi ketika tombol 'Tambah Rapat' ditekan
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Rapat'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
