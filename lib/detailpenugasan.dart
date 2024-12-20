import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
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

  void _showConsiderationForm() {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajukan Pertimbangan'),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: 'Masukkan alasan pertimbangan...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(widget.taskData['id'])
                      .update({
                    'status': 'Menunggu Pertimbangan',
                    'reasonForConsideration': reasonController.text.trim(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pertimbangan berhasil diajukan')),
                  );
                }
              },
              child: Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog() {
    TextEditingController descriptionController =
        TextEditingController(text: widget.taskData['description']);
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Perbarui Tugas'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(hintText: 'Deskripsi Tugas'),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Tenggat Waktu:'),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );

                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Text(
                        selectedDate == null
                            ? 'Pilih Tanggal & Waktu'
                            : DateFormat('yyyy-MM-dd HH:mm')
                                .format(selectedDate!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tenggat waktu harus dipilih')),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(widget.taskData['id'])
                    .update({
                  'status': 'Progress',
                  'dueDate': selectedDate!.toIso8601String(),
                  'description': descriptionController.text.trim(),
                  'considerationResponse': 'Diterima',
                  'creatorNote': 'Tugas diperbarui berdasarkan pertimbangan',
                });

                Navigator.pop(context);
                setState(() {
                  widget.taskData['status'] = 'Progress';
                });

                // Panggil ulang data untuk merefresh UI
                await _fetchFollowUpPlans();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tugas berhasil diperbarui')),
                );
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
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

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  void _showDispositionDialog() async {
    String? selectedUser;
    List<Map<String, dynamic>> usersList = await _fetchUsers();

    if (usersList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Tidak ada user yang tersedia untuk disposisi.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text("Disposisi Tugas"),
              content: DropdownButtonFormField<String>(
                hint: Text("Pilih user untuk diteruskan"),
                value: selectedUser,
                onChanged: (String? newValue) {
                  print('User selected: $newValue');
                  setDialogState(() {
                    selectedUser = newValue;
                  });
                  print(
                      'Dialog Button enabled: ${selectedUser != null && selectedUser != widget.currentUserId}');
                },
                items: usersList.map((user) {
                  print('Dropdown item: ${user['id']} - ${user['name']}');
                  return DropdownMenuItem<String>(
                    value: user['id'],
                    child: Text(user['name']!),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: selectedUser == null ||
                          selectedUser == widget.currentUserId
                      ? null
                      : () {
                          print('Tombol ditekan untuk user: $selectedUser');
                          _forwardTask(selectedUser!);
                          Navigator.pop(context);
                        },
                  child: Text("Teruskan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _forwardTask(String newAssignee) async {
    print('Forwarding task to: $newAssignee'); // Debugging awal
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskData['id'])
          .update({
        'assignedTo': newAssignee,
        'status': 'Diteruskan',
      });

      print('Task forwarded successfully'); // Debugging sukses
      setState(() {
        widget.taskData['assignedTo'] = newAssignee;
        widget.taskData['status'] = 'Diteruskan';
      });

      // await _addLog('Tugas diteruskan ke pengguna: $newAssignee');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tugas berhasil diteruskan")),
      );
    } catch (e) {
      print('Error forwarding task: $e'); // Debugging error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal meneruskan tugas: $e")),
      );
    }
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
        backgroundColor: Colors.white,
        title: Text(
          'Detail Penugasan',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData, // Panggil fungsi refresh manual
        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // Agar selalu bisa ditarik ke bawah
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskHeader(taskName, formattedDueDate),
                SizedBox(height: 16),
                if (widget.currentUserId == widget.taskData['creator'])
                  _buildConsiderationReview(),
                _buildTaskStatus(status, progress),
                SizedBox(height: 16),
                _buildTaskDescription(),
                SizedBox(height: 16),
                _buildFollowUpPlans(),
                SizedBox(height: 16),
                _buildActionButtons(),
                // Divider(),
                // _buildActivityLog(),
              ],
            ),
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

    bool isAssignedUser = widget.currentUserId == widget.taskData['assignedTo'];
    bool isCreator = widget.currentUserId == widget.taskData['creator'];

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
              onChanged: isAssignedUser
                  ? (value) => _updateCheckbox(plan['id'], value)
                  : null,
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
                    Text(
                      'Alasan Ditolak: ${plan['reason']}',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              trailing: isCreator && plan['status'] == 'Pending'
                  ? _buildFollowUpActionButtons(
                      plan['id']) // Creator bisa menerima/menolak
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
    // Identifikasi user
    bool isAssignedUser = widget.currentUserId == widget.taskData['assignedTo'];
    bool isRejected = widget.taskData['status'] == 'Rejected';
    bool isCreator = widget.currentUserId == widget.taskData['creator'];
    bool hasSubmittedReason = widget.taskData['status'] ==
        'Menunggu Pertimbangan'; // Status 'Menunggu Pertimbangan'

    // Tombol tidak ditampilkan jika user adalah creator
    if (isCreator) {
      return Container(); // Tidak menampilkan tombol sama sekali untuk creator
    }

    // Tombol dinonaktifkan untuk penerima tugas jika status 'Menunggu Pertimbangan' atau 'Rejected'
    if (followUpPlans.isNotEmpty ||
        hasSubmittedReason ||
        (isAssignedUser && isRejected)) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: null, // Dinonaktifkan
            icon: Icon(Icons.check, color: Colors.grey),
            label: Text('Tindak Lanjut', style: TextStyle(color: Colors.grey)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
            ),
          ),
          ElevatedButton.icon(
            onPressed: null, // Dinonaktifkan
            icon: Icon(Icons.cancel, color: Colors.grey),
            label: Text('Ajukan Pertimbangan',
                style: TextStyle(color: Colors.grey)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
            ),
          ),
          ElevatedButton.icon(
            onPressed: null, // Dinonaktifkan
            icon: Icon(Icons.forward, color: Colors.grey),
            label: Text('Disposisi/Diteruskan',
                style: TextStyle(color: Colors.grey)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
            ),
          ),
        ],
      );
    }

    // Tombol tetap aktif jika status memungkinkan
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: hasSubmittedReason
              ? null // Dinonaktifkan jika sudah mengajukan alasan
              : () {
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
          onPressed: hasSubmittedReason
              ? null // Dinonaktifkan jika sudah mengajukan alasan
              : _showConsiderationForm,
          icon: Icon(Icons.cancel),
          label: Text('Ajukan Pertimbangan'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        ElevatedButton.icon(
          onPressed: hasSubmittedReason
              ? null // Dinonaktifkan jika sudah mengajukan alasan
              : _showDispositionDialog,
          icon: Icon(Icons.forward),
          label: Text('Disposisi/Diteruskan'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildConsiderationReview() {
    if (widget.taskData['status'] == 'Menunggu Pertimbangan') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alasan Pertimbangan:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(widget.taskData['reasonForConsideration'] ?? '-'),
          SizedBox(height: 8),
          Wrap(
            spacing: 8, // Jarak antar tombol
            runSpacing: 8, // Jarak antar baris jika meluap
            alignment: WrapAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () async {
                  _showEditTaskDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(100, 40), // Tentukan ukuran minimum tombol
                ),
                child: Text('Terima Pertimbangan'),
              ),
              ElevatedButton(
                onPressed: () async {
                  TextEditingController rejectionNoteController =
                      TextEditingController();

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Alasan Penolakan'),
                        content: TextField(
                          controller: rejectionNoteController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan catatan tambahan...',
                          ),
                          maxLines: 3,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('tasks')
                                  .doc(widget.taskData['id'])
                                  .update({
                                'status': 'Progress',
                                'considerationResponse': 'Ditolak',
                                'creatorNote':
                                    rejectionNoteController.text.trim(),
                              });

                              Navigator.pop(context);
                              setState(() {
                                widget.taskData['status'] = 'Progress';
                              });

                              // Panggil ulang data untuk merefresh UI
                              await _fetchFollowUpPlans();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Pertimbangan ditolak')),
                              );
                            },
                            child: Text('Kirim'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(100, 40), // Tentukan ukuran minimum tombol
                ),
                child: Text('Tolak Pertimbangan'),
              ),
            ],
          ),
        ],
      );
    }
    return Container();
  }

  //    Widget _buildActivityLog() {
  //   return Column(
  //     children: [
  //       Expanded(
  //         child: StreamBuilder<QuerySnapshot>(
  //           stream: FirebaseFirestore.instance
  //               .collection('tasks')
  //               .doc(widget.taskData['id'])
  //               .collection('activityLog')
  //               .orderBy('timestamp', descending: true)
  //               .snapshots(),
  //           builder: (context, snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return Center(child: CircularProgressIndicator());
  //             }

  //             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //               return Center(child: Text('Belum ada aktivitas.'));
  //             }

  //             return ListView.builder(
  //               reverse: true,
  //               itemCount: snapshot.data!.docs.length,
  //               itemBuilder: (context, index) {
  //                 var log = snapshot.data!.docs[index].data()
  //                     as Map<String, dynamic>;
  //                 return ListTile(
  //                   leading: CircleAvatar(
  //                     child: Text(log['userName']?.substring(0, 1) ?? '-'),
  //                   ),
  //                   title: Text(log['description']),
  //                   subtitle: Text(
  //                     DateFormat('dd MMM yyyy, HH:mm').format(
  //                       (log['timestamp'] as Timestamp).toDate(),
  //                     ),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: TextField(
  //                 controller: _activityController,
  //                 decoration: InputDecoration(
  //                   hintText: 'Tulis pembaruan atau diskusi...',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 8),
  //             ElevatedButton.icon(
  //               onPressed: _sendActivityUpdate,
  //               icon: Icon(Icons.send),
  //               label: Text('Kirim'),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

