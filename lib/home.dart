import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartassistant/absensi.dart';
import 'package:smartassistant/dashboard.dart';
import 'package:smartassistant/login.dart';
import 'package:smartassistant/newsevenpage.dart';
import 'package:smartassistant/product.dart';
import 'package:smartassistant/profil.dart';
import 'package:smartassistant/report.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? userRole;

  Future<String> _fetchUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc['roles'] ?? 'guest'; // Default role jika tidak ditemukan
    }
    return 'guest';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading role: ${snapshot.error}'));
        }

        userRole = snapshot.data; // Set userRole dari hasil Future

        final List<Widget> pages = [
          _buildPage(DashboardPage(userRole: userRole!), 'Dashboard'),
          _buildPage(AbsensiPage(), 'Absensi'),
          _buildPage(NewsEventPage(), 'News & Event'),
          _buildPage(ProductPage(), 'Produk'),
          _buildPage(ReportAkhirShiftPage(), 'Report'),
        ];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.black),
                onPressed: () {},
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.person, color: Colors.black),
                onSelected: (String result) {
                  if (result == 'Logout') {
                    _logout();
                  } else if (result == 'Profile') {
                    _navigateToProfile();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'Profile',
                    child: Text('Profile'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Logout',
                    child: Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
          body: pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time),
                label: 'Absensi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'News & Event',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.production_quantity_limits),
                label: 'Produk',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.report),
                label: 'Report',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            backgroundColor: Color.fromRGBO(239, 175, 12, 100),
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging out: $e');
      }
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  static Widget _buildPage(Widget page, String title) {
    return Scaffold(
      body: page,
    );
  }
}


