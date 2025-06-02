import 'package:flutter/material.dart';
import 'dart:convert';

class ResultScreen extends StatelessWidget {
  final String jsonContent;

  const ResultScreen({super.key, required this.jsonContent});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? parsed;

    try {
      // Ambil hanya bagian JSON dari string yang panjang
      final jsonMatch = RegExp(r'\{[\s\S]*\}', dotAll: true)
          .firstMatch(jsonContent)
          ?.group(0);

      if (jsonMatch == null) throw FormatException('JSON block not found');
      parsed = json.decode(jsonMatch);
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hasil Ekstraksi')),
        body: Center(child: Text('Gagal membaca JSON:\n$e')),
      );
    }

    final items = parsed?['items'] as List<dynamic>? ?? [];
    final diskon = parsed?['diskon'] ?? 0;
    final totalHarga = parsed?['total_harga'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Ekstraksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Belanja:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: Text(item['nama'] ?? 'Tanpa nama'),
                    trailing: Text('Rp ${item['harga']}'),
                  );
                },
              ),
            ),
            const Divider(),
            Text('Diskon: Rp $diskon'),
            Text(
              'Total Harga: Rp $totalHarga',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
