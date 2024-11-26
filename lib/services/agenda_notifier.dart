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
      // print("Memeriksa agenda pada: ${DateFormat('HH:mm:ss').format(now)}");
      for (final agenda in agendas) {
        final timeDifference = agenda.waktu.difference(now).inMinutes;
        // print("Agenda: ${agenda.agenda}, Sisa waktu: $timeDifference menit");

        if (timeDifference > 0 && timeDifference <= 5) {
          // Alert sebelum 5 menit
          _showNotification(agenda);
        }
      }
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  Future<void> _showNotification(Agenda agenda) async {
    try {
      print("Menampilkan notifikasi untuk agenda: ${agenda.agenda}");
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'agenda_alert_channel', // Channel ID
        'Agenda Alerts', // Channel Name
        channelDescription: 'Notifikasi untuk agenda mendatang',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        agenda.id.hashCode, // ID Unik untuk notifikasi
        'Agenda Akan Dimulai',
        'Agenda "${agenda.agenda}" dimulai pada ${DateFormat('HH:mm').format(agenda.waktu)}',
        platformChannelSpecifics,
      );
      print("Notifikasi berhasil ditampilkan.");
    } catch (e) {
      print("Error saat menampilkan notifikasi: $e");
    }
  }
}
