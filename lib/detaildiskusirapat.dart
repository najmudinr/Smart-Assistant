// File path: lib/pages/detail_diskusi_rapat_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailDiskusiRapatPage extends StatelessWidget {
  final String rapatId;
  final String currentUserRole;

  const DetailDiskusiRapatPage({
    super.key,
    this.rapatId = '',
    this.currentUserRole = '',
  });

  Future<List<Map<String, dynamic>>> _fetchParticipantDetails(
      List<dynamic> participants) async {
    List<Map<String, dynamic>> participantDetails = [];

    for (var participantId in participants) {
      if (participantId is String) {
        try {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(participantId)
              .get();

          if (userSnapshot.exists) {
            participantDetails.add({
              'id': participantId,
              'name': userSnapshot['name'] ?? 'Unknown',
            });
          } else {
            participantDetails.add({'id': participantId, 'name': 'Unknown'});
          }
        } catch (e) {
          participantDetails
              .add({'id': participantId, 'name': 'Error Fetching Data'});
        }
      }
    }

    return participantDetails;
  }

  @override
  Widget build(BuildContext context) {
    // final TextEditingController teamLeaderNoteController =
    //     TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId =
        currentUser?.uid ?? ''; // Jika null, beri default kosong

    print('currentUserId: $currentUserId');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Detail Diskusi Rapat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('rapat').doc(rapatId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return const Center(child: Text('Data rapat tidak ditemukan.'));
          }

          final rapatData = snapshot.data!.data() as Map<String, dynamic>;
          final participants =
              rapatData['participants'] as List<dynamic>? ?? [];
          final teamLeaderId = rapatData['teamLeaderId'] ?? '';

          // Debug Print for teamLeaderId and currentUserId
          print('teamLeaderId: $teamLeaderId');
          print('currentUserId: $currentUserId');

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tema diskusi
                  Text(
                    'Tema diskusi: ${rapatData['topic'] ?? 'Tidak tersedia'}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Tanggal Pelaksanaan: ${rapatData['date'] ?? 'Tidak tersedia'}'),
                  const SizedBox(height: 16),

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

                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const Text('Team Leader: Tidak tersedia');
                      }

                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;

                      return Text(
                        'Team Leader: ${userData['name'] ?? 'Tidak tersedia'}',
                      );
                    },
                  ),

                  // Peserta
                  Text(
                    'Peserta:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  participants.isEmpty
                      ? const Text('Tidak ada peserta.')
                      : FutureBuilder<List<Map<String, dynamic>>>(
                          future: _fetchParticipantDetails(participants),
                          builder: (context, participantSnapshot) {
                            if (participantSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            if (!participantSnapshot.hasData ||
                                participantSnapshot.data!.isEmpty) {
                              return const Text('Data peserta tidak valid.');
                            }

                            final participantDetails =
                                participantSnapshot.data!;
                            return Wrap(
                              spacing: 8,
                              children:
                                  participantDetails.map<Widget>((participant) {
                                return Chip(
                                  label: Text(participant['name'] ?? 'Unknown'),
                                );
                              }).toList(),
                            );
                          },
                        ),

                  const SizedBox(height: 16),
                                    // Judul "Penyampaian Team Leader"
                  const Text(
                    'Penyampaian Team Leader:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  

                  if (rapatData['teamLeaderNotes'] != null)
                    Column(
                      children: (rapatData['teamLeaderNotes'] as List<dynamic>)
                          .map((note) {
                        // Jika note adalah string, gunakan langsung
                        final TextEditingController noteController =
                            TextEditingController(text: note);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          child: ListTile(
                            title: TextField(
                              controller: noteController,
                              decoration: InputDecoration(
                                hintText: 'Edit arahan...',
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.save,
                                      color: Colors.green),
                                  onPressed: () async {
                                    try {
                                      // Update logic for string type
                                      await FirebaseFirestore.instance
                                          .collection('rapat')
                                          .doc(rapatId)
                                          .update({
                                        'teamLeaderNotes':
                                            FieldValue.arrayRemove([note]),
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('rapat')
                                          .doc(rapatId)
                                          .update({
                                        'teamLeaderNotes':
                                            FieldValue.arrayUnion(
                                                [noteController.text]),
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Arahan berhasil diperbarui.')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Gagal memperbarui arahan: $e')),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('rapat')
                                          .doc(rapatId)
                                          .update({
                                        'teamLeaderNotes':
                                            FieldValue.arrayRemove([note]),
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Arahan berhasil dihapus.')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Gagal menghapus arahan: $e')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text('Belum ada arahan yang ditambahkan.'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
