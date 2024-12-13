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
  String searchQuery = "";

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
        reports =
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching reports: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter reports based on search query
    final filteredReports = reports
        .where((report) => searchQuery.isEmpty ||
            report.values
                .join(' ')
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();

    final paginatedReports = filteredReports
        .skip(_currentPage * _rowsPerPage)
        .take(_rowsPerPage)
        .toList();

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? const Center(child: Text("Tidak ada data untuk ditampilkan."))
              : Column(
                  children: [
                    // Filter dan Search
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Text("Show "),
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
                                _currentPage = 0; // Reset to first page
                              });
                            },
                          ),
                          const Text(" entries"),
                          const Spacer(),
                          const Text("Search: "),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (query) {
                                setState(() {
                                  searchQuery = query;
                                  _currentPage = 0; // Reset to first page
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
                          columns: const [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('Tanggal')),
                            DataColumn(label: Text('Shift')),
                            DataColumn(label: Text('Nama Karu')),
                            DataColumn(label: Text('Nama Gudang')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: paginatedReports.asMap().entries.map((entry) {
                            final index = entry.key;
                            final report = entry.value;

                            return DataRow(cells: [
                              DataCell(Text('${_currentPage * _rowsPerPage + index + 1}')),
                              DataCell(Text(report['tanggal'] ?? '-')),
                              DataCell(Text(report['shift'] ?? '-')),
                              DataCell(Text(report['foreman'] ?? '-')),
                              DataCell(Text(report['gudang'] ?? '-')),
                              DataCell(
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'Detail') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailReportPage(
                                            documentId: report['id'], // Gunakan ID dokumen yang valid
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'Detail',
                                      child: Text('Detail'),
                                    ),
                                  ],
                                  child: const Icon(Icons.more_vert),
                                ),
                              ),
                            ]);
                          }).toList(),
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
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _currentPage > 0
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            "Page ${_currentPage + 1} of ${(filteredReports.length / _rowsPerPage).ceil()}",
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: (_currentPage + 1) * _rowsPerPage <
                                    filteredReports.length
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
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}