import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailQuestionPage extends StatefulWidget {
  final String questionId;
  final String questionText;

  const DetailQuestionPage({
    required this.questionId,
    required this.questionText,
  });

  @override
  _DetailQuestionPageState createState() => _DetailQuestionPageState();
}

class _DetailQuestionPageState extends State<DetailQuestionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isExpert = false;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfExpert();
  }

  Future<void> _addAnswer(String answer) async {
    final user = _auth.currentUser;
    if (user == null || answer.isEmpty) return;

    final answerData = {
      'answer': answer,
      'answeredBy': user.uid,
      'votes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('askexpert')
        .doc(widget.questionId)
        .collection('answers')
        .add(answerData);

    _answerController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jawaban berhasil ditambahkan')),
    );
  }

  Future<void> _checkIfExpert() async {
    final userDoc =
        await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
    final userData = userDoc.data();
    setState(() {
      isExpert = userData?['mainRole'] == 'SUPERVISORY';
    });
  }

  Future<void> _addVote(String answerId) async {
    final answerDoc = _firestore
        .collection('askexpert')
        .doc(widget.questionId)
        .collection('answers')
        .doc(answerId);

    await answerDoc.update({
      'votes': FieldValue.increment(1),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vote berhasil ditambahkan')),
    );
  }

  Future<String> _getUserName(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data();
    return userData?['name'] ?? 'Anonymous';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pertanyaan'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.questionText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('askexpert')
                  .doc(widget.questionId)
                  .collection('answers')
                  .orderBy('votes', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada jawaban.',
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
                    final answerId = answer.id;

                    return FutureBuilder<String>(
                      future: _getUserName(data['answeredBy']),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            title: Text(data['answer'] ?? ''),
                            subtitle: Text('Sedang memuat nama...'),
                          );
                        }

                        return ListTile(
                          title: Text(data['answer'] ?? ''),
                          subtitle: Text(
                              'Dijawab oleh: ${userSnapshot.data ?? 'Anonymous'}'),
                          trailing: Column(
                            children: [
                              Text(
                                'Votes: ${data['votes'] ?? 0}',
                                style: TextStyle(fontSize: 14),
                              ),
                              if (isExpert)
                                IconButton(
                                  icon: Icon(Icons.thumb_up),
                                  color: Colors.blue,
                                  onPressed: () => _addVote(answerId),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      hintText: 'Tulis jawaban Anda...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addAnswer(_answerController.text.trim()),
                  child: Text('Kirim'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
