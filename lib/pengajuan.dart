import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartassistant/editpengajuan.dart';
import 'package:url_launcher/url_launcher.dart';

class PengajuanPage extends StatefulWidget {
  const PengajuanPage({super.key});

  @override
  _PengajuanPageState createState() => _PengajuanPageState();
}

class _PengajuanPageState extends State<PengajuanPage> {
  // String? _userRole;

  @override
  void initState() {
    super.initState();
    // _getUserRole();
  }

  // Future<void> _getUserRole() async {
  //   User? currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUser.uid)
  //         .get();
  //     if (userSnapshot.exists) {
  //       setState(() {
  //         _userRole = userSnapshot['roles'];
  //       });
  //     }
  //   }
  // }

  Future<List<Map<String, dynamic>>> _fetchSubmissions() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      // Query submissions
      final receivedSnapshot = await FirebaseFirestore.instance
          .collection('submissions')
          .where('targetUserId', isEqualTo: currentUser.uid)
          .get();

      final sentSnapshot = await FirebaseFirestore.instance
          .collection('submissions')
          .where('submittedBy', isEqualTo: currentUser.uid)
          .get();

      final submissions = [
        ...receivedSnapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }),
        ...sentSnapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }),
      ];

      // Get all unique user IDs for mapping names
      final userIds = {
        ...submissions.map((s) => s['submittedBy']),
        ...submissions.map((s) => s['targetUserId']),
      }.where((id) => id != null).toSet();

      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds.toList())
          .get();

      // Map user IDs to names
      final userIdToName = {
        for (var doc in userDocs.docs)
          doc.id: doc.data()['name'] ?? 'Tidak diketahui',
      };

      // Add user names to submissions
      return submissions.map((submission) {
        return {
          ...submission,
          'submittedByName': userIdToName[submission['submittedBy']],
          'targetUserName': userIdToName[submission['targetUserId']],
        };
      }).toList();
    } catch (e) {
      print('Error fetching submissions: $e');
      return [];
    }
  }

  Future<void> _updateSubmissionStatus(String submissionId, String status,
      {String? reason}) async {
    try {
      final data = {
        'status': status,
        if (reason != null) 'reason': reason, // Simpan alasan jika ada
      };
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(submissionId)
          .update(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status pengajuan diperbarui menjadi $status.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status pengajuan.')),
      );
    }
  }

  Future<void> _showReturnDialog(String submissionId) async {
    final TextEditingController reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alasan Pengembalian'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Masukkan alasan pengembalian',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                _updateSubmissionStatus(submissionId, 'dikembalikan',
                    reason: reason);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Alasan pengembalian tidak boleh kosong.')),
                );
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'disetujui':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      case 'dikembalikan':
        return Icons.undo;
      default:
        return Icons.hourglass_empty;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'dikembalikan':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengajuan'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSubmissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('Terjadi kesalahan saat memuat data'));
          }

          final submissions = snapshot.data ?? [];

          if (submissions.isEmpty) {
            return const Center(
              child: Text('Tidak ada pengajuan untuk ditampilkan.'),
            );
          }

          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              final currentUser = FirebaseAuth.instance.currentUser;

              // Periksa apakah pengguna saat ini adalah penerima
              final isReceiver = submission['targetUserId'] == currentUser?.uid;

              // Periksa apakah pengajuan dikembalikan
              final isSender = submission['submittedBy'] == currentUser?.uid;
              final isReturned = submission['status'] == 'dikembalikan';

              print('Submission ID: ${submission['id']}');
              print('isSender: $isSender');
              print('isReturned: $isReturned');

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission['title'] ?? 'Judul tidak tersedia',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(submission['description'] ??
                          'Deskripsi tidak tersedia'),
                      const SizedBox(height: 10),
                      Text(
                        'Dikirim Oleh: ${submission['submittedByName'] ?? 'Tidak diketahui'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Diterima Oleh: ${submission['targetUserName'] ?? 'Tidak diketahui'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        children: [
                          Icon(
                            _getStatusIcon(submission['status']),
                            color: _getStatusColor(submission['status']),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Status: ${submission['status'] ?? 'Belum diproses'}',
                            style: TextStyle(
                              color: _getStatusColor(submission['status']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isReturned)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Alasan Pengembalian: ${submission['reason'] ?? 'Tidak ada alasan'}',
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          if (submission['documentUrl'] != null)
                            TextButton(
                              onPressed: () {
                                launchUrl(Uri.parse(submission['documentUrl']));
                              },
                              child: const Text(
                                'Lihat Dokumen',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          const SizedBox(height: 10),
                          if (isReceiver)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _updateSubmissionStatus(
                                        submission['id'], 'disetujui');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Terima'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    _showReturnDialog(submission['id']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text('Kembalikan'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    _updateSubmissionStatus(
                                        submission['id'], 'ditolak');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Tolak'),
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          if (isSender && isReturned)
                            ElevatedButton(
                              onPressed: () {
                                print(
                                    'Navigating to EditSubmissionPage for Submission ID: ${submission['id']}');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditSubmissionPage(
                                        submissionId: submission['id']),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Edit Pengajuan'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
