import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
// Import helper

class AddNewsPage extends StatefulWidget {
  @override
  _AddNewsPageState createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;
  // Instance UserInfoHelper

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef =
          FirebaseStorage.instance.ref().child('news_docs/$fileName');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  Future<void> _submitNews() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      String? fileUrl;
      if (_selectedFile != null) {
        fileUrl = await _uploadFile(_selectedFile!);
      }

      final user = FirebaseAuth.instance.currentUser!;
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = userSnapshot['name'] ?? 'Anonymous';
      final userRole = userSnapshot['roles'] ?? 'User';

      // Tambahkan userId ke dalam newsData
      final newsData = {
        'userId': user.uid, // User ID
        'title': _titleController.text,
        'content': _contentController.text,
        'fileUrl': fileUrl ?? '',
        'name': userName,
        'roles': userRole,
        'timeAgo': DateTime.now().toIso8601String(),
        'likesCount': 0, // Inisialisasi jumlah suka ke 0
        'likedBy': [], // Inisialisasi daftar suka ke array kosong
      };

      try {
        await FirebaseFirestore.instance.collection('news').add(newsData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Berita berhasil ditambahkan!"),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      } catch (e) {
        print("Error adding news: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Terjadi kesalahan saat menambahkan berita."),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Berita"),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Judul Berita",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Judul berita tidak boleh kosong";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: "Isi Berita",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Isi berita tidak boleh kosong";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectFile,
                    icon: Icon(Icons.upload_file),
                    label: Text("Unggah Dokumen"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                  ),
                  SizedBox(width: 8),
                  if (_selectedFile != null)
                    Expanded(
                      child: Text(
                        _selectedFile!.path.split('/').last,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 32),
              _isUploading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitNews,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                      child: Text("Tambah Berita"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
