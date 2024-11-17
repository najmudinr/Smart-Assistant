import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  DateTimeRange? _selectedDateRange;
  String? _selectedWarehouse;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.teal,
              tabs: const [
                Tab(text: "Shipping In/Out"),
                Tab(text: "Performa Produk"),
                Tab(text: "Booked Area"),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Shipping In/Out Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedWarehouse,
                                  decoration: InputDecoration(
                                    labelText: "Pilih Gudang",
                                    border: OutlineInputBorder(),
                                  ),
                                  items: <String>[
                                    'Gudang 1',
                                    'Gudang 2',
                                    'Gudang 3'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedWarehouse = newValue;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDateRange(context),
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: _selectedDateRange == null
                                            ? "Pilih Tanggal"
                                            : "${_selectedDateRange!.start.toLocal()} - ${_selectedDateRange!.end.toLocal()}",
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // Tambahkan logika untuk menampilkan data berdasarkan pilihan
                                print("Gudang: $_selectedWarehouse");
                                print(
                                    "Tanggal: ${_selectedDateRange?.start} - ${_selectedDateRange?.end}");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: Text("Tampilkan"),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Table
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(
                                  label: Container(
                                    color: Colors.orange,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Produk",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.orange,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Stock Awal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.orange,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Produksi",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.orange,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Gudang Penyangga",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.orange,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Ex Impor",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.orange,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Gudang Internal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.orange,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Rebag (+)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.orange,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Adjusment (+)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.orange,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Total Pemasukan",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                              rows: [
                                DataRow(
                                  cells: [
                                    DataCell(Text("NPK PHONSKA PLUS @25KG")),
                                    DataCell(Text("6,986.375")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text("NPK 15-10-12 Sub @50KG")),
                                    DataCell(Text("13,086.700")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text("Urea SUB @50 KG")),
                                    DataCell(Text("11,208.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text("SP 26 NS @25KG")),
                                    DataCell(Text("16,370.200")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text("Nitralite NS @25KG")),
                                    DataCell(Text("1,527.875")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                    DataCell(Text("0.000")),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Performa Produk Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Performa Produk",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(
                                  label: Container(
                                    color: Colors.amber,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Product",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.amber,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Stock Awal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.amber,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Produksi",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.amber,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Total Pemasukan",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                              rows: [
                                DataRow(
                                  cells: [
                                    DataCell(Text("Product 1")),
                                    DataCell(Text("100")),
                                    DataCell(Text("50")),
                                    DataCell(Text("150")),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text("Product 2")),
                                    DataCell(Text("200")),
                                    DataCell(Text("100")),
                                    DataCell(Text("300")),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text("Product 3")),
                                    DataCell(Text("300")),
                                    DataCell(Text("150")),
                                    DataCell(Text("450")),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Booked Area Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Booked Area",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(
                                  label: Container(
                                    color: Colors.blue,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Area",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.blue,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Tanggal Booking",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.blue,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Waktu Booking",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    color: Colors.blue,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Status",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                              rows: [
                                DataRow(
                                  cells: [
                                    DataCell(Text("Area 1")),
                                    DataCell(Text("2023-08-28")),
                                    DataCell(Text("10:00 AM - 12:00 PM")),
                                    DataCell(Text("Confirmed")),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text("Area 2")),
                                    DataCell(Text("2023-08-29")),
                                    DataCell(Text("01:00 PM - 03:00 PM")),
                                    DataCell(Text("Pending")),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text("Area 3")),
                                    DataCell(Text("2023-08-30")),
                                    DataCell(Text("09:00 AM - 11:00 AM")),
                                    DataCell(Text("Cancelled")),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
