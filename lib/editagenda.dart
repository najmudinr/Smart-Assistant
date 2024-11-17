import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:smartassistant/models/agenda.dart';
import 'package:smartassistant/services/agenda_services.dart';
import 'package:smartassistant/services/firestore_services.dart';

class EditAgendaPage extends StatefulWidget {
  final Agenda agenda; // Agenda yang akan diedit

  const EditAgendaPage({required this.agenda});

  @override
  _EditAgendaPageState createState() => _EditAgendaPageState();
}

class _EditAgendaPageState extends State<EditAgendaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController agendaController = TextEditingController();
  final TextEditingController tempatController = TextEditingController();
  DateTime? selectedDateTime;
  List<String> _allPersonel = []; // Semua personel dari Firestore
  List<String> _selectedPersonel = []; // Personel yang dipilih

  @override
  void initState() {
    super.initState();
    // Inisialisasi data awal
    agendaController.text = widget.agenda.agenda;
    tempatController.text = widget.agenda.tempat;
    selectedDateTime = widget.agenda.waktu;
    _selectedPersonel = List.from(widget.agenda.personel);
    _fetchPersonel(); // Ambil data personel dari Firestore
  }

  Future<void> _fetchPersonel() async {
    final personelNames = await FirestoreService().getPersonelNames();
    setState(() {
      _allPersonel = personelNames;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveAgenda() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silakan pilih tanggal dan waktu')),
        );
        return;
      }

      // Buat agenda yang diperbarui
      final updatedAgenda = Agenda(
        id: widget.agenda.id,
        waktu: selectedDateTime!,
        agenda: agendaController.text,
        personel: _selectedPersonel,
        tempat: tempatController.text,
      );

      // Simpan ke Firestore
      await AgendaService().updateAgenda(updatedAgenda);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agenda berhasil diperbarui')));

      Navigator.pop(context); // Kembali ke halaman sebelumnya
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Agenda'),
      ),
      body: _allPersonel.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading saat data belum siap
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: agendaController,
                      decoration: InputDecoration(labelText: 'Agenda'),
                      validator: (value) =>
                          value!.isEmpty ? 'Agenda tidak boleh kosong' : null,
                    ),
                    MultiSelectDialogField(
                      items: _allPersonel
                          .map((person) => MultiSelectItem(person, person))
                          .toList(),
                      title: Text('Pilih Personel'),
                      buttonText: Text('Personel'),
                      initialValue: _selectedPersonel, // Set personel yang sudah dipilih
                      onConfirm: (values) {
                        setState(() {
                          _selectedPersonel = values.cast<String>();
                        });
                      },
                    ),
                    TextFormField(
                      controller: tempatController,
                      decoration: InputDecoration(labelText: 'Tempat'),
                      validator: (value) =>
                          value!.isEmpty ? 'Tempat tidak boleh kosong' : null,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDateTime == null
                              ? 'Pilih Tanggal dan Waktu'
                              : '${selectedDateTime!.toLocal()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDateTime(context),
                          child: Text('Pilih'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveAgenda,
                      child: Text('Simpan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
