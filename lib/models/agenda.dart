import 'package:cloud_firestore/cloud_firestore.dart';

class Agenda {
  final String id;
  final DateTime waktu;
  final String agenda;
  final List<String> personel; // Perubahan di sini
  final String tempat;

  Agenda({
    required this.id,
    required this.waktu,
    required this.agenda,
    required this.personel,
    required this.tempat,
  });

  factory Agenda.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Agenda(
      id: doc.id,
      waktu: (data['waktu'] as Timestamp).toDate(),
      agenda: data['agenda'] ?? '',
      personel: List<String>.from(data['personel'] ?? []), // Ambil array personel
      tempat: data['tempat'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'waktu': Timestamp.fromDate(waktu),
      'agenda': agenda,
      'personel': personel, // Simpan array personel
      'tempat': tempat,
    };
  }
}
