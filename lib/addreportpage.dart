import 'package:flutter/material.dart';

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
  final List<Map<String, dynamic>> _produkList = [];

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
  void dispose() {
    _tanggalController.dispose();
    _jamMulaiController.dispose();
    _jamSelesaiController.dispose();
    super.dispose();
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
        _tanggalController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
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
                // Input tanggal
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tanggal harus diisi";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Input jam mulai dan jam selesai
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
                            onTap: () => _selectTime(context, _jamMulaiController),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Jam mulai harus diisi";
                              }
                              return null;
                            },
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
                            onTap: () => _selectTime(context, _jamSelesaiController),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Jam selesai harus diisi";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Dropdown untuk gudang
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Gudang harus dipilih";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Tabel input produk
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
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _produkList[index]["awal"].toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Awal",
                            ),
                            onChanged: (value) {
                              _produkList[index]["awal"] = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _produkList[index]["masuk"].toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Masuk",
                            ),
                            onChanged: (value) {
                              _produkList[index]["masuk"] = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _produkList[index]["terlayani"].toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Terlayani",
                            ),
                            onChanged: (value) {
                              _produkList[index]["terlayani"] = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _produkList[index]["sisa"].toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Sisa",
                            ),
                            onChanged: (value) {
                              _produkList[index]["sisa"] = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _addProdukRow,
                    child: Text("Tambah Produk"),
                  ),
                ),
                SizedBox(height: 24),

                // Tombol simpan
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print("Data valid, simpan ke database...");
                      }
                    },
                    child: Text("Simpan"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
