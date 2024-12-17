import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartassistant/services/inputfoto.dart';

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
                            'creator': FirebaseAuth
                                .instance.currentUser!.uid, // ID pembuat tugas
                            'createdAt': FieldValue.serverTimestamp(),
                            'status':
                                'Pending', // Field status dengan nilai default
                            'progress':
                                0, // Field progress dengan nilai default
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
                    child: Text('Simpan'),
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
