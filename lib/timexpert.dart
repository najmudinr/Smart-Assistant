import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpertPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tim Expert - Pilih Jawaban'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('askexpert')
            .where('status', isEqualTo: 'answered')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada pertanyaan untuk dipilih jawabannya.',
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectAnswerPage(
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

class SelectAnswerPage extends StatelessWidget {
  final String questionId;
  final String questionText;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SelectAnswerPage({required this.questionId, required this.questionText});

  void _selectAnswer(String answerId) async {
    await _firestore.collection('askexpert').doc(questionId).update({
      'finalAnswer': answerId,
      'status': 'resolved',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Jawaban Terbaik'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Pertanyaan:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(questionText),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('askexpert')
                  .doc(questionId)
                  .collection('answers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada jawaban untuk pertanyaan ini.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final answers = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    final answer = answers[index];
                    final data = answer.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(data['answer'] ?? 'Jawaban tidak ditemukan'),
                      subtitle: Text(data['contributor'] ?? 'Anonim'),
                      onTap: () {
                        _selectAnswer(answer.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
