import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowUpForm extends StatefulWidget {
  final String taskId;
  final String? followUpId;
  final String? currentPlan;
  final VoidCallback onPlanAdded;
  final VoidCallback onPlanUpdated;

  const FollowUpForm({
    required this.taskId,
    this.followUpId,
    this.currentPlan,
    required this.onPlanAdded,
    super.key,
    required this.onPlanUpdated,
  });

  @override
  _FollowUpFormState createState() => _FollowUpFormState();
}

class _FollowUpFormState extends State<FollowUpForm> {
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    // Jika mode Edit, tambahkan rencana aktivitas lama ke controller pertama
    if (widget.currentPlan != null) {
      final controller = TextEditingController(text: widget.currentPlan);
      _controllers.add(controller);
    } else {
      // Tambahkan satu controller kosong sebagai default
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewInputField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeInputField(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  Future<void> _savePlans() async {
    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .collection('followUpPlans');

      if (widget.followUpId != null) {
        // Update existing plan (reset status to Pending)
        await collectionRef.doc(widget.followUpId).update({
          'plan': _controllers[0].text, // Ambil dari controller pertama
          'status': 'Pending', // Reset status ke Pending
          'updatedAt': FieldValue.serverTimestamp(), // Timestamp update
        });
      } else {
        // Add new follow-up plans
        for (var controller in _controllers) {
          if (controller.text.trim().isNotEmpty) {
            await collectionRef.add({
              'plan': controller.text,
              'status': 'Pending', // Default status
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rencana aktivitas berhasil disimpan')),
      );

      widget.onPlanAdded();
      Navigator.pop(context);
    } catch (e) {
      print('Error saving follow-up plans: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan rencana aktivitas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.followUpId == null
            ? 'Tambah Rencana Aktivitas'
            : 'Edit Rencana Aktivitas'),
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
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeInputField(index),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addNewInputField,
              icon: Icon(Icons.add),
              label: Text('Tambah Rencana Aktivitas'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePlans,
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
