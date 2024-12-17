import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowUpForm extends StatefulWidget {
  final String taskId;
  final VoidCallback onPlanAdded;

  const FollowUpForm({
    required this.taskId,
    required this.onPlanAdded,
    super.key,
  });

  @override
  _FollowUpFormState createState() => _FollowUpFormState();
}

class _FollowUpFormState extends State<FollowUpForm> {
  final List<TextEditingController> _controllers = [];

  // Fungsi untuk menyimpan rencana tindak lanjut
  Future<void> saveFollowUpPlans() async {
    try {
      for (var controller in _controllers) {
        if (controller.text.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('tasks')
              .doc(widget.taskId) // Mengakses taskId dari widget
              .collection('followUpPlans')
              .add({
            'plan': controller.text,
            'status': 'Pending',
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rencana tindak lanjut berhasil ditambahkan!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error saving follow-up plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan rencana tindak lanjut')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.taskId.isEmpty) {
      print('Task ID tidak valid!');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rencana Aktivitas Tindak Lanjut'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _controllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          decoration: InputDecoration(
                            labelText: 'Rencana Aktivitas ${index + 1}',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _controllers[index].dispose();
                            _controllers.removeAt(index);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _controllers.add(TextEditingController());
                });
              },
              icon: Icon(Icons.add),
              label: Text('Tambah Aktivitas'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveFollowUpPlans, // Memanggil fungsi tanpa parameter
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
