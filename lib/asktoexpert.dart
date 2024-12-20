import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartassistant/addasktoexpert.dart';

class ComdevPage extends StatefulWidget {
  @override
  _ComdevPageState createState() => _ComdevPageState();
}

class _ComdevPageState extends State<ComdevPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ask to Expert'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Pertanyaan....',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('askexpert')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Jika data kosong
                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada pertanyaan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                final questions = snapshot.data!.docs;
                final filteredQuestions = questions.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final questionText = data['question'] ?? '';
                  return questionText
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredQuestions.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada pertanyaan yang sesuai dengan pencarian.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredQuestions.length,
                  itemBuilder: (context, index) {
                    final question = filteredQuestions[index];
                    final data = question.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(data['question'] ?? ''),
                        subtitle: Text(data['answer'] ?? 'Belum Dijawab'),
                        trailing: Text(
                          data['status'] == 'answered' ? 'Dijawab' : 'Pending',
                          style: TextStyle(
                            color: data['status'] == 'answered'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        onTap: () {
                          // Tindakan ketika pertanyaan diklik
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddAskToExpertPage()),
            );
          },
          backgroundColor: Colors.amber,
          icon: Icon(Icons.add),
          label: Text("Ajukan Pertanyaan"),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}