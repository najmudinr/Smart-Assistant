import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartassistant/editagenda.dart';
import 'package:smartassistant/services/agenda_services.dart';
import 'package:smartassistant/tambahagenda.dart';
import '../models/agenda.dart';

class AgendaCard extends StatelessWidget {
  final double screenWidth;
  final String userRole;

  const AgendaCard({
    required this.screenWidth,
    required this.userRole,
  });

  void navigateToAddPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAgendaPage()),
    );
  }

  void navigateToEditPage(BuildContext context, Agenda agenda) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAgendaPage(agenda: agenda)),
    );
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  // Method to create routine agenda
  Agenda getRoutineAgenda() {
    return Agenda(
      waktu: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 7, 15),
      agenda: 'Daily Bagging Performance Review',
      personel: ['Semua Karyawan'],
      tempat: 'Zoom Meetings', id: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Agenda>>(
      stream: AgendaService().getAgendas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan'));
        }

        final allAgendas = snapshot.data ?? [];

        // Filter for today's agenda
        final today = DateTime.now();
        final filteredAgendas = allAgendas
            .where((agenda) =>
                agenda.waktu.year == today.year &&
                agenda.waktu.month == today.month &&
                agenda.waktu.day == today.day)
            .toList();

        // Add routine agenda if today is Monday-Friday
        if (today.weekday >= 1 && today.weekday <= 5) {
          filteredAgendas.add(getRoutineAgenda());
        }

        return Card(
          color: Colors.white,
          margin: EdgeInsets.all(screenWidth * 0.02),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Agenda Bagian III Hari Ini',
                      style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (userRole == 'Admin Bagian' ||
                            userRole == 'Admin Seksi')
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.cyan),
                            onPressed: () => navigateToAddPage(context),
                          ),
                        if (userRole == 'Admin Bagian' ||
                            userRole == 'Admin Seksi')
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.cyan),
                            onPressed: () {
                              if (filteredAgendas.isNotEmpty) {
                                navigateToEditPage(context, filteredAgendas.first);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Tidak ada agenda untuk diedit')),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: screenWidth * 0.02),

                // Tabel Agenda
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: screenWidth * 0.05,
                    columns: [
                      DataColumn(label: Text('Waktu')),
                      DataColumn(label: Text('Agenda')),
                      DataColumn(label: Text('Personel')),
                      DataColumn(label: Text('Tempat')),
                    ],
                    rows: filteredAgendas.map((agenda) {
                      return DataRow(cells: [
                        DataCell(Text(formatDateTime(agenda.waktu))),
                        DataCell(Text(agenda.agenda)),
                        DataCell(Text(agenda.personel.join(', '))),
                        DataCell(Text(agenda.tempat)),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
