import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAskToExpertPage extends StatefulWidget {
  @override
  _AddAskToExpertPageState createState() => _AddAskToExpertPageState();
}

class _AddAskToExpertPageState extends State<AddAskToExpertPage> {
  final TextEditingController _questionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _submitQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    await _firestore.collection('askexpert').add({
      'question': question,
      'answer': null,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pertanyaan berhasil diajukan!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajukan Pertanyaan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Masukkan Pertanyaan',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitQuestion,
              child: Text('Kirim Pertanyaan'),
            ),
          ],
        ),
      ),
    );
  }
}
