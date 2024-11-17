import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:smartassistant/main.dart';
import 'dart:async';

import 'package:smartassistant/models/agenda.dart';

class AgendaNotifier {
  Timer? _timer;

  void startMonitoring(List<Agenda> agendas) {
    _timer?.cancel(); // Batalkan timer jika sudah ada
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      for (final agenda in agendas) {
        final timeDifference = agenda.waktu.difference(now).inMinutes;
        if (timeDifference > 0 && timeDifference <= 30) { // Alert sebelum 30 menit
          _showNotification(agenda);
        }
      }
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  Future<void> _showNotification(Agenda agenda) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'agenda_alert_channel',
      'Agenda Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      agenda.id.hashCode,
      'Agenda Akan Dimulai',
      'Agenda "${agenda.agenda}" dimulai pada ${DateFormat('HH:mm').format(agenda.waktu)}',
      platformChannelSpecifics,
    );
  }
}
