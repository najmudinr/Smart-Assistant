import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartassistant/report.dart';

class AddReportPage extends StatefulWidget {
  @override
  _AddReportPageState createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jamMulaiController = TextEditingController();
  final TextEditingController _jamSelesaiController = TextEditingController();
  String? _selectedGudang;
  String? _selectedForeman;
  String _selectedShift = "Shift Belum Ditentukan";
  final List<Map<String, dynamic>> _produkList = [];
  List<String> _foremanList = [];

  final List<String> _gudangOptions = [
    "Gudang Multi Guna",
    "Gudang Pupuk A",
    "Gudang Pupuk B",
  ];

  final List<String> _produkOptions = [
    "NPK KEBOMAS",
    "Phonska+Zn",
    "Urea NS 5 KG",
    "SP 36 @25KG NONSUB",
    "PHOSGREEN",
    "NITREA",
    "UREA SUB",
  ];

  @override
  void initState() {
    super.initState();
    _fetchForemanList();
  }

  Future<void> _fetchForemanList() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('roles', isEqualTo: 'FOREMAN')
          .get();

      final foremanList =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        _foremanList = foremanList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat daftar Foreman: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text =
            "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format waktu ke 24 jam
      final formattedTime =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      setState(() {
        controller.text = formattedTime;
        _updateShiftClassification(); // Update shift jika diperlukan
      });
    }
  }

  void _updateShiftClassification() {
    if (_jamMulaiController.text.isNotEmpty) {
      final timeParts = _jamMulaiController.text.split(":");
      final hour = int.tryParse(timeParts[0]) ?? 0;

      setState(() {
        if (hour >= 7 && hour < 15) {
          _selectedShift = "Shift 1";
        } else if (hour >= 15 && hour < 23) {
          _selectedShift = "Shift 2";
        } else {
          _selectedShift = "Shift Malam";
        }
      });
    }
  }

  void _addProdukRow() {
    setState(() {
      _produkList.add({
        "produk": null,
        "awal": 0,
        "masuk": 0,
        "terlayani": 0,
        "sisa": 0,
      });
    });
  }

  void _removeProdukRow(int index) {
    setState(() {
      _produkList.removeAt(index);
    });
  }

  void _calculateSisa(int index) {
    final awal = _produkList[index]["awal"] ?? 0;
    final masuk = _produkList[index]["masuk"] ?? 0;
    final terlayani = _produkList[index]["terlayani"] ?? 0;

    setState(() {
      _produkList[index]["sisa"] = awal + masuk - terlayani;
    });
  }

  Future<void> _saveToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'tanggal': _tanggalController.text,
        'jamMulai': _jamMulaiController.text,
        'jamSelesai': _jamSelesaiController.text,
        'shift': _selectedShift,
        'gudang': _selectedGudang,
        'foreman': _selectedForeman,
        'produkList': _produkList,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Laporan berhasil ditambahkan')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportAkhirShiftPage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan laporan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Laporan Akhir Shift"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tanggal"),
                TextFormField(
                  controller: _tanggalController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                    hintText: "Pilih tanggal",
                  ),
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Jam Mulai"),
                          TextFormField(
                            controller: _jamMulaiController,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                              hintText: "Pilih jam mulai",
                            ),
                            onTap: () =>
                                _selectTime(context, _jamMulaiController),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Jam Selesai"),
                          TextFormField(
                            controller: _jamSelesaiController,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                              hintText: "Pilih jam selesai",
                            ),
                            onTap: () =>
                                _selectTime(context, _jamSelesaiController),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text("Gudang"),
                DropdownButtonFormField<String>(
                  value: _selectedGudang,
                  items: _gudangOptions
                      .map((gudang) => DropdownMenuItem(
                            value: gudang,
                            child: Text(gudang),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGudang = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Pilih gudang",
                  ),
                ),
                SizedBox(height: 16),
                Text("Foreman"),
                DropdownButtonFormField<String>(
                  value: _selectedForeman,
                  items: _foremanList
                      .map((foreman) => DropdownMenuItem(
                            value: foreman,
                            child: Text(foreman),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedForeman = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Pilih Foreman",
                  ),
                ),
                SizedBox(height: 16),
                Text("Shift: $_selectedShift"),
                SizedBox(height: 16),
                Text("Antrian Truk Muat Akhir Shift:"),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _produkList.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _produkList[index]["produk"],
                            items: _produkOptions
                                .map((produk) => DropdownMenuItem(
                                      value: produk,
                                      child: Text(produk),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _produkList[index]["produk"] = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Pilih produk",
                            ),
                            isExpanded: true,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Awal",
                            ),
                            onChanged: (value) {
                              _produkList[index]["awal"] =
                                  int.tryParse(value) ?? 0;
                              _calculateSisa(index);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Masuk",
                            ),
                            onChanged: (value) {
                              _produkList[index]["masuk"] =
                                  int.tryParse(value) ?? 0;
                              _calculateSisa(index);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Terlayani",
                            ),
                            onChanged: (value) {
                              _produkList[index]["terlayani"] =
                                  int.tryParse(value) ?? 0;
                              _calculateSisa(index);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${_produkList[index]['sisa']}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeProdukRow(index);
                          },
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addProdukRow,
                  child: Text("Tambah Produk"),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _saveToFirestore();
                    }
                  },
                  child: Text("Simpan Laporan"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
