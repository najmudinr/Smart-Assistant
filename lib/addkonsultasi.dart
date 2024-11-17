import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartassistant/konsultasi.dart';

class AddConsultationPage extends StatefulWidget {
  @override
  _AddConsultationPageState createState() => _AddConsultationPageState();
}

class _AddConsultationPageState extends State<AddConsultationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _priority = 'Rendah';
  String? _selectedAtasan;
  String? _uploadedFileUrl;
  String? _userRole;
  String? _mainRole; // Variable untuk menyimpan mainRole pengguna

  @override
  void initState() {
    super.initState();
    _getUserRoleAndMainRole();
  }

  Future<void> _getUserRoleAndMainRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userRole = userDoc['roles'];
        _mainRole = userDoc['mainRole']; // Ambil mainRole dari Firestore
      });
    }
  }

  Future<List<QueryDocumentSnapshot>> _fetchAtasan() async {
    if (_mainRole == null) return [];

    List<String> rolesAtasan = [];
    switch (_mainRole) {
      case 'STAFF_OPERASIONAL':
        rolesAtasan = ['FOREMAN', 'SPV', 'AVP'];
      case 'FOREMAN':
        rolesAtasan = ['SPV', 'AVP'];
      case 'SPV':
        rolesAtasan = ['AVP'];
      case 'AVP':
        return []; // AVP tidak memiliki atasan lebih tinggi
      default:
        print("Tidak ada atasan yang tersedia untuk mainRole $_mainRole.");
        return [];
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('roles', whereIn: rolesAtasan)
          .get();

      if (snapshot.docs.isEmpty) {
        print("Tidak ditemukan data atasan untuk roles: $rolesAtasan.");
      } else {
        print("Ditemukan ${snapshot.docs.length} atasan dengan roles $rolesAtasan.");
      }

      return snapshot.docs;
    } catch (e) {
      print("Error saat mengambil data atasan: $e");
      return [];
    }
  }

  Future<void> _submitConsultation() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        DocumentReference consultationRef =
            await FirebaseFirestore.instance.collection('consultations').add({
          'userId': user?.uid,
          'userRole': _userRole,
          'topic': _topicController.text,
          'description': _descriptionController.text,
          'priority': _priority,
          'atasan': _selectedAtasan,
          'fileUrl': _uploadedFileUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'Aktif',
        });

        await FirebaseFirestore.instance.collection('notifications').add({
          'receiverId': _selectedAtasan,
          'consultationId': consultationRef.id,
          'message': 'Anda menerima konsultasi baru dari ${user?.email}',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sukses'),
            content: Text('Konsultasi berhasil diajukan.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ConsultationPage(),
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Gagal mengajukan konsultasi: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Konsultasi Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _topicController,
                  decoration: InputDecoration(labelText: 'Topik Konsultasi'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tulis topik konsultasi di sini';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tulis deskripsi di sini';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Text('Prioritas :'),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Rendah',
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    Text('Rendah'),
                    Radio<String>(
                      value: 'Tinggi',
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    Text('Tinggi'),
                  ],
                ),
                FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _fetchAtasan(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('Tidak ada data atasan');
                    }
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Tujuan'),
                      items: snapshot.data!
                          .map((atasan) => DropdownMenuItem(
                                value: atasan.id,
                                child: Text(atasan['name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAtasan = value;
                        });
                      },
                      value: _selectedAtasan,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih atasan';
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitConsultation,
                    child: Text('Ajukan Konsultasi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
