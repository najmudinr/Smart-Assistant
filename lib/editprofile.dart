import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController _usernameController = TextEditingController(text: "eripras11");
  final TextEditingController _tempatLahirController = TextEditingController(text: "Gresik");
  final TextEditingController _tanggalLahirController = TextEditingController(text: "01/10/2000");
  final TextEditingController _alamatController = TextEditingController(text: "Jalan dimana mana hatiku senank");
  final TextEditingController _nomorRTController = TextEditingController(text: "001");
  final TextEditingController _nikController = TextEditingController(text: "3525131290123232");
  final TextEditingController _nomorHpController = TextEditingController(text: "081220090901");
  final TextEditingController _pendidikanTerakhirController = TextEditingController(text: "SMA");
  final TextEditingController _nomorBPJSController = TextEditingController(text: "00018920303");
  final TextEditingController _nomorBPJSTKController = TextEditingController(text: "230012234");
  final TextEditingController _nomorPajakController = TextEditingController(text: "626383949572849234");

  // Dropdown selections
  String _selectedGender = 'Laki - laki';
  String _selectedStatusKawin = 'Kawin';
  String _selectedAgama = 'Islam';

  // Options for dropdown menus
  final List<String> _genderOptions = ['Laki - laki', 'Perempuan'];
  final List<String> _statusKawinOptions = ['Kawin', 'Belum Kawin'];
  final List<String> _agamaOptions = ['Islam', 'Kristen', 'Hindu', 'Buddha', 'Lainnya'];

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 10),
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
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
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
                controller: _nomorRTController,
                decoration: InputDecoration(labelText: 'Nomor RT'),
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