// final TextEditingController _activityController = TextEditingController();

// void _sendActivityUpdate() async {
//     if (_activityController.text.trim().isEmpty) return;

//     User? currentUser = FirebaseAuth.instance.currentUser;

//     await FirebaseFirestore.instance
//         .collection('tasks')
//         .doc(widget.taskData['id'])
//         .collection('activityLog')
//         .add({
//       'userId': currentUser?.uid,
//       'userName': currentUser?.displayName ?? 'User',
//       'description': _activityController.text.trim(),
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     _activityController.clear();
//   }

//  Future<void> _addLog(String description) async {
//     User? currentUser = FirebaseAuth.instance.currentUser;

//     await FirebaseFirestore.instance
//         .collection('tasks')
//         .doc(widget.taskData['id'])
//         .collection('activityLog')
//         .add({
//       'userId': currentUser?.uid,
//       'userName': currentUser?.displayName ?? 'User',
//       'description': description,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> _logFollowUpActivity(String planId, bool isApproved) async {
//     String activity = isApproved
//         ? 'Creator menyetujui rencana aktivitas tindak lanjut dengan ID $planId.'
//         : 'Creator menolak rencana aktivitas tindak lanjut dengan ID $planId.';

//     await _addLog(activity);
//   }

//   Future<void> _logProgressUpdate(String progressDescription) async {
//     String activity = 'User melakukan progress pada penugasan: $progressDescription.';
//     await _addLog(activity);
//   }

//   Future<void> _logConsideration(String considerationDescription, bool isApproved) async {
//     String activity = isApproved
//         ? 'Creator menyetujui pertimbangan: $considerationDescription.'
//         : 'Creator menolak pertimbangan: $considerationDescription.';

//     await _addLog(activity);
//   }

//   Future<void> _logTaskDisposition(String newUserId) async {
//     String activity = 'User melakukan disposisi penugasan ke user dengan ID $newUserId.';
//     await _addLog(activity);
//   }

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

  Future<void> _refreshData() async {
    try {
      // Muat ulang data tugas
      DocumentSnapshot taskDoc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskData['id'])
          .get();

      if (taskDoc.exists) {
        setState(() {
          widget.taskData.addAll(taskDoc.data() as Map<String, dynamic>);
        });
      }

      // Muat ulang rencana tindak lanjut
      await _fetchFollowUpPlans();
    } catch (e) {
      print('Error refreshing data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat ulang data.')),
      );
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
