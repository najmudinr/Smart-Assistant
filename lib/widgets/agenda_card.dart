import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:smartassistant/editagenda.dart';
import 'package:smartassistant/main.dart';
import 'package:smartassistant/services/agenda_services.dart';
import 'package:smartassistant/tambahagenda.dart';
import '../models/agenda.dart';

class AgendaCard extends StatefulWidget {
  final double screenWidth;
  final String userRole;

  const AgendaCard({
    required this.screenWidth,
    required this.userRole,
  });

  @override
  _AgendaCardState createState() => _AgendaCardState();
}

class _AgendaCardState extends State<AgendaCard> {
  DateTime today = DateTime.now();

  Future<void> requestNotificationPermission() async {
    final plugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (plugin != null) {
      await plugin.requestPermission(); // Tidak ada nilai kembalian
      print(
          "Izin notifikasi telah diminta."); // Hasil hanya dapat diobservasi oleh pengguna
    }
  }

  @override
  void initState() {
    super.initState();
    _startDayRefreshTimer(); // Mulai timer untuk refresh agenda saat hari berganti
    requestNotificationPermission();
  }

  @override
  void dispose() {
    _dayRefreshTimer?.cancel();
    super.dispose();
  }

  Timer? _dayRefreshTimer;

  void _startDayRefreshTimer() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _dayRefreshTimer = Timer(durationUntilMidnight, () {
      setState(() {
        today = DateTime.now(); // Perbarui tanggal hari ini
      });
      _startDayRefreshTimer(); // Set timer ulang untuk hari berikutnya
    });
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  Agenda getRoutineAgenda() {
    final routineTime = DateTime(today.year, today.month, today.day, 7, 15);
    return Agenda(
      waktu: routineTime,
      agenda: 'Daily Bagging Performance Review',
      personel: ['Semua Karyawan'],
      tempat: 'Zoom Meetings',
      id: '',
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

        // Filter hanya agenda untuk hari ini
        final filteredAgendas = allAgendas
            .where((agenda) =>
                agenda.waktu.year == today.year &&
                agenda.waktu.month == today.month &&
                agenda.waktu.day == today.day)
            .toList();

        // Tambahkan agenda rutin jika hari ini adalah Senin-Jumat
        if (today.weekday >= 1 && today.weekday <= 5) {
          filteredAgendas.add(getRoutineAgenda());
        }

        return Card(
          color: Colors.white,
          margin: EdgeInsets.all(widget.screenWidth * 0.02),
          child: Padding(
            padding: EdgeInsets.all(widget.screenWidth * 0.04),
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
                    if (widget.userRole == 'Admin Bagian' ||
                        widget.userRole == 'Admin Seksi')
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.cyan),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddAgendaPage()),
                          );
                        },
                      ),
                  ],
                ),

                SizedBox(height: widget.screenWidth * 0.02),

                // Tabel Agenda
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: widget.screenWidth * 0.05,
                    columns: [
                      DataColumn(label: Text('Waktu')),
                      DataColumn(label: Text('Agenda')),
                      DataColumn(label: Text('Personel')),
                      DataColumn(label: Text('Tempat')),
                      if (widget.userRole == 'Admin Bagian' ||
                          widget.userRole == 'Admin Seksi')
                        DataColumn(label: Text('Aksi')),
                    ],
                    rows: filteredAgendas.map((agenda) {
                      return DataRow(cells: [
                        DataCell(Text(formatDateTime(agenda.waktu))),
                        DataCell(Text(agenda.agenda)),
                        DataCell(Text(agenda.personel.join(', '))),
                        DataCell(Text(agenda.tempat)),
                        if (widget.userRole == 'Admin Bagian' ||
                            widget.userRole == 'Admin Seksi')
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.cyan),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditAgendaPage(agenda: agenda),
                                  ),
                                );
                              },
                            ),
                          ),
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

extension on AndroidFlutterLocalNotificationsPlugin {
  requestPermission() {}
}
