import 'package:flutter/material.dart';
import 'package:smartassistant/addasktoexpert.dart';

class ComdevPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ask to Expert'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Pertanyaan....',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text('Pertanyaan Populer 1'),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Pertanyaan Populer 2'),
                  onTap: () {},
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AddComdevPage()));
            // Aksi untuk tombol tambah disposisi
          },
          backgroundColor: Colors.orange,
          icon: Icon(Icons.add),
          label: Text("Ajukan Pertanyaan"),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
