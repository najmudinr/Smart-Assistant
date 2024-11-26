import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailDiskusiRapatPage extends StatelessWidget {
  final String rapatId;
  final String currentUserRole;

  const DetailDiskusiRapatPage({
    super.key,
    required this.rapatId,
    required this.currentUserRole,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? '';

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('rapat').doc(rapatId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return const Center(child: Text('Data rapat tidak ditemukan.'));
          }

          final rapatData = snapshot.data!.data() as Map<String, dynamic>;
          final teamLeaderId = rapatData['teamLeaderId'] ?? '';
          final participants = rapatData['participants'] as List<dynamic>? ?? [];
          final teamLeaderNotes = rapatData['teamLeaderNotes'] as List<dynamic>? ?? [];
          final participantNotes = rapatData['participantNotes'] as List<dynamic>? ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema diskusi: ${rapatData['topic'] ?? 'Tidak tersedia'}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Tanggal Pelaksanaan: ${rapatData['date'] ?? 'Tidak tersedia'}'),
                  const SizedBox(height: 16),

                  _buildTeamLeaderInfo(context, teamLeaderId),
                  const SizedBox(height: 16),

                  const Text(
                    'Peserta:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  participants.isEmpty
                      ? const Text('Tidak ada peserta.')
                      : _buildParticipants(participants),

                  const SizedBox(height: 16),
                  const Text(
                    'Penyampaian Team Leader:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  if (currentUserId == teamLeaderId) ...[
                    _buildAddNoteSection(context, rapatId),
                    const SizedBox(height: 16),
                  ],
                  teamLeaderNotes.isEmpty
                      ? const Text('Belum ada arahan yang ditambahkan.')
                      : _buildTeamLeaderNotes(context, rapatId, teamLeaderNotes, currentUserId, teamLeaderId),

                  const SizedBox(height: 16),
                  const Text(
                    'Penyampaian Peserta Rapat:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  _buildAddParticipantNoteSection(context, rapatId),
                  participantNotes.isEmpty
                      ? const Text('Belum ada penyampaian peserta.')
                      : _buildParticipantNotes(context, participantNotes, currentUserId, teamLeaderId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticipantNotes(
    BuildContext context,
    List<dynamic> participantNotes,
    String currentUserId,
    String teamLeaderId,
  ) {
    return Column(
      children: participantNotes.map((entry) {
        final String userId = entry['userId'] ?? 'Unknown';
        final String note = entry['note'] ?? 'Tidak ada penyampaian.';
        final String? leaderResponse = entry['leaderResponse'];
        final TextEditingController responseController = TextEditingController();

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final userName = userSnapshot.data?['name'] ?? 'Tidak diketahui';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(note),
                    subtitle: Text('Peserta: $userName'),
                  ),
                  if (leaderResponse != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Tanggapan Leader: $leaderResponse',
                        style: const TextStyle(color: Colors.green, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  if (currentUserId == teamLeaderId) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: responseController,
                            decoration: const InputDecoration(
                              labelText: 'Tambah tanggapan untuk peserta...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final response = responseController.text.trim();
                              if (response.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tanggapan tidak boleh kosong.')),
                                );
                                return;
                              }
                              try {
                                // Update tanggapan di Firestore
                                await FirebaseFirestore.instance
                                    .collection('rapat')
                                    .doc(rapatId)
                                    .update({
                                  'participantNotes': FieldValue.arrayRemove([entry]),
                                });
                                await FirebaseFirestore.instance
                                    .collection('rapat')
                                    .doc(rapatId)
                                    .update({
                                  'participantNotes': FieldValue.arrayUnion([
                                    {...entry, 'leaderResponse': response}
                                  ]),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tanggapan berhasil ditambahkan.')),
                                );
                                responseController.clear();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal menambahkan tanggapan: $e')),
                                );
                              }
                            },
                            child: const Text('Tambah Tanggapan'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildAddParticipantNoteSection(BuildContext context, String rapatId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final TextEditingController noteController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tambah Penyampaian Anda:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Masukkan penyampaian Anda...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final note = noteController.text.trim();
            if (note.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Penyampaian tidak boleh kosong.')),
              );
              return;
            }
            try {
              await FirebaseFirestore.instance
                  .collection('rapat')
                  .doc(rapatId)
                  .update({
                'participantNotes': FieldValue.arrayUnion([
                  {'userId': currentUser?.uid, 'note': note}
                ]),
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Penyampaian berhasil ditambahkan.')),
              );
              noteController.clear();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal menambahkan penyampaian: $e')),
              );
            }
          },
          child: const Text('Tambah Penyampaian'),
        ),
      ],
    );
  }

  Widget _buildTeamLeaderInfo(BuildContext context, String teamLeaderId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(teamLeaderId)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Text('Memuat...');
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Text('Team Leader: Tidak tersedia');
        }
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        return Text('Team Leader: ${userData['name'] ?? 'Tidak tersedia'}');
      },
    );
  }

  Widget _buildParticipants(List<dynamic> participants) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchParticipantDetails(participants),
      builder: (context, participantSnapshot) {
        if (participantSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!participantSnapshot.hasData || participantSnapshot.data!.isEmpty) {
          return const Text('Data peserta tidak valid.');
        }
        final participantDetails = participantSnapshot.data!;
        return Wrap(
          spacing: 8,
          children: participantDetails.map((participant) {
            return Chip(label: Text(participant['name'] ?? 'Unknown'));
          }).toList(),
        );
      },
    );
  }

  Widget _buildAddNoteSection(BuildContext context, rapatId) {
    final TextEditingController newNoteController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tambah Arahan Baru:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: newNoteController,
          decoration: const InputDecoration(
            hintText: 'Masukkan arahan baru...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final newNote = newNoteController.text.trim();
            if (newNote.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(content: Text('Arahan tidak boleh kosong.')),
              );
              return;
            }
            try {
              await FirebaseFirestore.instance
                  .collection('rapat')
                  .doc(rapatId)
                  .update({
                'teamLeaderNotes': FieldValue.arrayUnion([newNote]),
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Arahan berhasil ditambahkan.')),
              );
              newNoteController.clear();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal menambahkan arahan: $e')),
              );
            }
          },
          child: const Text('Tambah Arahan'),
        ),
      ],
    );
  }

  Widget _buildTeamLeaderNotes(
    BuildContext context,
    String rapatId,
    List<dynamic> teamLeaderNotes,
    String currentUserId,
    String teamLeaderId,
  ) {
    return Column(
      children: teamLeaderNotes.map((note) {
        final TextEditingController noteController =
            TextEditingController(text: note);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          child: ListTile(
            title: TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'Edit arahan...',
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.green),
                  onPressed: () async {
                    // Validasi Role
                    if (currentUserId != teamLeaderId) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Hanya Team Leader yang dapat menyimpan arahan.'),
                        ),
                      );
                      return;
                    }
                    try {
                      await FirebaseFirestore.instance
                          .collection('rapat')
                          .doc(rapatId)
                          .update({
                        'teamLeaderNotes': FieldValue.arrayRemove([note]),
                      });
                      await FirebaseFirestore.instance
                          .collection('rapat')
                          .doc(rapatId)
                          .update({
                        'teamLeaderNotes':
                            FieldValue.arrayUnion([noteController.text]),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Arahan berhasil diperbarui.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal memperbarui arahan: $e')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Validasi Role
                    if (currentUserId != teamLeaderId) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Hanya Team Leader yang dapat menghapus arahan.'),
                        ),
                      );
                      return;
                    }
                    try {
                      await FirebaseFirestore.instance
                          .collection('rapat')
                          .doc(rapatId)
                          .update({
                        'teamLeaderNotes': FieldValue.arrayRemove([note]),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Arahan berhasil dihapus.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menghapus arahan: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchParticipantDetails(
      List<dynamic> participantIds) async {
    final participants = <Map<String, dynamic>>[];
    for (final participantId in participantIds) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(participantId)
          .get();
      if (doc.exists) {
        participants.add(doc.data() as Map<String, dynamic>);
      }
    }
    return participants;
  }
}