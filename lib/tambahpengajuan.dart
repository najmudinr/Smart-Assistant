import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class TambahPengajuanPage extends StatefulWidget {
  @override
  _TambahPengajuanPageState createState() => _TambahPengajuanPageState();
}

class _TambahPengajuanPageState extends State<TambahPengajuanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedTargetUserId;
  PlatformFile? _selectedFile;

  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String? uploadedFileUrl;

    // Upload dokumen jika ada
    if (_selectedFile != null) {
      try {
        final ref = FirebaseStorage.instance.ref().child('submissions').child(
            '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}');
        final uploadTask = ref.putData(_selectedFile!.bytes!);
        final snapshot = await uploadTask;
        uploadedFileUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Error uploading file: $e');
      }
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('submissions').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'documentUrl': uploadedFileUrl,
        'targetUserId': _selectedTargetUserId,
        'submittedBy': currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengajuan berhasil dikirim!')),
      );

      // Reset form
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedTargetUserId = null;
        _selectedFile = null;
      });
    } catch (e) {
      print('Error saving submission: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan. Silakan coba lagi.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<List<Map<String, String>>> _fetchTargets() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Ambil dokumen pengguna
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final String mainRole = userDoc['mainRole'] ?? '';

          // Menentukan hierarki atasan berdasarkan mainRole
          List<String> rolesAtasan = [];
          switch (mainRole) {
            case 'STAFF_OPERASIONAL':
              rolesAtasan = ['FOREMAN', 'SPV', 'AVP'];
              break;
            case 'FOREMAN':
              rolesAtasan = ['SPV', 'AVP'];
              break;
            case 'SPV':
              rolesAtasan = ['AVP'];
              break;
            case 'AVP':
              return []; // AVP tidak memiliki atasan
            default:
              print("Tidak ada atasan untuk role: $mainRole.");
              return [];
          }

          // Mengambil data atasan dari Firestore berdasarkan rolesAtasan
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('roles', whereIn: rolesAtasan)
              .get();

          return querySnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'name': doc['name'] as String? ?? 'Unknown',
            };
          }).toList();
        } else {
          print('User document not found for ${currentUser.uid}');
        }
      }
    } catch (e) {
      print('Error fetching targets: $e');
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Pengajuan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul pengajuan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Pengajuan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi pengajuan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickFile,
                      child: Text(_selectedFile == null
                          ? 'Upload Dokumen (Opsional)'
                          : 'File: ${_selectedFile!.name}'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              FutureBuilder<List<Map<String, String>>>(
                future: _fetchTargets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Text('Terjadi kesalahan saat memuat data');
                  }

                  final targets = snapshot.data ?? [];

                  if (targets.isEmpty) {
                    return const Text('Tidak ada atasan yang tersedia');
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedTargetUserId,
                    items: targets
                        .map(
                          (target) => DropdownMenuItem<String>(
                            value: target['id'],
                            child: Text(target['name']!),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTargetUserId = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Atasan yang Dituju',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan pilih atasan';
                      }
                      return null;
                    },
                  );
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Kirim Pengajuan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
