import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCommunityQuestionPage extends StatefulWidget {
  @override
  _AddCommunityQuestionPageState createState() =>
      _AddCommunityQuestionPageState();
}

class _AddCommunityQuestionPageState extends State<AddCommunityQuestionPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  bool _isUploading = false;

  Future<void> _submitQuestion() async {
    if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
      setState(() {
        _isUploading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser!;
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userSnapshot.exists) {
          throw Exception("User data not found");
        }

        final userName = userSnapshot['name'] ?? 'Pengguna';
        final userRole = userSnapshot['roles'] ?? 'User';

        await FirebaseFirestore.instance.collection('questions').add({
          'userId': user.uid,
          'name': userName,
          'roles': userRole,
          'title': titleController.text,
          'content': contentController.text,
          'likesCount': 0,
          'likedBy': [],
          'comments': [],
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pertanyaan berhasil ditambahkan!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        print("Error adding question: $e"); // Log the actual error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menambahkan pertanyaan. Silakan coba lagi."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Judul dan Deskripsi tidak boleh kosong!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Pertanyaan"),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Judul Pertanyaan",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: "Deskripsi Pertanyaan",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            _isUploading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text("Simpan"),
                  ),
          ],
        ),
      ),
    );
  }
}
