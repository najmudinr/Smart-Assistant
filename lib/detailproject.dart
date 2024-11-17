import 'package:flutter/material.dart';

class ProjectManagementDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Project Management Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    0: FlexColumnWidth(40.0),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(2),
                    5: FlexColumnWidth(2),
                    6: FlexColumnWidth(1.5),
                    7: FlexColumnWidth(1.5),
                    8: FlexColumnWidth(1),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        _buildTableCell('No', isHeader: true),
                        _buildTableCell('List Of Work', isHeader: true),
                        _buildTableCell('PIC', isHeader: true),
                        _buildTableCell('Sequence', isHeader: true),
                        _buildTableCell('Condition to Start Work',
                            isHeader: true),
                        _buildTableCell('Requirement of Work', isHeader: true),
                        _buildTableCell('Supervising By', isHeader: true),
                        _buildTableCell('Status', isHeader: true),
                      ],
                    ),
                    _buildTableRow('1', 'Preparasi'),
                    _buildTableRow('2', 'Penyiapan RKS'),
                    _buildTableRow('3', 'Design & Kebutuhan'),
                    _buildTableRow('4', 'Perhitungan Anggaran'),
                    _buildTableRow('5', 'Tender Projek dan Evaluasi Vendor'),
                    _buildTableRow('6', 'Mulai Project'),
                    _buildTableRow('6.a', 'Penyiapan Material'),
                    _buildTableRow('6.b', 'Alur Proses dan Desain Proses'),
                    _buildTableRow('6.c', 'Konfigurasi Project'),
                    _buildTableRow('6.d', 'Testing Project'),
                    _buildTableRow('7', 'FAT'),
                    _buildTableRow('8', 'Performance Test'),
                    _buildTableRow('9', 'Go Live'),
                  ],
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add),
                    label: Text('Tambah Teamwork'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String no, String work) {
    return TableRow(
      children: [
        _buildTableCell(no),
        _buildTableCell(work),
        _buildTableCell(''),
        _buildTableCell(''),
        _buildTableCell(''),
        _buildTableCell(''),
        _buildTableCell(''),
        _buildTableCell(''),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 14.0 : 12.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
