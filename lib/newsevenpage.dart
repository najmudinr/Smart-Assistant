import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartassistant/addcommunity.dart';
import 'package:smartassistant/addnews.dart';
import 'package:smartassistant/widgets/newscard.dart';

class NewsEventPage extends StatefulWidget {
  @override
  _NewsEventPageState createState() => _NewsEventPageState();
}

class _NewsEventPageState extends State<NewsEventPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Jumlah tab
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: TabBar(
            controller: _tabController,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(text: "Berita dan Pengumuman"),
              Tab(text: "Tanya Komunitas"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab "Berita dan Pengumuman"
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('news').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("Belum ada berita yang tersedia."),
                  );
                }

                final newsList = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    final news = newsList[index];
                    return NewsCard(
                      newsData: news,
                    );
                  },
                );
              },
            ),

            // Tab "Tanya Komunitas"
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('questions')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("Belum ada pertanyaan di komunitas."),
                  );
                }

                final questionsList = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: questionsList.length,
                  itemBuilder: (context, index) {
                    final question = questionsList[index];
                    return QuestionCard(questionData: question);
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amber,
          onPressed: () {
            if (_tabController.index == 0) {
              // Tab pertama (Berita dan Pengumuman)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNewsPage()),
              );
            } else {
              // Tab kedua (Tanya Komunitas)
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddCommunityQuestionPage()),
              );
            }
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class CommentSection extends StatefulWidget {
  final String questionId; // ID dari pertanyaan

  const CommentSection({required this.questionId});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Mengambil nama pengguna dari koleksi 'users' di Firestore
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName =
          userSnapshot['name'] ?? 'Anonymous'; // Menggunakan 'name'

      final commentData = {
        'userId': user.uid,
        'name': userName, // Menyimpan nama pengguna yang sudah didapatkan
        'comment': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Menambahkan komentar ke Firestore
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(widget.questionId)
          .collection('comments')
          .add(commentData);

      _commentController.clear();
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input untuk komentar
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "Tambahkan komentar...",
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: Colors.teal),
                onPressed: _addComment,
              ),
            ),
          ),
          SizedBox(height: 16),

          // Menampilkan daftar komentar
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('questions')
                .doc(widget.questionId)
                .collection('comments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text("Belum ada komentar.");
              }

              final comments = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    title: Text(
                      comment['name'] ??
                          'Anonymous', // Menampilkan nama pengguna
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(comment['comment']),
                    trailing: Text(
                      (comment['timestamp'] as Timestamp?)
                              ?.toDate()
                              .toString()
                              .split('.')[0] ??
                          '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  final QueryDocumentSnapshot questionData;

  const QuestionCard({required this.questionData});

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool isLiking = false;

  Future<void> toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final questionRef = widget.questionData.reference;
    final likedBy = List<String>.from(widget.questionData['likedBy'] ?? []);
    final isAlreadyLiked = likedBy.contains(userId);

    setState(() {
      isLiking = true;
    });

    try {
      if (isAlreadyLiked) {
        await questionRef.update({
          'likesCount': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        await questionRef.update({
          'likesCount': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      print("Error updating likes: $e");
    } finally {
      setState(() {
        isLiking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final likesCount = widget.questionData['likesCount'] ?? 0;
    final likedBy = List<String>.from(widget.questionData['likedBy'] ?? []);
    final user = FirebaseAuth.instance.currentUser;
    final isAlreadyLiked = user != null && likedBy.contains(user.uid);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 20,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.questionData['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              widget.questionData['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.questionData['content'],
              style: TextStyle(fontSize: 14, color: Colors.black),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isAlreadyLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: isAlreadyLiked ? Colors.teal : Colors.grey,
                      ),
                      onPressed: isLiking ? null : toggleLike,
                    ),
                    Text(
                      "$likesCount",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.comment, color: Colors.teal),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) =>
                          CommentSection(questionId: widget.questionData.id),
                    );
                    // Tambahkan fitur komentar
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
