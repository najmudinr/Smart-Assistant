import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPenugasan extends StatefulWidget {
  final Map<String, dynamic> taskData;
  final String currentUserId;
  final String currentUserRole;

  const DetailPenugasan({
    required this.taskData,
    required this.currentUserId,
    required this.currentUserRole,
    super.key,
  });

  @override
  State<DetailPenugasan> createState() => _DetailPenugasanState();
}

class _DetailPenugasanState extends State<DetailPenugasan> {
  Future<String> _getUserName(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        String name = userDoc['name'] ?? 'Unknown';
        return _getInitials(name);
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
    return 'U'; // Default inisial jika gagal
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.isEmpty) return 'U'; // Default jika nama kosong
    return nameParts
        .map((part) => part.isNotEmpty ? part[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  void showFollowUpDialog(
      BuildContext context, String? taskId, String? creator) {
    if (taskId == null || creator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Data tugas tidak valid: Task ID atau Creator ID kosong."),
        ),
      );
      return;
    }

    final TextEditingController activityController = TextEditingController();
    final List<String> activityList = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Ajukan Rencana Aktivitas Tindak Lanjut"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input Field
                    TextField(
                      controller: activityController,
                      decoration: InputDecoration(
                        labelText: "Rencana Aktivitas",
                        hintText: "Masukkan aktivitas...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Add Button
                    ElevatedButton.icon(
                      onPressed: () {
                        if (activityController.text.trim().isNotEmpty) {
                          setState(() {
                            activityList.add(activityController.text.trim());
                            activityController.clear();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Masukkan aktivitas yang valid")),
                          );
                        }
                      },
                      icon: Icon(Icons.add),
                      label: Text("Tambah Aktivitas"),
                    ),
                    SizedBox(height: 16),
                    // List of Activities
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: activityList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(activityList[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  activityList.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                  },
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (activityList.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Tambahkan setidaknya satu aktivitas")),
                      );
                      return;
                    }

                    try {
                      // Simpan ke Firestore
                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(taskId)
                          .collection('followUps')
                          .add({
                        'activities': activityList,
                        'submittedBy': FirebaseAuth.instance.currentUser!.uid,
                        'submittedAt': FieldValue.serverTimestamp(),
                        'reviewed': false,
                        'creator': creator,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Rencana aktivitas berhasil diajukan!")),
                      );
                      Navigator.pop(context); // Tutup dialog
                    } catch (e) {
                      print("Error submitting follow-up: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Terjadi kesalahan: $e")),
                      );
                    }
                  },
                  child: Text("Ajukan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDueDate = '';
    if (widget.taskData['dueDate'] != null &&
        widget.taskData['dueDate'] is Timestamp) {
      formattedDueDate = DateFormat('EEEE, d MMMM yyyy')
          .format(widget.taskData['dueDate'].toDate());
    } else if (widget.taskData['dueDate'] is String) {
      try {
        DateTime date = DateTime.parse(widget.taskData['dueDate']);
        formattedDueDate = DateFormat('EEEE, d MMMM yyyy').format(date);
      } catch (e) {
        formattedDueDate = 'Tanggal Tidak Valid';
      }
    } else {
      formattedDueDate = 'Tidak Ditentukan';
    }

    String taskName = widget.taskData['taskName'] ?? 'Tugas Tidak Diketahui';
    String status = widget.taskData['status'] ?? 'Status Tidak Diketahui';
    double progress = widget.taskData['progress'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Penugasan',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                taskName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.red[300],
                        child: FutureBuilder<String>(
                          future: _getUserName(widget.taskData['assignedTo']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            if (snapshot.hasError) {
                              return Icon(Icons.error, color: Colors.red);
                            }
                            return Text(snapshot.data ?? 'U');
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      FutureBuilder<String>(
                        future: _getUserName(widget.taskData['assignedTo']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Memuat...');
                          }
                          if (snapshot.hasError) {
                            return Text('Error');
                          }
                          return Text(snapshot.data ?? 'Unknown');
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Tenggat'),
                      Text(
                        formattedDueDate,
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status'),
                  Text(status),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
                minHeight: 8,
              ),
              SizedBox(height: 16),
              Text(
                'Deskripsi Tugas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(widget.taskData['description'] ?? 'Tidak ada deskripsi.'),
              SizedBox(height: 16),
              Text(
                'Rencana Aktivitas Tindak Lanjut',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                widget.taskData['followUpPlan'] ??
                    'Silahkan pilih tindak lanjut untuk mengisi rencana aktivitas.',
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.currentUserId == widget.taskData['creator']) {
      return Container();
    }

    if (widget.currentUserId == widget.taskData['assignedTo'] &&
        widget.taskData['status'] != 'Completed') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.check),
            label: Text('Tindak Lanjut'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Logika untuk Ajukan Pertimbangan
            },
            icon: Icon(Icons.cancel),
            label: Text('Ajukan Pertimbangan'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Logika untuk Disposisi/Diteruskan
            },
            icon: Icon(Icons.forward),
            label: Text('Disposisi/Diteruskan'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      );
    }

    return Container();
  }
}
