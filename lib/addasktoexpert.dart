import 'package:flutter/material.dart';

class AddComdevPage extends StatefulWidget {
  @override
  State<AddComdevPage> createState() => _AddComdevPageState();
}

class _AddComdevPageState extends State<AddComdevPage> {
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = false;
  List<String> _suggestedQuestions = []; // Contoh data dummy, bisa diganti dengan real data

  // Function to simulate fetching suggested questions
  void _fetchSuggestedQuestions(String query) {
    setState(() {
      _suggestedQuestions = [
        "Apa itu Flutter?",
        "Bagaimana cara menggunakan Firebase?",
        "Apa kelebihan Dart dibandingkan JavaScript?"
      ];
    });
  }

  // Function to handle submitting the question
  void _submitQuestion() {
    setState(() {
      _isLoading = true;
    });

    // Simulate a delay for submitting the question
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Show a dialog or redirect to another page
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Pertanyaan Diajukan'),
          content: Text('Pertanyaan Anda telah diajukan ke sistem.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajukan Pertanyaan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _questionController,
              onChanged: _fetchSuggestedQuestions,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ketik pertanyaan Anda di sini...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            if (_suggestedQuestions.isNotEmpty) ...[
              Text(
                'Pertanyaan yang Mungkin Relevan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._suggestedQuestions.map((question) => ListTile(
                    title: Text(question),
                    onTap: () {
                      // User can select a suggested question
                      _questionController.text = question;
                    },
                  )),
            ],
            Spacer(),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitQuestion,
                    child: Text('Ajukan Pertanyaan'),
                  ),
          ],
        ),
      ),
    );
  }
}