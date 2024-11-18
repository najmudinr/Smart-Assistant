import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:smartassistant/addkonsultasi.dart';
import 'package:smartassistant/detailkonsultasi.dart';

class ConsultationPage extends StatefulWidget {
  @override
  _ConsultationPageState createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _userRole;

  // List of roles that should use 'atasan' field
  final List<String> atasanRoles = [
    'AVP',
    'SPV',
    'FOREMAN',
  ];

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userSnapshot.exists) {
        setState(() {
          _userRole = userSnapshot['roles'];
        });
      }
      print("Current User UID: ${currentUser.uid}");
      print("User Role: $_userRole");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Konsultasi",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            _buildSearchBar(screenWidth),
            SizedBox(height: screenHeight * 0.02),
            Expanded(child: _buildConsultationList(screenWidth, screenHeight)),
          ],
        ),
      ),
      floatingActionButton: (_userRole == null || _userRole == "AVP")
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddConsultationPage()),
                );
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari konsultasi...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildConsultationList(double screenWidth, double screenHeight) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('consultations')
          .where(
            // If user role is in the list, use 'atasan' field; otherwise use 'userId'
            atasanRoles.contains(_userRole) ? 'atasan' : 'userId',
            isEqualTo: currentUser?.uid,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Tidak ada konsultasi saat ini."));
        }

        var filteredDocs = snapshot.data!.docs.where((doc) {
          var topic = doc['topic'].toString().toLowerCase();
          return topic.contains(_searchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text("Tidak ada konsultasi yang cocok."));
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            return _buildConsultationCard(
                filteredDocs[index], screenWidth, screenHeight);
          },
        );
      },
    );
  }

  Widget _buildConsultationCard(QueryDocumentSnapshot consultation,
      double screenWidth, double screenHeight) {
    Timestamp? timestamp = consultation['timestamp'];
    DateTime dateTime = timestamp?.toDate() ?? DateTime.now();
    String formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);

    String topic = consultation['topic'] ?? 'Unknown Topic';
    String priority = consultation['priority'] ?? 'Unknown';
    String status = consultation['status'] ?? 'Unknown';
    String userId = consultation['userId'] ?? 'Unknown';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('Pengirim tidak ditemukan');
        }

        String userName = snapshot.data!['name'] ?? 'Unknown Name';

        return Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.02),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengirim: $userName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Topik: $topic',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Dimulai pada: $formattedDate',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      color: status == 'Aktif' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    'Prioritas: $priority',
                    style: TextStyle(
                      color: priority == 'Rendah' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailConsultationPage(
                                consultationId: consultation.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Lihat Detail'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
