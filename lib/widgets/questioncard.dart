import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartassistant/newsevenpage.dart';

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
                    Text(
                      widget.questionData['roles'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              widget.questionData['questions'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.questionData['details'],
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