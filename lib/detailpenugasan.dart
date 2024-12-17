import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartassistant/widgets/followupform.dart';

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
  Future<Map<String, dynamic>> fetchTaskData(String taskId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Tambahkan Document ID ke dalam data
        data['id'] = doc.id;
        return data;
      } else {
        throw Exception('Task not found');
      }
    } catch (e) {
      print('Error fetching task: $e');
      throw Exception('Failed to fetch task');
    }
  }

  List<Map<String, dynamic>> followUpPlans = [];
  String? assignedToName;

  @override
  void initState() {
    super.initState();
    // print('Task data: ${widget.taskData}');
    _fetchFollowUpPlans();
    _fetchAssignedToName();
  }

  void _fetchFollowUpPlans() async {
    try {
      String taskId = widget.taskData['id'];
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .collection('followUpPlans')
          .get();

      setState(() {
        followUpPlans = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'plan': doc['plan'],
            'status': doc['status'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching follow-up plans: $e');
    }
  }

  void _fetchAssignedToName() async {
    try {
      final assignedToId = widget.taskData['assignedTo'];
      print('AssignedTo ID: $assignedToId');

      if (assignedToId != null && assignedToId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(assignedToId)
            .get();

        if (userDoc.exists) {
          print('AssignedTo Name: ${userDoc['name']}');
          setState(() {
            assignedToName = userDoc['name'] ?? 'Unknown';
          });
        } else {
          print('User document does not exist');
        }
      } else {
        print('AssignedTo ID is null or empty');
      }
    } catch (e) {
      print('Error fetching assignedTo name: $e');
      setState(() {
        assignedToName = 'Unknown';
      });
    }
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
    if (widget.taskData['id'] == null || widget.taskData['id'].isEmpty) {}

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
                          future: getUserName(widget.taskData['assignedTo']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              );
                            }
                            if (snapshot.hasError || snapshot.data == null) {
                              return Icon(Icons.error,
                                  color: Colors.white, size: 16);
                            }
                            final String initial = snapshot.data!.isNotEmpty
                                ? snapshot.data![0].toUpperCase()
                                : 'U';
                            return Text(
                              initial,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      FutureBuilder<String>(
                        future: getUserName(widget.taskData['assignedTo']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              'Memuat nama...',
                              style: TextStyle(color: Colors.grey),
                            );
                          }
                          if (snapshot.hasError || snapshot.data == null) {
                            return Text(
                              'Tidak diketahui',
                              style: TextStyle(color: Colors.red),
                            );
                          }
                          return Text(
                            snapshot.data!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
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
                widget.currentUserId == widget.taskData['assignedTo']
                    ? "Silahkan pilih tindak lanjut untuk mengisi rencana aktivitas"
                    : "Tugas belum ditindak lanjuti oleh ${assignedToName ?? 'Penerima'}",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 8),
              ...followUpPlans.map((plan) {
                return ListTile(
                  title: Text(plan['plan']),
                  subtitle: Text('Status: ${plan['status']}'),
                  trailing: widget.currentUserId == widget.taskData['creator']
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  _updateFollowUpStatus(plan['id'], 'Approved'),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  _updateFollowUpStatus(plan['id'], 'Rejected'),
                            ),
                          ],
                        )
                      : null,
                );
              }),
              SizedBox(height: 16),
              buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  void _updateFollowUpStatus(String followUpId, String status) async {
    try {
      String taskId = widget.taskData['id'];
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .collection('followUpPlans')
          .doc(followUpId)
          .update({'status': status});

      _fetchFollowUpPlans();
    } catch (e) {
      print('Error updating follow-up status: $e');
    }
  }

  Widget buildActionButtons() {
    // Sembunyikan tombol jika ada follow-up plan
    if (followUpPlans.isNotEmpty) {
      return Container(); // Tidak menampilkan tombol
    }

    // Sembunyikan tombol jika user adalah pembuat tugas
    if (widget.currentUserId == widget.taskData['creator']) {
      return Container(); // Tidak menampilkan tombol jika user adalah pembuat tugas
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            String taskId = widget.taskData['id'];
            if (taskId.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowUpForm(
                    taskId: taskId,
                    onPlanAdded: () {
                      _fetchFollowUpPlans();
                    }, // Perbarui UI setelah input
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task ID tidak ditemukan!')),
              );
            }
          },
          icon: Icon(Icons.check),
          label: Text('Tindak Lanjut'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

  Future<String> getUserName(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['name'] ?? 'Unknown';
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
    return 'Unknown';
  }
}
