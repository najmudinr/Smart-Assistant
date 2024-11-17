import 'package:flutter/material.dart';
import 'package:smartassistant/detailreport.dart';

class ReportAkhirShiftPage extends StatefulWidget {
  @override
  _ReportAkhirShiftPageState createState() => _ReportAkhirShiftPageState();
}

class _ReportAkhirShiftPageState extends State<ReportAkhirShiftPage> {
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter dan Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text("Show "),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  items: [10, 20, 30].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _rowsPerPage = value!;
                    });
                  },
                ),
                Text(" entries"),
                Spacer(),
                Text("Search: "),
                SizedBox(
                  width: 150,
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Shift')),
                  DataColumn(label: Text('Nama Karu')),
                  DataColumn(label: Text('Nama Gudang')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: List.generate(10, (index) {
                  return DataRow(cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text('1 Juli 2024')),
                    DataCell(Text('Shift 1')),
                    DataCell(Text('Rifky Isyarah')),
                    DataCell(Text('Gudang Multiguna 1')),
                    DataCell(
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'Detail') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailReportPage(),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'Detail',
                            child: Text('Detail'),
                          ),
                        ],
                        child: Icon(Icons.more_vert),
                      ),
                    ),
                  ],
                  );
                }),
              ),
            ),
          ),
          // Pagination
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _currentPage > 0
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                        }
                      : null,
                ),
                Text("Page ${_currentPage + 1} of 10"),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _currentPage++;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}