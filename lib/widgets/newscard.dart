import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewsCard extends StatefulWidget {
  final QueryDocumentSnapshot newsData;

  const NewsCard({required this.newsData});

  @override
  _NewsCardState createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isLiking = false;

  Future<void> toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final newsRef = widget.newsData.reference;
    final likedBy = List<String>.from(widget.newsData['likedBy'] ?? []);
    final isAlreadyLiked = likedBy.contains(userId);

    setState(() {
      isLiking = true;
    });

    try {
      if (isAlreadyLiked) {
        // Jika user sudah like, hapus like
        await newsRef.update({
          'likesCount': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        // Jika user belum like, tambahkan like
        await newsRef.update({
          'likesCount': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      print("Error updating likes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan saat memproses like.")),
      );
    } finally {
      setState(() {
        isLiking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final likesCount = widget.newsData['likesCount'] ?? 0;
    final likedBy = List<String>.from(widget.newsData['likedBy'] ?? []);
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
            // Header
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
                      widget.newsData['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.newsData['roles'],
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
            // Title
            Text(
              widget.newsData['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            // Content
            Text(
              widget.newsData['content'],
              style: TextStyle(fontSize: 14, color: Colors.black),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16),
            // Footer
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
                Text(
                  widget.newsData['timeAgo'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
