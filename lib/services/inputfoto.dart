import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Helper untuk menangani pemilihan gambar/file di seluruh aplikasi.
class FileUtils {
  // Mengambil gambar dari kamera
  static Future<File?> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      print('Error saat mengambil gambar dari kamera: $e');
      return null;
    }
  }

  // Mengambil gambar dari galeri
  static Future<File?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      print('Error saat mengambil gambar dari galeri: $e');
      return null;
    }
  }

  // Memilih file dengan file picker
  static Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      } else {
        print('Tidak ada file yang dipilih');
        return null;
      }
    } catch (e) {
      print('Error saat memilih file: $e');
      return null;
    }
  }
}
