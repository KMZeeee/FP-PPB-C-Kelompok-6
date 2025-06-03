// lib/services/ocr_api.dart

import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';

class OcrApiService {
  // Inisialisasi model Gemini (pastikan dependency firebase_ai sudah di pubspec.yaml)
  final GenerativeModel _model = FirebaseAI.googleAI()
      .generativeModel(model: 'gemini-2.0-flash-001');

  /// Kirim prompt teks + optional gambar ke Gemini, lalu kembalikan hasilnya.
  /// - [promptText] : teks instruksi untuk model.
  /// - [imageFile]  : jika tidak null, akan dikirim sebagai InlineDataPart.
  Future<String> generateContent({
    required String promptText,
    File? imageFile,
  }) async {
    final List<Part> parts = [];

    // 1. Tambahkan TextPart
    parts.add(TextPart(promptText));

    // 2. Jika ada gambar, tambahkan InlineDataPart
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      parts.add(InlineDataPart('image/jpeg', bytes));
    }

    // 3. Panggil Gemini untuk menghasilkan konten
    final response = await _model.generateContent([
      Content.multi(parts),
    ]);

    // 4. Ambil teks hasil (atau fallback jika null)
    return response.text ?? 'No content generated';
  }
}
