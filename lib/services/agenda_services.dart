// lib/services/agenda_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agenda.dart';

class AgendaService {
  final CollectionReference _agendaCollection =
      FirebaseFirestore.instance.collection('agendas');

  // Tambahkan agenda baru
  Future<void> addAgenda(Agenda agenda) {
    return _agendaCollection.add(agenda.toFirestore());
  }

  // Ambil semua agenda
  Stream<List<Agenda>> getAgendas() {
    return _agendaCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => Agenda.fromFirestore(doc)).toList();
    });
  }

  // Perbarui agenda
  Future<void> updateAgenda(Agenda agenda) {
    return _agendaCollection.doc(agenda.id).update(agenda.toFirestore());
  }

  // Hapus agenda
  Future<void> deleteAgenda(String id) {
    return _agendaCollection.doc(id).delete();
  }
}
