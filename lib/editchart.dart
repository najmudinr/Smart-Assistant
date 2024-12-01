import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminInputPage extends StatefulWidget {
  @override
  _AdminInputPageState createState() => _AdminInputPageState();
}

class _AdminInputPageState extends State<AdminInputPage> {
  final TextEditingController _totalCapacityController = TextEditingController();
  final TextEditingController _usedCapacityController = TextEditingController();
  final TextEditingController _freeCapacityController = TextEditingController();

  String _selectedGudang = 'internal'; // Default: Gudang Internal
  String? _selectedNamaGudang; // Nama Gudang yang Dipilih
  List<String> _namaGudangList = []; // Daftar Nama Gudang

  @override
  void initState() {
    super.initState();
    _fetchNamaGudang(); // Ambil data nama gudang saat halaman dibuka
  }

  // Ambil daftar nama gudang dari Firestore
  Future<void> _fetchNamaGudang() async {
    String collection = _selectedGudang == 'internal' 
        ? 'gudang_internal' 
        : 'gudang_external';

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
      List<String> fetchedList = snapshot.docs
          .map((doc) => doc['name'].toString())
          .toSet() // Hilangkan duplikasi jika ada
          .toList();

      setState(() {
        _namaGudangList = fetchedList;
        // Tetapkan nilai default hanya jika daftar tidak kosong
        if (_namaGudangList.isNotEmpty) {
          _selectedNamaGudang = _namaGudangList[0];
        } else {
          _selectedNamaGudang = null;
        }
      });
    } catch (e) {
      print("Error fetching gudang names: $e");
      setState(() {
        _namaGudangList = [];
        _selectedNamaGudang = null;
      });
    }
  }

  // Simpan data ke Firestore
  void _saveData() async {
    if (_selectedNamaGudang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih nama gudang terlebih dahulu!')),
      );
      return;
    }

    String collection = _selectedGudang == 'internal' 
        ? 'gudang_internal' 
        : 'gudang_external';

    try {
      await FirebaseFirestore.instance.collection(collection).add({
        'name': _selectedNamaGudang, // Nama Gudang dari Dropdown
        'total_capacity': int.parse(_totalCapacityController.text),
        'used_capacity': int.parse(_usedCapacityController.text),
        'free_capacity': int.parse(_freeCapacityController.text),
      });

      // Clear input fields after saving
      _totalCapacityController.clear();
      _usedCapacityController.clear();
      _freeCapacityController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil disimpan ke $collection')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Validasi untuk memastikan nilai _selectedNamaGudang cocok
    if (_selectedNamaGudang != null && !_namaGudangList.contains(_selectedNamaGudang)) {
      _selectedNamaGudang = _namaGudangList.isNotEmpty ? _namaGudangList[0] : null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Data Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown untuk memilih gudang internal/eksternal
            DropdownButton<String>(
              value: _selectedGudang,
              items: [
                DropdownMenuItem(
                  value: 'internal',
                  child: Text('Gudang Internal'),
                ),
                DropdownMenuItem(
                  value: 'external',
                  child: Text('Gudang External'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGudang = value!;
                  _fetchNamaGudang(); // Ambil nama gudang sesuai koleksi yang dipilih
                });
              },
            ),
            SizedBox(height: 16),

            // Dropdown untuk memilih nama gudang
            if (_namaGudangList.isEmpty)
              Text('Tidak ada nama gudang tersedia.')
            else
              DropdownButton<String>(
                value: _selectedNamaGudang,
                items: _namaGudangList
                    .map((nama) => DropdownMenuItem(
                          value: nama,
                          child: Text(nama),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedNamaGudang = value;
                  });
                },
              ),
            SizedBox(height: 16),

            // Input kapasitas total
            TextField(
              controller: _totalCapacityController,
              decoration: InputDecoration(labelText: 'Kapasitas Total'),
              keyboardType: TextInputType.number,
            ),

            // Input kapasitas terpakai
            TextField(
              controller: _usedCapacityController,
              decoration: InputDecoration(labelText: 'Kapasitas Terpakai'),
              keyboardType: TextInputType.number,
            ),

            // Input kapasitas tersedia
            TextField(
              controller: _freeCapacityController,
              decoration: InputDecoration(labelText: 'Kapasitas Tersedia'),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 16),

            // Tombol simpan
            ElevatedButton(
              onPressed: _saveData,
              child: Text('Simpan Data'),
            ),
          ],
        ),
      ),
    );
  }
}
