import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:smartassistant/models/agenda.dart';
import 'package:smartassistant/services/agenda_services.dart';
import 'package:smartassistant/services/firestore_services.dart';

class AddAgendaPage extends StatefulWidget {
  @override
  _AddAgendaPageState createState() => _AddAgendaPageState();
}

class _AddAgendaPageState extends State<AddAgendaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController agendaController = TextEditingController();
  final TextEditingController tempatController = TextEditingController();
  DateTime? selectedDateTime;
  List<String> _allPersonel = []; // Daftar personel dari Firestore
  List<String> _selectedPersonel = []; // Personel yang dipilih

  @override
  void initState() {
    super.initState();
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

      // Simpan agenda ke Firestore
      final newAgenda = Agenda(
        id: '', // ID akan di-generate oleh Firestore
        waktu: selectedDateTime!,
        agenda: agendaController.text,
        personel: _selectedPersonel,
        tempat: tempatController.text,
      );

      await AgendaService().addAgenda(newAgenda);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agenda berhasil ditambahkan')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Agenda'),
      ),
      body: _allPersonel.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator(), // Loading saat data belum siap
            )
          : SingleChildScrollView(
              // Tambahkan SingleChildScrollView di sini
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
    );
  }
}
