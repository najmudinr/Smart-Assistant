// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class EditMemoPage extends StatefulWidget {
  final String memoId;

  const EditMemoPage({required this.memoId});

  @override
  _EditMemoPageState createState() => _EditMemoPageState();
}

class _EditMemoPageState extends State<EditMemoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _memoNumberController = TextEditingController();
  final TextEditingController _creatorController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();
  final TextEditingController _relatedPicController = TextEditingController();

  String _selectedOrigin = 'Bagian';
  String _selectedStatus = 'Di Rekap Sekretaris';
  String _selectedNotes = 'Pending';
  String _selectedDestination = 'VP Pergudangan dan Pengantongan';

  DateTime? _submissionDate;
  DateTime? _avpSendDate;
  DateTime? _avpReceivedDate;
  DateTime? _vpSendDate;
  DateTime? _vpReceivedDate;

  String? _uploadedFileUrl;

  @override
  void initState() {
    super.initState();
    _loadMemoData();
  }

  Future<void> _loadMemoData() async {
    DocumentSnapshot memoSnapshot = await FirebaseFirestore.instance
        .collection('internal_memos')
        .doc(widget.memoId)
        .get();

    if (memoSnapshot.exists) {
      setState(() {
        _memoNumberController.text = memoSnapshot['memo_number'] ?? '';
        _creatorController.text = memoSnapshot['creator'] ?? '';
        _destinationController.text = memoSnapshot['destination'] ?? '';
        _subjectController.text = memoSnapshot['subject'] ?? '';
        _selectedOrigin = memoSnapshot['origin'] ?? 'Bagian';
        _selectedStatus = memoSnapshot['status'] ?? 'Di Rekap Sekretaris';
        _selectedNotes = memoSnapshot['notes'] ?? 'Pending';
        _followUpController.text = memoSnapshot['follow_up'] ?? '';
        _relatedPicController.text = memoSnapshot['related_pic'] ?? '';
        _uploadedFileUrl = memoSnapshot['document_archive'];
        _submissionDate =
            (memoSnapshot['submission_date'] as Timestamp?)?.toDate();
        _avpSendDate = (memoSnapshot['avp_send_date'] as Timestamp?)?.toDate();
        _avpReceivedDate =
            (memoSnapshot['avp_received_date'] as Timestamp?)?.toDate();
        _vpSendDate = (memoSnapshot['vp_send_date'] as Timestamp?)?.toDate();
        _vpReceivedDate =
            (memoSnapshot['vp_received_date'] as Timestamp?)?.toDate();
      });
    }
  }

  Future<void> _updateMemo() async {
    try {
      await FirebaseFirestore.instance
          .collection('internal_memos')
          .doc(widget.memoId)
          .update({
        'memo_number': _memoNumberController.text,
        'creator': _creatorController.text,
        'origin': _selectedOrigin,
        'destination': _destinationController.text,
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
        'document_archive': _uploadedFileUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Memo berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui memo: $e')),
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

  // Future<void> _uploadDocument() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

  //   if (result != null) {
  //     String? filePath = result.files.single.path;
  //     String fileName = result.files.single.name;

  //     if (filePath != null) {
  //       Reference storageRef = FirebaseStorage.instance.ref().child('documents/$fileName');

  //       try {
  //         TaskSnapshot uploadTask = await storageRef.putFile(File(filePath));
  //         String downloadUrl = await uploadTask.ref.getDownloadURL();
  //         setState(() {
  //           _uploadedFileUrl = downloadUrl;
  //         });
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('File berhasil diunggah')),
  //         );
  //       } catch (e) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Gagal mengunggah file: $e')),
  //         );
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Memo'),
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
              // SizedBox(height: 10),
              // Text('Arsip Dokumen: ${_uploadedFileUrl ?? 'Belum ada dokumen diunggah'}'),
              // ElevatedButton(
              //   onPressed: _uploadDocument,
              //   child: Text('Upload Dokumen'),
              // ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateMemo();
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
