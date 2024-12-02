import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditSubmissionPage extends StatefulWidget {
  final String submissionId;
  const EditSubmissionPage({super.key, required this.submissionId});

  @override
  _EditSubmissionPageState createState() => _EditSubmissionPageState();
}

class _EditSubmissionPageState extends State<EditSubmissionPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loadSubmission() async {
    setState(() {
      _isLoading = true;
    });

    final doc = await FirebaseFirestore.instance.collection('submissions').doc(widget.submissionId).get();
    if (doc.exists) {
      _titleController.text = doc['title'] ?? '';
      _descriptionController.text = doc['description'] ?? '';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateSubmission() async {
    try {
      await FirebaseFirestore.instance.collection('submissions').doc(widget.submissionId).update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': null, // Reset status setelah pengeditan
        'reason': null, // Reset alasan
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil diperbarui.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui pengajuan.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
      print('Editing Submission ID: ${widget.submissionId}');
    _loadSubmission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengajuan'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Judul Pengajuan'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Deskripsi Pengajuan'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateSubmission,
                    child: const Text('Simpan Perubahan'),
                  ),
                ],
              ),
            ),
    );
  }
}
