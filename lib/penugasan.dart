import 'package:flutter/material.dart';

class PenugasanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Daftar Penugasan',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: [
                  _buildAssignmentCard('Rebag Produk ZK', 'Aminudin to Eduardus Adi P', 'Progress', 'Hari ini'),
                  Divider(),
                  _buildAssignmentCard('Rebag Produk ZK', 'Aminudin to Eduardus Adi P', 'Progress', 'Hari ini'),
                  Divider(),
                  // Add more cards here
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0), // Atur padding bawah untuk menaikkan FAB
        child: FloatingActionButton.extended(
          onPressed: () {
            // Aksi untuk tombol tambah tugas
          },
          backgroundColor: Colors.orange,
          icon: Icon(Icons.add),
          label: Text("Tambah Tugas"),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAssignmentCard(String title, String subtitle, String status, String time) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.check, color: Colors.black),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(time),
          ),
        ],
      ),
    );
  }
}