import 'package:flutter/material.dart';

class TambahIQCPage extends StatefulWidget {
  @override
  _TambahIQCPageState createState() => _TambahIQCPageState();
}

class _TambahIQCPageState extends State<TambahIQCPage> {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _jumlahProdukController = TextEditingController();
  final TextEditingController _asalProdukController = TextEditingController();
  final TextEditingController _noPoController = TextEditingController();
  final TextEditingController _jumlahSamplingController = TextEditingController();

  int _jumlahSampling = 0; // Jumlah baris pada tabel sampling
  List<Map<String, TextEditingController>> _tableDataControllers = [];

  // Fungsi untuk membuka date picker
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

  // Fungsi untuk mengupdate jumlah baris di tabel
  void _updateTableData() {
    setState(() {
      _jumlahSampling = int.tryParse(_jumlahSamplingController.text) ?? 0;
      _tableDataControllers = List.generate(_jumlahSampling, (index) => {
            'sampling': TextEditingController(),
            'keterangan': TextEditingController()
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Laporan IQC'),
        backgroundColor: Colors.white,
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
            _buildTextField('Tanggal', _tanggalController, onTap: () => _pickDate(context), readOnly: true, icon: Icons.calendar_today),
            _buildDropdownField('Shift', ['Shift 1', 'Shift 2', 'Shift 3']),
            _buildTextField('Nama Produk', _namaProdukController),
            _buildTextField('Jumlah Produk', _jumlahProdukController, keyboardType: TextInputType.number),
            _buildTextField('Asal Produk', _asalProdukController),
            _buildTextField('No PO', _noPoController),
            _buildTextField('Jumlah Sampling', _jumlahSamplingController, keyboardType: TextInputType.number, onChanged: (value) => _updateTableData()),
            
            SizedBox(height: 16.0),
            Text('Masukan Kuantum Produk On Spec & Off Spec', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            _buildTable(),

            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('Batal', Colors.red, () {
                  // Aksi untuk tombol Batal
                }),
                _buildButton('Kirim Laporan', Colors.amber, () {
                  // Aksi untuk tombol Kirim Laporan
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {Function()? onTap, bool readOnly = false, IconData? icon, TextInputType keyboardType = TextInputType.text, Function(String)? onChanged}) {
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

  Widget _buildDropdownField(String label, List<String> items) {
    String selectedValue = items[0];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            onChanged: (String? newValue) {
              setState(() {
                selectedValue = newValue!;
              });
            },
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

  Widget _buildTable() {
    return DataTable(
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Input sampling',
                ),
              ),
            ),
            DataCell(
              TextField(
                controller: _tableDataControllers[index]['keterangan'],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Input keterangan',
                ),
              ),
            ),
          ],
        );
      }),
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
}
