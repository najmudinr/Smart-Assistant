import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartassistant/detailpenugasan.dart';
import 'package:smartassistant/services/helper_tugas.dart';
import 'package:smartassistant/services/inputfoto.dart';

class PenugasanPage extends StatefulWidget {
  @override
  _PenugasanPageState createState() => _PenugasanPageState();
}

class _PenugasanPageState extends State<PenugasanPage> {
  bool _canShowFab = false;
  // String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        // _currentUserId = user.uid;
      });
    }
  }

  Future<void> _checkUserRole() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String userRole = userDoc['roles'] ?? '';
        if (['AVP', 'SPV', 'FOREMAN'].contains(userRole.toUpperCase())) {
          setState(() {
            _canShowFab = true;
          });
        }
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
  }

  Future<String> getCurrentUserRole() async {
    try {
      // Ambil pengguna yang sedang masuk
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Query ke Firestore menggunakan UID pengguna
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          // Ambil field 'roles' dari dokumen pengguna
          String userRole = userDoc['roles'] ?? 'Unknown';
          print("User Role: $userRole"); // Debugging
          return userRole;
        } else {
          print("User document not found in Firestore.");
          return 'Unknown';
        }
      } else {
        print("No user is currently signed in.");
        return 'Unknown';
      }
    } catch (e) {
      print("Error fetching user role: $e");
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Daftar Penugasan',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _buildTaskList(),
      floatingActionButton: _canShowFab
          ? FloatingActionButton.extended(
              onPressed: () {
                _showAddTaskModal(context);
              },
              backgroundColor: Colors.orange,
              icon: Icon(Icons.add),
              label: Text("Tambah Tugas"),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTaskList() {
    // Check current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Stream: Combine tasks assigned to user and tasks created by user
    Stream<List<QueryDocumentSnapshot>> combinedStream = FirebaseFirestore
        .instance
        .collection('tasks')
        .where('assignedTo', isEqualTo: currentUser?.uid)
        .snapshots()
        .asyncMap((assignedSnapshot) async {
      // Fetch tasks created by the user
      var createdSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('creator', isEqualTo: currentUser?.uid)
          .get();

      // Combine both streams
      return [
        ...assignedSnapshot.docs,
        ...createdSnapshot.docs,
      ];
    });

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: combinedStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Belum ada tugas.'));
        }

        // Combine tasks
        List<QueryDocumentSnapshot> tasks = snapshot.data!;

        return ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            var task = tasks[index];
            return _buildAssignmentCard(task);
          },
        );
      },
    );
  }

  Widget _buildAssignmentCard(QueryDocumentSnapshot task) {
    // Extract task data
    final taskData = task.data() as Map<String, dynamic>;
    final String taskName = taskData['taskName'] ?? 'Tugas Tidak Diketahui';
    final String status = taskData['status'] ?? 'Tidak Diketahui';
    final dueDate = taskData['dueDate'];
    final String creatorUid = taskData['creator'] ?? '';
    final String assignedToUid = taskData['assignedTo'] ?? '';

    // Fetch creator and assignedTo names
    return FutureBuilder<List<String>>(
      future: Future.wait([
        _getUserName(creatorUid), // Get creator name
        _getUserName(assignedToUid), // Get assignedTo name
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.length < 2) {
          return ListTile(
            title: Text(taskName),
            subtitle: Text('Memuat nama pengguna...'),
          );
        }

        // Safe extraction of names
        final String creatorName = snapshot.data![0];
        final String assignedToName = snapshot.data![1];

        return ListTile(
          title: Text(
            taskName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('$creatorName ➡ $assignedToName'),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              SizedBox(height: 4),
              Text(formatDate(dueDate)),
            ],
          ),
          onTap: () async {
            String currentUserRole = await getCurrentUserRole();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPenugasan(
                  taskData: taskData,
                  currentUserRole: currentUserRole,
                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                ),
              ),
            );
          },
        );
      },
    );
  }

// Function to get user name from Firestore
  Future<String> _getUserName(String uid) async {
    if (uid.isEmpty) return 'Tidak Diketahui'; // Handle empty UID
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['name'] ?? 'Tidak Diketahui';
      }
    } catch (e) {
      print('Error fetching user name for UID $uid: $e');
    }
    return 'Tidak Diketahui';
  }

  void _showAddTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddTaskForm(),
    );
  }
}

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key});

  @override
  _AddTaskFormState createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUser;
  DateTime? _selectedDateTime;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _selectImageFromCamera() async {
    // Use a utility or package for picking an image.
    File? image = await FileUtils.pickImageFromCamera();
    if (image != null) {
      print('Gambar dari kamera: ${image.path}');
    }
  }

// Mengambil gambar dari galeri
  Future<void> _selectImageFromGallery() async {
    File? image = await FileUtils.pickImageFromGallery();
    if (image != null) {
      print('Gambar dari galeri: ${image.path}');
    }
  }

// Memilih file
  Future<void> _selectFile() async {
    File? file = await FileUtils.pickFile();
    if (file != null) {
      print('File yang dipilih: ${file.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tambah Tugas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Tugas',
                  hintText: 'Masukkan nama tugas...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tugas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  List<DropdownMenuItem<String>> userItems =
                      snapshot.data!.docs.map((doc) {
                    String userId = doc.id; // Ambil UID pengguna
                    String userName = doc['name']; // Nama pengguna
                    return DropdownMenuItem<String>(
                      value: userId,
                      child: Text(userName),
                    );
                  }).toList();

                  return DropdownButtonFormField<String>(
                    value: _selectedUser,
                    items: userItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedUser = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Diberikan ke',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih pengguna';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
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
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedDateTime == null
                        ? 'Pilih Tenggat'
                        : 'Tenggat: ${_selectedDateTime!.toLocal()}'
                            .split('.')[0],
                    style: TextStyle(
                      color: _selectedDateTime == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Masukkan deskripsi tugas...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () async {
                      _selectImageFromCamera();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gambar diambil dari kamera')),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () async {
                      _selectFile();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('File berhasil dipilih')),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.image),
                    onPressed: () async {
                      _selectImageFromGallery();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gambar dipilih dari galeri')),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('tasks')
                              .add({
                            'taskName': _taskNameController.text,
                            'assignedTo': _selectedUser,
                            'dueDate': _selectedDateTime?.toIso8601String(),
                            'description': _descriptionController.text,
                            'creator': FirebaseAuth.instance.currentUser!
                                .uid, // Tambahkan ID pembuat tugas
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          // Tampilkan snackbar berhasil
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tugas berhasil dibuat')),
                          );

                          Navigator.pop(
                              context); // Tutup modal setelah tugas dibuat
                        } catch (e) {
                          // Tampilkan snackbar untuk error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Terjadi kesalahan: $e')),
                          );
                        }
                      }
                    },
                    child: Text("Simpan"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
