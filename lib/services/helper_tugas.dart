// utils/task_helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Fungsi untuk memformat tanggal
String formatDate(String? date) {
  if (date == null || date.isEmpty) return "Tanggal Tidak Diketahui";
  final DateTime parsedDate = DateTime.parse(date);
  return DateFormat('dd MMM yyyy, HH:mm').format(parsedDate);
}

// Fungsi untuk mendapatkan warna berdasarkan status
Color getStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'Terkirim':
      return Colors.green;
    case 'Progress':
      return Colors.blue;
    case 'Pending':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
