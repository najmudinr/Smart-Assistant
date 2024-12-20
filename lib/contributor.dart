import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContributorPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kontributor - Jawab Pertanyaan'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('askexpert')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada pertanyaan yang menunggu jawaban.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final questions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              final data = question.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['question'] ?? 'Pertanyaan tidak ditemukan'),
                  subtitle: Text('Status: ${data['status']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnswerQuestionPage(
                          questionId: question.id,
                          questionText: data['question'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AnswerQuestionPage extends StatefulWidget {
  final String questionId;
  final String questionText;

  const AnswerQuestionPage(
      {required this.questionId, required this.questionText});

  @override
  _AnswerQuestionPageState createState() => _AnswerQuestionPageState();
}

class _AnswerQuestionPageState extends State<AnswerQuestionPage> {
  final TextEditingController _answerController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _submitAnswer() async {
    if (_answerController.text.isEmpty) return;

    await _firestore
        .collection('askexpert')
        .doc(widget.questionId)
        .collection('answers')
        .add({
      'answer': _answerController.text,
      'contributor': 'Nama Kontributor', // Ganti dengan data user
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jawab Pertanyaan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pertanyaan:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(widget.questionText),
            SizedBox(height: 16),
            TextField(
              controller: _answerController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis jawaban Anda di sini...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: Text('Kirim Jawaban'),
            ),
          ],
        ),
      ),
    );
  }
}
