import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartassistant/addreportpage.dart';
import 'package:smartassistant/detailreport.dart';

class ReportAkhirShiftPage extends StatefulWidget {
  @override
  _ReportAkhirShiftPageState createState() => _ReportAkhirShiftPageState();
}

class _ReportAkhirShiftPageState extends State<ReportAkhirShiftPage> {
  int _currentPage = 0;
  int _rowsPerPage = 10;
  String? userRole;
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    fetchReports();
  }

  Future<void> fetchUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          userRole = doc['roles'];
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> fetchReports() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('reports').get();
      setState(() {
        reports = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching reports: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? Center(child: Text("Tidak ada data untuk ditampilkan."))
              : Column(
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
                              onChanged: (query) {
                                setState(() {
                                  reports = reports
                                      .where((report) => report.values
                                          .join(' ')
                                          .toLowerCase()
                                          .contains(query.toLowerCase()))
                                      .toList();
                                });
                              },
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
                          rows: reports
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final report = entry.value;
                                return DataRow(cells: [
                                  DataCell(Text('${index + 1}')),
                                  DataCell(Text(report['tanggal'] ?? '-')),
                                  DataCell(Text(report['shift'] ?? '-')),
                                  DataCell(Text(report['nama_karu'] ?? '-')),
                                  DataCell(Text(report['nama_gudang'] ?? '-')),
                                  DataCell(
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'Detail') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailReportPage(),
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
                                ]);
                              })
                              .toList()
                              .take(_rowsPerPage)
                              .toList(),
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
                          Text(
                            "Page ${_currentPage + 1} of ${reports.isNotEmpty ? (_rowsPerPage / reports.length).ceil() : 1}",
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: reports.isNotEmpty &&
                                    (_currentPage + 1) * _rowsPerPage <
                                        reports.length
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: (userRole == 'FOREMAN' || userRole == 'Checker')
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddReportPage()));
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
