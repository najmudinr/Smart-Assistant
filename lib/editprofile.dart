import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _nomorHpController = TextEditingController();
  final TextEditingController _pendidikanTerakhirController = TextEditingController();
  final TextEditingController _nomorBPJSController = TextEditingController();
  final TextEditingController _nomorBPJSTKController = TextEditingController();
  final TextEditingController _nomorPajakController = TextEditingController();

  // Dropdown selections
  String _selectedGender = 'Laki - laki';
  String _selectedStatusKawin = 'Kawin';
  String _selectedAgama = 'Islam';

  // Options for dropdown menus
  final List<String> _genderOptions = ['Laki - laki', 'Perempuan'];
  final List<String> _statusKawinOptions = ['Kawin', 'Belum Kawin'];
  final List<String> _agamaOptions = ['Islam', 'Kristen', 'Hindu', 'Buddha', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Ambil user ID dari FirebaseAuth
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Ambil data dari Firestore berdasarkan UID
        DocumentSnapshot userProfile = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userProfile.exists) {
          Map<String, dynamic> data = userProfile.data() as Map<String, dynamic>;

          setState(() {
            _emailController.text = data['email'] ?? '';
            _tempatLahirController.text = data['placeOfBirth'] ?? '';
            _tanggalLahirController.text = data['dateOfBirth'] ?? '';
            _alamatController.text = data['address'] ?? '';
            _nikController.text = data['nik'] ?? '';
            _nomorHpController.text = data['phoneNumber'] ?? '';
            _pendidikanTerakhirController.text = data['lastEducation'] ?? '';
            _nomorBPJSController.text = data['bpjsNumber'] ?? '';
            _nomorBPJSTKController.text = data['bpjsTkNumber'] ?? '';
            _nomorPajakController.text = data['taxNumber'] ?? '';
            _selectedGender = data['gender'] ?? 'Laki - laki';
            _selectedStatusKawin = data['statusKawin'] ?? 'Kawin';
            _selectedAgama = data['religion'] ?? 'Islam';
          });
        } else {
          print('User profile does not exist');
        }
      } else {
        print('No user is currently logged in');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _tempatLahirController,
                decoration: InputDecoration(labelText: 'Tempat Lahir'),
              ),
              TextFormField(
                controller: _tanggalLahirController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
              DropdownButtonFormField(
                value: _selectedGender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: _genderOptions.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
              ),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
              ),
              TextFormField(
                controller: _nikController,
                decoration: InputDecoration(labelText: 'NIK'),
              ),
              TextFormField(
                controller: _nomorHpController,
                decoration: InputDecoration(labelText: 'Nomor Handphone'),
              ),
              TextFormField(
                controller: _pendidikanTerakhirController,
                decoration: InputDecoration(labelText: 'Pendidikan Terakhir'),
              ),
              TextFormField(
                controller: _nomorBPJSController,
                decoration: InputDecoration(labelText: 'Nomor BPJS'),
              ),
              TextFormField(
                controller: _nomorBPJSTKController,
                decoration: InputDecoration(labelText: 'Nomor BPJS TK'),
              ),
              TextFormField(
                controller: _nomorPajakController,
                decoration: InputDecoration(labelText: 'Nomor Pajak'),
              ),
              DropdownButtonFormField(
                value: _selectedStatusKawin,
                decoration: InputDecoration(labelText: 'Status Kawin'),
                items: _statusKawinOptions.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatusKawin = newValue!;
                  });
                },
              ),
              DropdownButtonFormField(
                value: _selectedAgama,
                decoration: InputDecoration(labelText: 'Agama'),
                items: _agamaOptions.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedAgama = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save profile changes logic here
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
