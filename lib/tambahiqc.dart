import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TambahIQCPage extends StatefulWidget {
  @override
  _TambahIQCPageState createState() => _TambahIQCPageState();
}

class _TambahIQCPageState extends State<TambahIQCPage> {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jumlahProdukController = TextEditingController();
  final TextEditingController _asalProdukController = TextEditingController();
  final TextEditingController _noPoController = TextEditingController();
  final TextEditingController _jumlahSamplingController =
      TextEditingController();

  String? _selectedNamaProduk;
  String? _selectedShift;
  int _jumlahSampling = 0;
  double _bobotProduk = 0; // Bobot produk yang dipilih
  List<Map<String, TextEditingController>> _tableDataControllers = [];
  List<String> namaProdukItems = [];

  @override
  void initState() {
    super.initState();
    _fetchNamaProduk();
  }

  Future<void> _fetchNamaProduk() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('products').get();
      setState(() {
        namaProdukItems =
            snapshot.docs.map((doc) => doc['name'].toString()).toList();
        _selectedNamaProduk =
            namaProdukItems.isNotEmpty ? namaProdukItems[0] : null;

        // Ambil bobot dari produk pertama (jika ada)
        if (snapshot.docs.isNotEmpty) {
          _bobotProduk = snapshot.docs.first['weight']?.toDouble() ?? 0;
        }
      });
    } catch (e) {
      print('Error fetching product names: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil daftar nama produk')),
      );
    }
  }

  void _updateTableData() {
    setState(() {
      _jumlahSampling = int.tryParse(_jumlahSamplingController.text) ?? 0;
      _tableDataControllers = List.generate(
          _jumlahSampling,
          (index) => {
                'sampling': TextEditingController(),
                'keterangan': TextEditingController()
              });
    });
  }

  void _validateSampling(int index) {
    // Validasi apakah "On Spec" atau "Off Spec"
    final samplingController = _tableDataControllers[index]['sampling']!;
    final keteranganController = _tableDataControllers[index]['keterangan']!;

    final samplingValue = double.tryParse(samplingController.text) ?? 0;
    final threshold = _bobotProduk + 0.3;

    if (samplingValue >= threshold) {
      keteranganController.text = 'On Spec';
    } else {
      keteranganController.text = 'Off Spec';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Laporan IQC'),
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Tanggal', _tanggalController,
                onTap: () => _pickDate(context),
                readOnly: true,
                icon: Icons.calendar_today),
            _buildDropdownField('Shift', ['Shift 1', 'Shift 2', 'Shift 3'],
                (value) => _selectedShift = value),
            _buildDropdownField('Nama Produk', namaProdukItems, (value) {
              setState(() {
                _selectedNamaProduk = value;

                // Update bobot produk berdasarkan nama yang dipilih
                _fetchWeightForSelectedProduct(value!);
              });
            }),
            _buildTextField('Jumlah Produk (Ton)', _jumlahProdukController,
                keyboardType: TextInputType.number),
            _buildTextField('Asal Produk', _asalProdukController),
            _buildTextField('No PO', _noPoController),
            _buildTextField('Jumlah Sampling', _jumlahSamplingController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateTableData()),
            SizedBox(height: 16.0),
            Text('Masukan Kuantum Produk On Spec & Off Spec',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            _buildTable(),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                    'Batal', Colors.red, () => Navigator.of(context).pop()),
                _buildButton('Kirim Laporan', Colors.amber, _saveToFirestore),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchWeightForSelectedProduct(String selectedName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: selectedName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _bobotProduk = snapshot.docs.first['weight']?.toDouble() ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching product weight: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil bobot produk')),
      );
    }
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('Masukan Kuantum Sampling')),
          DataColumn(label: Text('Keterangan')),
        ],
        rows: List<DataRow>.generate(_jumlahSampling, (index) {
          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(
                TextField(
                  controller: _tableDataControllers[index]['sampling'],
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _validateSampling(index),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Input sampling'),
                ),
              ),
              DataCell(
                TextField(
                  controller: _tableDataControllers[index]['keterangan'],
                  readOnly: true,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {Function()? onTap,
      bool readOnly = false,
      IconData? icon,
      TextInputType keyboardType = TextInputType.text,
      Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.isNotEmpty ? items[0] : null,
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _tanggalController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _saveToFirestore() async {
    try {
      // Ambil informasi pengguna yang sedang login
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengguna tidak terautentikasi')),
        );
        return;
      }

      final List<Map<String, dynamic>> samplingData =
          _tableDataControllers.map((data) {
        return {
          'sampling': data['sampling']!.text,
          'keterangan': data['keterangan']!.text,
        };
      }).toList();

      await FirebaseFirestore.instance.collection('iqc_data').add({
        'tanggal': _tanggalController.text,
        'shift': _selectedShift,
        'nama_produk': _selectedNamaProduk,
        'jumlah_produk': _jumlahProdukController.text,
        'asal_produk': _asalProdukController.text,
        'no_po': _noPoController.text,
        'user_id': user.uid, // Simpan UID pengguna
        'user_email': user.email, // Simpan email pengguna
        'sampling_data': samplingData,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Laporan berhasil disimpan.')));
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan laporan: $e')),
      );
    }
  }
}
