// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class AddMemoPage extends StatefulWidget {
  @override
  _AddMemoPageState createState() => _AddMemoPageState();
}

class _AddMemoPageState extends State<AddMemoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _memoNumberController = TextEditingController();
  final TextEditingController _creatorController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();
  final TextEditingController _relatedPicController = TextEditingController();

  String _selectedOrigin = 'Bagian'; // Default value
  String _selectedStatus = 'Di Rekap Sekretaris'; // Default value
  String _selectedNotes = 'Pending'; // Default value
  String _selectedDestination = 'VP Pergudangan dan Pengantongan';

  DateTime? _submissionDate;
  DateTime? _avpSendDate;
  DateTime? _avpReceivedDate;
  DateTime? _vpSendDate;
  DateTime? _vpReceivedDate;

  // PlatformFile? _selectedFile; // Untuk menyimpan file yang dipilih
  // String? _uploadedFileUrl; // URL file yang diunggah

// Future<void> _selectFile() async {
//   try {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();

//     if (result != null) {
//       setState(() {
//         _selectedFile = result.files.first;

//         // Jika `bytes` tidak tersedia, baca data dari path
//         if (_selectedFile!.bytes == null && _selectedFile!.path != null) {
//           _selectedFile = PlatformFile(
//             name: _selectedFile!.name,
//             path: _selectedFile!.path,
//             size: _selectedFile!.size,
//             bytes: File(_selectedFile!.path!).readAsBytesSync(),
//           );
//         }
//       });
//     }
//   } catch (e) {
//     print("Gagal memilih file: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Gagal memilih file: $e')),
//     );
//   }
// }

// Future<void> _uploadFile() async {
//   if (_selectedFile == null || _selectedFile!.bytes == null) {
//     print("File tidak valid atau tidak memiliki data bytes.");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Gagal mengunggah file: File tidak valid')),
//     );
//     return;
//   }

//   try {
//     final path = 'internal_memos/${_selectedFile!.name}';
//     final ref = FirebaseStorage.instance.ref().child(path);

//     final uploadTask = ref.putData(_selectedFile!.bytes!); // `bytes` tidak boleh null
//     final snapshot = await uploadTask;

//     final downloadUrl = await snapshot.ref.getDownloadURL();
//     setState(() {
//       _uploadedFileUrl = downloadUrl;
//     });

