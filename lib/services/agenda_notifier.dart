import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:smartassistant/models/agenda.dart';
import 'package:smartassistant/main.dart'; // Impor flutterLocalNotificationsPlugin

class AgendaNotifier {
  Timer? _timer;

  void startMonitoring(List<Agenda> agendas) {
    _timer?.cancel(); // Batalkan timer jika sudah ada
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      for (final agenda in agendas) {
        final timeDifference = agenda.waktu.difference(now).inMinutes;

        if (timeDifference > 0 && timeDifference <= 5) {
          // Alert sebelum 30 menit
          _showNotification(agenda);
        }
      }
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  Future<void> _showNotification(Agenda agenda) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'agenda_alert_channel', // Channel ID
      'Agenda Alerts', // Channel Name
      channelDescription: 'Notifikasi untuk agenda mendatang',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Tampilkan notifikasi hanya sekali untuk agenda yang sama
    await flutterLocalNotificationsPlugin.show(
      agenda.id.hashCode, // ID Unik berdasarkan hash agenda.id
      'Agenda Akan Dimulai',
      'Agenda "${agenda.agenda}" dimulai pada ${DateFormat('HH:mm').format(agenda.waktu)}',
      platformChannelSpecifics,
    );
  }
}
