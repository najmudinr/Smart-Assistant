import 'package:flutter/material.dart';

class DetailDiskusiRapatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Detail Diskusi Rapat'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tema Diskusi
              Text(
                'Tema diskusi : Rapat Bagian Gudang III',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Tanggal Pelaksanaan : 10 Oktober 2024'),
              SizedBox(height: 16),
              // Peserta
              Row(
                children: [
                  Text('Peserta : '),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan nama peserta',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text('Moderator/Team Leader :'),
              SizedBox(height: 16),
              // Penyampaian Team Leader
              Container(
                width: screenWidth,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penyampaian Team Leader:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Lorem Ipsum adalah contoh teks atau dummy dalam industri percetakan dan penataan huruf atau typesetting.',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2. Tambahkan catatan di sini',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Penyampaian Peserta Rapat
              Container(
                width: screenWidth,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.orange[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penyampaian Peserta Rapat:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Eri Pras:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '   Lorem Ipsum adalah contoh teks atau dummy dalam industri percetakan dan penataan huruf atau typesetting.',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. Eri Pras:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '   Lorem Ipsum adalah contoh teks atau dummy dalam industri percetakan dan penataan huruf atau typesetting.',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3. Tambahkan catatan di sini',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Arahan Team Leader
              Container(
                width: screenWidth,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arahan Team Leader:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Lorem Ipsum adalah contoh teks atau dummy dalam industri percetakan dan penataan huruf atau typesetting.',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2. Tambahkan arahan di sini.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Footer note
              Text(
                '*Mohon dipastikan kelengkapan catatan dari seluruh peserta sebelum rapat ditutup.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}