//     print("File berhasil diunggah ke: $_uploadedFileUrl");
//   } catch (e) {
//     print("Gagal mengunggah file: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Gagal mengunggah file: $e')),
//     );
//   }
// }

  Future<void> _addMemo() async {
    try {
      //   await _uploadFile(); // Unggah file sebelum menyimpan data

      //   if (_uploadedFileUrl == null) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //           content:
      //               Text('Gagal menyimpan memo: File tidak berhasil diunggah')),
      //     );
      //     return; // Jangan lanjutkan jika file gagal diunggah
      //   }

      await FirebaseFirestore.instance.collection('internal_memos').add({
        'memo_number': _memoNumberController.text,
        'creator': _creatorController.text,
        'origin': _selectedOrigin,
        'destination': _tujuanController.text,
        'subject': _subjectController.text,
        'submission_date': _submissionDate != null
            ? Timestamp.fromDate(_submissionDate!)
            : null,
        'avp_send_date':
            _avpSendDate != null ? Timestamp.fromDate(_avpSendDate!) : null,
        'avp_received_date': _avpReceivedDate != null
            ? Timestamp.fromDate(_avpReceivedDate!)
            : null,
        'vp_send_date':
            _vpSendDate != null ? Timestamp.fromDate(_vpSendDate!) : null,
        'vp_received_date': _vpReceivedDate != null
            ? Timestamp.fromDate(_vpReceivedDate!)
            : null,
        'status': _selectedStatus,
        'notes': _selectedNotes,
        'follow_up': _followUpController.text,
        'related_pic': _relatedPicController.text,
        // 'document_archive': _uploadedFileUrl, // URL file yang diunggah
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Memo berhasil ditambahkan')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan memo: $e')),
      );
    }
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime) onDatePicked) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        onDatePicked(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Memo'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _memoNumberController,
                decoration: InputDecoration(labelText: 'Nomor Memo'),
              ),
              TextFormField(
                controller: _creatorController,
                decoration: InputDecoration(labelText: 'Pembuat Memo'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedOrigin,
                decoration: InputDecoration(labelText: 'Asal Memo'),
                items: ['Bagian', 'Seksi'].map((origin) {
                  return DropdownMenuItem<String>(
                    value: origin,
                    child: Text(origin),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedOrigin = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedDestination,
                decoration: InputDecoration(labelText: 'Tujuan Memo'),
                items: [
                  'VP Pergudangan dan Pengantongan',
                  'AVP Bagian Gudang dan Pengantongan Area III'
                ].map((destination) {
                  return DropdownMenuItem<String>(
                    value: destination,
                    child: Text(destination),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDestination = value!;
                  });
                },
              ),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Perihal Pengajuan'),
              ),
              SizedBox(height: 10),
              Text(
                  'Tanggal Pengajuan: ${_submissionDate != null ? DateFormat('dd MMM yyyy').format(_submissionDate!) : 'Belum dipilih'}'),
              ElevatedButton(
                onPressed: () =>
                    _selectDate(context, (picked) => _submissionDate = picked),
                child: Text('Pilih Tanggal Pengajuan'),
              ),
              SizedBox(height: 10),
              Text(
                  'Tanggal Pengiriman ke AVP: ${_avpSendDate != null ? DateFormat('dd MMM yyyy').format(_avpSendDate!) : 'Belum dipilih'}'),
              ElevatedButton(
                onPressed: () =>
                    _selectDate(context, (picked) => _avpSendDate = picked),
                child: Text('Pilih Tanggal Pengiriman ke AVP'),
              ),
              SizedBox(height: 10),
              Text(
                  'Tanggal Diterima AVP: ${_avpReceivedDate != null ? DateFormat('dd MMM yyyy').format(_avpReceivedDate!) : 'Belum dipilih'}'),
              ElevatedButton(
                onPressed: () =>
                    _selectDate(context, (picked) => _avpReceivedDate = picked),
                child: Text('Pilih Tanggal Diterima AVP'),
              ),
              SizedBox(height: 10),
              Text(
                  'Tanggal Pengiriman ke VP: ${_vpSendDate != null ? DateFormat('dd MMM yyyy').format(_vpSendDate!) : 'Belum dipilih'}'),
              ElevatedButton(
                onPressed: () =>
                    _selectDate(context, (picked) => _vpSendDate = picked),
                child: Text('Pilih Tanggal Pengiriman ke VP'),
              ),
              SizedBox(height: 10),
              Text(
                  'Tanggal Diterima VP: ${_vpReceivedDate != null ? DateFormat('dd MMM yyyy').format(_vpReceivedDate!) : 'Belum dipilih'}'),
              ElevatedButton(
                onPressed: () =>
                    _selectDate(context, (picked) => _vpReceivedDate = picked),
                child: Text('Pilih Tanggal Diterima VP'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(labelText: 'Status'),
                items: [
                  'Di Rekap Sekretaris',
                  'Di Review VP',
                  'Di Setujui VP',
                  'Di Revisi VP',
                  'Di Batalkan VP',
                  'Di Rekap Adm Bagian',
                  'Review AVP',
                  'Disetujui AVP',
                  'Di Revisi AVP',
                  'Di Batalkan AVP',
                ].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedNotes,
                decoration: InputDecoration(labelText: 'Keterangan'),
                items: ['Pending', 'Progress', 'Closed'].map((notes) {
                  return DropdownMenuItem<String>(
                    value: notes,
                    child: Text(notes),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedNotes = value!;
                  });
                },
              ),
              TextFormField(
                controller: _followUpController,
                decoration: InputDecoration(labelText: 'Tindak Lanjut'),
              ),
              TextFormField(
                controller: _relatedPicController,
                decoration: InputDecoration(labelText: 'PIC Terkait'),
              ),
              // Row(
              //   children: [
              //     ElevatedButton(
              //       onPressed: _selectFile,
              //       child: Text('Pilih Arsip Dokumen'),
              //     ),
              //     SizedBox(width: 10),
              //     Expanded(
              //       child: Text(
              //         _selectedFile != null
              //             ? _selectedFile!.name
              //             : 'Belum ada file yang dipilih',
              //         overflow: TextOverflow.ellipsis,
              //       ),
              //     ),
              //   ],
              // ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addMemo();
                  }
                },
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
