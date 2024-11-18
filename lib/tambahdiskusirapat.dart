import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahDiskusiPage extends StatefulWidget {
  @override
  _TambahDiskusiPageState createState() => _TambahDiskusiPageState();
}

class _TambahDiskusiPageState extends State<TambahDiskusiPage> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _dateController = TextEditingController();
  String? _selectedTeamLeader;
  final List<String> _selectedParticipants = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Diskusi'),
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
                  decoration: InputDecoration(labelText: 'Tema Diskusi'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tema diskusi harus diisi.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(labelText: 'Tanggal'),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      _dateController.text = date.toLocal().toString().split(' ')[0];
                    }
                  },
                ),
                SizedBox(height: 16),
                // Team Leader Selection
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final users = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Pilih Team Leader'),
                      items: users.map((user) {
                        final userData = user.data() as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: user.id,
                          child: Text(userData['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTeamLeader = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Team leader harus dipilih.';
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 16),
                // Participants Selection
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final users = snapshot.data!.docs;
                    return Wrap(
                      spacing: 8,
                      children: users.map((user) {
                        final userData = user.data() as Map<String, dynamic>;
                        return FilterChip(
                          label: Text(userData['name']),
                          selected: _selectedParticipants.contains(user.id),
                          onSelected: (isSelected) {
                            setState(() {
                              if (isSelected) {
                                _selectedParticipants.add(user.id);
                              } else {
                                _selectedParticipants.remove(user.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await FirebaseFirestore.instance.collection('rapat').add({
                        'topic': _topicController.text,
                        'date': _dateController.text,
                        'teamLeaderId': _selectedTeamLeader,
                        'participants': _selectedParticipants,
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}