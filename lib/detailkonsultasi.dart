import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartassistant/services/inputfoto.dart';

class DetailConsultationPage extends StatefulWidget {
  final String consultationId;

  const DetailConsultationPage({required this.consultationId});

  @override
  _DetailConsultationPageState createState() => _DetailConsultationPageState();
}

class _DetailConsultationPageState extends State<DetailConsultationPage> {
  final TextEditingController _messageController = TextEditingController();
  String? description;

  Future<void> _selectImageFromCamera() async {
    File? image = await FileUtils.pickImageFromCamera();
    if (image != null) {
      print('Gambar dari kamera: ${image.path}');
    }
  }

// Mengambil gambar dari galeri
  Future<void> _selectImageFromGallery() async {
    File? image = await FileUtils.pickImageFromGallery();
    if (image != null) {
      print('Gambar dari galeri: ${image.path}');
    }
  }

// Memilih file
  Future<void> _selectFile() async {
    File? file = await FileUtils.pickFile();
    if (file != null) {
      print('File yang dipilih: ${file.path}');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDescription();
  }

  void _loadDescription() async {
    DocumentSnapshot consultationSnapshot = await FirebaseFirestore.instance
        .collection('consultations')
        .doc(widget.consultationId)
        .get();

    setState(() {
      description = consultationSnapshot['description'];
    });
  }

  Future<String> getUserName(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedName = prefs.getString('userName_$userId');

    if (cachedName != null) {
      return cachedName;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        String name = userDoc['name'] ?? 'Nama tidak tersedia';
        prefs.setString('userName_$userId', name);
        return name;
      } else {
        return 'Nama tidak tersedia';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Error mengambil nama';
    }
  }

  Future<String> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('No user currently logged in');
    }
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    String message = _messageController.text.trim();
    String userId = await getCurrentUserId();

    await FirebaseFirestore.instance
        .collection('consultations')
        .doc(widget.consultationId)
        .collection('messages')
        .add({
      'senderId': userId,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Konsultasi"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double fontSizeMultiplier = constraints.maxWidth < 600 ? 1.0 : 1.2;
          double paddingMultiplier = constraints.maxWidth < 600 ? 0.04 : 0.02;

          return Padding(
            padding: EdgeInsets.all(constraints.maxWidth * paddingMultiplier),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('consultations')
                  .doc(widget.consultationId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var consultationData =
                    snapshot.data!.data() as Map<String, dynamic>?;
                var atasanUserId = consultationData?['atasan'];
                var topic =
                    consultationData?['topic'] ?? 'Topik tidak tersedia';
                var priority =
                    consultationData?['priority'] ?? 'Prioritas tidak tersedia';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: atasanUserId != null
                          ? getUserName(atasanUserId)
                          : Future.value('Atasan tidak tersedia'),
                      builder: (context, atasanSnapshot) {
                        var atasanName =
                            atasanSnapshot.data ?? 'Nama tidak tersedia';
                        return Text(
                          "Nama Atasan: $atasanName",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16 * fontSizeMultiplier,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Text(
                      'Topik: "$topic"',
                      style: TextStyle(fontSize: 14 * fontSizeMultiplier),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Text(
                      'Prioritas: $priority',
                      style: TextStyle(
                        fontSize: 14 * fontSizeMultiplier,
                        color: priority == "Rendah" ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(thickness: 1, color: Colors.black),
                    if (description != null)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: constraints.maxHeight * 0.01),
                        child: Text(
                          "Deskripsi: \"$description\"",
                          style: TextStyle(
                              fontSize: 14 * fontSizeMultiplier,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600]),
                        ),
                      ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('consultations')
                            .doc(widget.consultationId)
                            .collection('messages')
                            .orderBy('timestamp')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          var messages = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              var message = messages[index];
                              var senderId = message['senderId'];
                              var text = message['text'];
                              var timestamp = message['timestamp'] as Timestamp;
                              var formattedTime =
                                  DateFormat('dd MMM yyyy, hh:mm a')
                                      .format(timestamp.toDate());

                              return FutureBuilder<String>(
                                future: getUserName(senderId),
                                builder: (context, userNameSnapshot) {
                                  var userName = userNameSnapshot.data ??
                                      'Nama tidak tersedia';
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: constraints.maxHeight * 0.01),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "$userName: $text",
                                            style: TextStyle(
                                                fontSize:
                                                    14 * fontSizeMultiplier),
                                          ),
                                        ),
                                        Text(
                                          formattedTime,
                                          style: TextStyle(
                                            fontSize: 12 * fontSizeMultiplier,
                                            color: Colors.grey,
                                          ),
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
                    Divider(thickness: 1, color: Colors.black),
                    TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Tambahkan komentar/tanggapan baru...",
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 14 * fontSizeMultiplier),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: () {
                            _selectImageFromCamera();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.attach_file),
                          onPressed: () {
                            _selectFile();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.image),
                          onPressed: () {
                            _selectImageFromGallery();
                          },
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: sendMessage,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
