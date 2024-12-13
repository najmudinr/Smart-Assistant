import 'package:flutter/material.dart';

class AddTaskForm extends StatefulWidget {
  @override
  _AddTaskFormState createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Tambah Tugas", style: TextStyle(fontSize: 20)),
            TextFormField(
              controller: _taskNameController,
              decoration: InputDecoration(labelText: 'Nama Tugas'),
            ),
            ElevatedButton(
              onPressed: () => _saveTask(context),
              child: Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }

  void _saveTask(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Save task logic
      Navigator.pop(context);
    }
  }
}
