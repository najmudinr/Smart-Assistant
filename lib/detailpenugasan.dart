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
  List<Map<String, dynamic>> followUpPlans = [];
  String? assignedToName;

  Map<String, bool> checkboxValues = {};

  @override
  void initState() {
    super.initState();
    _fetchFollowUpPlans();
    _fetchAssignedToName();
  }

  Future<void> _fetchFollowUpPlans() async {
    try {
      String taskId = widget.taskData['id'];
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .collection('followUpPlans')
          .get();

      setState(() {
        followUpPlans = snapshot.docs.map((doc) {
          checkboxValues[doc.id] = doc['completed'] ?? false; // Checkbox state
          return {
            'id': doc.id,
            'plan': doc['plan'],
            'status': doc['status'],
          };
        }).toList();
      });
      _calculateProgress(); // Hitung progress awal
    } catch (e) {
      print('Error fetching follow-up plans: $e');
    }
  }

  void _updateCheckbox(String id, bool? value) async {
    setState(() {
      checkboxValues[id] = value ?? false;
    });

    // Update Firestore dengan status checkbox
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.taskData['id'])
        .collection('followUpPlans')
        .doc(id)
        .update({'completed': checkboxValues[id]});

    _calculateProgress();
  }

  void _calculateProgress() async {
    int totalApproved =
        followUpPlans.where((plan) => plan['status'] == 'Approved').length;

    int completedCount =
        checkboxValues.entries.where((entry) => entry.value).length;

    double progress = totalApproved > 0 ? completedCount / totalApproved : 0.0;

    setState(() {
      widget.taskData['progress'] = progress;
    });

    // Update progress di Firestore
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.taskData['id'])
        .update({'progress': progress});

    // Cek dan perbarui status berdasarkan progress
    if (progress >= 1.0) {
      // Jika progress mencapai 100%, status menjadi "Selesai"
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskData['id'])
          .update({'status': 'Selesai'});

      setState(() {
        widget.taskData['status'] = 'Selesai';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progress telah mencapai 100%! Tugas selesai.')),
      );
    } else if (progress > 0.0 && progress < 1.0) {
      // Jika progress di antara 0 dan 100%, status menjadi "Progress"
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskData['id'])
          .update({'status': 'Progress'});

      setState(() {
        widget.taskData['status'] = 'Progress';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tugas sedang dalam progres.')),
      );
    }
  }

  Future<void> _fetchAssignedToName() async {
    try {
      final assignedToId = widget.taskData['assignedTo'];
      if (assignedToId != null && assignedToId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(assignedToId)
            .get();

        if (userDoc.exists) {
          setState(() {
            assignedToName = userDoc['name'] ?? 'Unknown';
          });
        }
      }
    } catch (e) {
      print('Error fetching assignedTo name: $e');
      setState(() {
        assignedToName = 'Unknown';
      });
    }
  }

  void _navigateToEditFollowUp(String followUpId, String currentPlan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowUpForm(
          taskId: widget.taskData['id'],
          followUpId: followUpId,
          currentPlan: currentPlan,
          onPlanUpdated: () => _fetchFollowUpPlans(),
          onPlanAdded: () {}, // Refresh UI after edit
        ),
      ),
    );
  }

  String _formatDueDate() {
    if (widget.taskData['dueDate'] != null) {
      if (widget.taskData['dueDate'] is Timestamp) {
        return DateFormat('EEEE, d MMMM yyyy')
            .format(widget.taskData['dueDate'].toDate());
      } else if (widget.taskData['dueDate'] is String) {
        try {
          DateTime date = DateTime.parse(widget.taskData['dueDate']);
          return DateFormat('EEEE, d MMMM yyyy').format(date);
        } catch (e) {
          return 'Tanggal Tidak Valid';
        }
      }
    }
    return 'Tidak Ditentukan';
  }

  @override
  Widget build(BuildContext context) {
    String formattedDueDate = _formatDueDate();
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
              _buildTaskHeader(taskName, formattedDueDate),
              SizedBox(height: 16),
              _buildTaskStatus(status, progress),
              SizedBox(height: 16),
              _buildTaskDescription(),
              SizedBox(height: 16),
              _buildFollowUpPlans(),
              SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader(String taskName, String formattedDueDate) {
    return Column(
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
            _buildAssignedToInfo(),
            _buildDueDateInfo(formattedDueDate),
          ],
        ),
      ],
    );
  }

  Widget _buildAssignedToInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.red[300],
          child: FutureBuilder<String>(
            future: getUserName(widget.taskData['assignedTo']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Icon(Icons.error, color: Colors.white, size: 16);
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
            if (snapshot.connectionState == ConnectionState.waiting) {
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
    );
  }

  Widget _buildDueDateInfo(String formattedDueDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Tenggat'),
        Text(
          formattedDueDate,
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTaskStatus(String status, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Status'),
            Text(status),
          ],
        ),
        SizedBox(height: 8),
        _buildProgressBar(progress),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        Text('Progress Tugas', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: Colors.green,
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildTaskDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi Tugas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(widget.taskData['description'] ?? 'Tidak ada deskripsi.'),
      ],
    );
  }

  Widget _buildFollowUpPlans() {
    // Debug untuk memeriksa semua data
    print('All Plans: $followUpPlans');

    final approvedPlans =
        followUpPlans.where((plan) => plan['status'] == 'Approved').toList();

    final pendingOrRejectedPlans =
        followUpPlans.where((plan) => plan['status'] != 'Approved').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rencana Aktivitas Tindak Lanjut',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),

        // Tampilkan pesan jika tidak ada rencana aktivitas sama sekali
        if (followUpPlans.isEmpty)
          Text(
            widget.currentUserId == widget.taskData['assignedTo']
                ? "Silahkan pilih tindak lanjut untuk mengisi rencana aktivitas"
                : "Tugas belum ditindak lanjuti oleh ${assignedToName ?? 'Penerima'}",
            style: TextStyle(color: Colors.grey),
          ),

        // Tampilkan Approved Plans sebagai Checkbox
        if (approvedPlans.isNotEmpty)
          ...approvedPlans.map((plan) {
            return CheckboxListTile(
              title: Text(plan['plan'] ?? 'Rencana tidak tersedia'),
              value: checkboxValues[plan['id']] ?? false,
              onChanged: (value) => _updateCheckbox(plan['id'], value),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),

        // Tampilkan Pending atau Rejected Plans sebagai ListTile biasa
        if (pendingOrRejectedPlans.isNotEmpty)
          ...pendingOrRejectedPlans.map((plan) {
            return ListTile(
              title: Text(plan['plan'] ?? 'Rencana tidak tersedia'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${plan['status'] ?? 'Tidak Diketahui'}'),
                  if (plan['status'] == 'Rejected' && plan['reason'] != null)
                    Text('Alasan Ditolak: ${plan['reason']}',
                        style: TextStyle(color: Colors.red)),
                ],
              ),
              trailing: widget.currentUserId == widget.taskData['creator'] &&
                      plan['status'] == 'Pending'
                  ? _buildFollowUpActionButtons(plan['id'])
                  : null,
              onTap: () {
                if (widget.currentUserId == widget.taskData['assignedTo'] &&
                    plan['status'] == 'Rejected') {
                  _navigateToEditFollowUp(plan['id'], plan['plan']);
                }
              },
            );
          }),
      ],
    );
  }

  Widget _buildFollowUpActionButtons(String followUpId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.check, color: Colors.green),
          onPressed: () => _updateFollowUpStatus(followUpId, 'Approved'),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: () => _updateFollowUpStatus(followUpId, 'Rejected'),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (followUpPlans.isNotEmpty ||
        widget.currentUserId == widget.taskData['creator']) {
      return Container(); // Do not display buttons if there are follow-up plans or the user is the task creator
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
                    },
                    followUpId: '',
                    currentPlan: '',
                    onPlanUpdated: () {}, // Update UI after input
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
            // Logic for submitting consideration
          },
          icon: Icon(Icons.cancel),
          label: Text('Ajukan Pertimbangan'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Logic for disposition/forwarding
          },
          icon: Icon(Icons.forward),
          label: Text('Disposisi/Diteruskan'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
      ],
    );
  }

  Future<void> _updateFollowUpStatus(String followUpId, String status) async {
    if (status == 'Rejected') {
      // Show dialog to input reason
      String? reason = await _showRejectReasonDialog();
      if (reason == null || reason.isEmpty) {
        return; // Cancel if no reason is provided
      }

      try {
        String taskId = widget.taskData['id'];
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(taskId)
            .collection('followUpPlans')
            .doc(followUpId)
            .update({
          'status': status,
          'reason': reason, // Save the reason
        });
        _fetchFollowUpPlans();
      } catch (e) {
        print('Error updating follow-up status: $e');
      }
    } else {
      // Directly approve
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
  }

  Future<String?> _showRejectReasonDialog() async {
    TextEditingController reasonController = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alasan Penolakan'),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: 'Masukkan alasan mengapa ditolak',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, reasonController.text), // Confirm
              child: Text('Simpan'),
            ),
          ],
        );
      },
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
