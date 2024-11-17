import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartassistant/editprofile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DocumentSnapshot? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  bool _isProfileComplete(Map<String, dynamic> data) {
    return data['email']?.isNotEmpty == true &&
        data['placeOfBirth']?.isNotEmpty == true &&
        data['dateOfBirth']?.isNotEmpty == true &&
        data['address']?.isNotEmpty == true &&
        data['phoneNumber']?.isNotEmpty == true;
  }

  Future<void> _fetchUserProfile() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userProfile = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userProfile.exists) {
          // Periksa apakah data profil lengkap
          if (_isProfileComplete(userProfile.data() as Map<String, dynamic>)) {
            setState(() {
              _userProfile = userProfile;
              _isLoading = false;
            });
          } else {
            // Jika data profil tidak lengkap, arahkan ke EditProfilePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EditProfilePage()),
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to fetch user profile: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.amber,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _userProfile!['name'] ?? 'No Name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _userProfile!['roles'] ?? 'No Roles',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildProfileInfoContainer(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfilePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: Colors.black),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    ),
                    child: Text('Edit Biodata'),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileInfoContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Karyawan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(),
          ProfileInfoRow(
              label: 'Email', value: _userProfile!['email'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Tempat Lahir',
              value: _userProfile!['placeOfBirth'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Tanggal Lahir',
              value: _userProfile!['dateOfBirth'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Gender', value: _userProfile!['gender'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Alamat', value: _userProfile!['address'] ?? 'N/A'),
          ProfileInfoRow(label: 'NIK', value: _userProfile!['nik'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Nomor Handphone',
              value: _userProfile!['phoneNumber'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Pendidikan Terakhir',
              value: _userProfile!['lastEducation'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Nomor BPJS', value: _userProfile!['bpjsNumber'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Nomor BPJS TK',
              value: _userProfile!['bpjsTkNumber'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Nomor Pajak', value: _userProfile!['taxNumber'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Status Kawin',
              value: _userProfile!['maritalStatus'] ?? 'N/A'),
          ProfileInfoRow(
              label: 'Agama', value: _userProfile!['religion'] ?? 'N/A'),
        ],
      ),
    );
  }
}

// Widget untuk baris informasi profil
class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
