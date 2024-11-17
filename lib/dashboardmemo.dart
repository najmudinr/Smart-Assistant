import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'tambahmemo.dart';
import 'editmemo.dart';

class MemoDashboardPage extends StatefulWidget {
  @override
  _MemoDashboardPageState createState() => _MemoDashboardPageState();
}

class _MemoDashboardPageState extends State<MemoDashboardPage> {
  bool _canAddMemo = false;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userSnapshot.exists) {
        String userRole = userSnapshot['roles'];
        setState(() {
          // FAB hanya muncul untuk Admin Bagian dan Admin Seksi
          _canAddMemo = userRole == 'Admin Bagian' || userRole == 'Admin Seksi';
        });
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    return DateFormat('dd MMM yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Rekap Memo Internal'),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('internal_memos')
            .orderBy('submission_date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Tidak ada memo saat ini."));
          }

          final memos = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 1400),
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Nomor Memo')),
                  DataColumn(label: Text('Pembuat Memo')),
                  DataColumn(label: Text('Asal Memo')),
                  DataColumn(label: Text('Tujuan Memo')),
                  DataColumn(label: Text('Perihal Pengajuan')),
                  DataColumn(label: Text('Tanggal Pengajuan')),
                  DataColumn(label: Text('Tanggal Pengiriman ke AVP')),
                  DataColumn(label: Text('Tanggal Diterima ke AVP')),
                  DataColumn(label: Text('Tanggal Pengiriman ke VP')),
                  DataColumn(label: Text('Tanggal Diterima VP')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Tindak Lanjut')),
                  DataColumn(label: Text('PIC Terkait')),
                  DataColumn(label: Text('Keterangan')),
                  DataColumn(label: Text('Aksi')), // Kolom tambahan untuk aksi
                ],
                rows: memos.map((memo) {
                  return DataRow(cells: [
                    DataCell(Text(memo['memo_number'] ?? '-')),
                    DataCell(Text(memo['creator'] ?? '-')),
                    DataCell(Text(memo['origin'] ?? '-')),
                    DataCell(Text(memo['destination'] ?? '-')),
                    DataCell(Text(memo['subject'] ?? '-')),
                    DataCell(Text(_formatTimestamp(memo['submission_date']))),
                    DataCell(Text(_formatTimestamp(memo['avp_send_date']))),
                    DataCell(Text(_formatTimestamp(memo['avp_received_date']))),
                    DataCell(Text(_formatTimestamp(memo['vp_send_date']))),
                    DataCell(Text(_formatTimestamp(memo['vp_received_date']))),
                    DataCell(Text(memo['status'] ?? '-')),
                    DataCell(Text(memo['follow_up'] ?? '-')),
                    DataCell(
                      Text(
                        memo['related_pic'] is List
                            ? (memo['related_pic'] as List).join(', ')
                            : (memo['related_pic'] ?? '-'),
                      ),
                    ),
                    DataCell(
                      Text(
                        memo['notes'] is List
                            ? (memo['notes'] as List).join(', ')
                            : (memo['notes'] ?? '-'),
                      ),
                    ),
                    // DataCell(
                    //   memo['document_archive'] != null &&
                    //           memo['document_archive'].isNotEmpty
                    //       ? GestureDetector(
                    //           onTap: () {
                    //             // Buka URL dokumen menggunakan browser default
                    //             _openDocument(memo['document_archive']);
                    //           },
                    //           child: Text(
                    //             'Lihat Dokumen',
                    //             style: TextStyle(
                    //               color: Colors.blue,
                    //               decoration: TextDecoration.underline,
                    //             ),
                    //           ),
                    //         )
                    //       : Text('-'),
                    // ), // Tombol Edit di kolom aksi
                    DataCell(
                      _canAddMemo
                          ? IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditMemoPage(memoId: memo.id),
                                  ),
                                );
                              },
                            )
                          : SizedBox.shrink(),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: _canAddMemo
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMemoPage()),
                );
              },
              backgroundColor: Colors.orange,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

//   void _openDocument(String url) async {
//     Uri documentUri = Uri.parse(url);
//     try {
//       if (await canLaunchUrl(documentUri)) {
//         await launchUrl(documentUri, mode: LaunchMode.externalApplication);
//       } else {
//         throw 'Tidak dapat membuka dokumen: $url';
//       }
//     } catch (e) {
//       print('Error membuka dokumen: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Gagal membuka dokumen')),
//       );
//     }
//   }
// }
