// lib/screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_picker.dart';
import '../services/ocr_api.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final OcrApiService _ocrService = OcrApiService();

  bool _isLoading = false;
  File? _selectedImage;
  String _generatedContent = '';

  /// Method untuk memilih gambar dari galeri.
  Future<void> _pickImage() async {
    final file = await _imagePickerService.pickImageFromGallery();
    if (file != null) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  /// Method untuk mengambil gambar dari kamera
  Future<void> _pickImageFromCamera() async {
    final file = await _imagePickerService.pickImageFromCamera();
    if (file != null) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  /// Method untuk mengirim gambar ke OCR dengan prompt yang sudah ditentukan.
  Future<void> _generateContent() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedContent = '';
    });

    // Predefined prompt for OCR processing
    const String predefinedPrompt = """
    Please extract all items and their prices from this receipt. 
    Format the result as a JSON object with the following structure:

    {
      "items": [
        {
          "nama": "item name",
          "harga": integer price
        }
      ],
      "diskon": integer discount (if any, otherwise use 0),
      "total_harga": total price after discount
    }

    Make sure:
    - All prices are integers (no currency symbols or decimals).
    - The total_harga equals the sum of item prices minus the discount.
    """;

    try {
      final result = await _ocrService.generateContent(
        promptText: predefinedPrompt,
        imageFile: _selectedImage,
      );

      setState(() {
        _generatedContent = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _generatedContent = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baca Struk'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
  

            // 2. Baris tombol: Select Image & Generate Content
            // Button to select image
            Row(
              children: [
              Expanded(
                child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('From Gallery'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                onPressed: _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('From Camera'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                ),
                ),
              ),
              ],
            ),
            
            const SizedBox(height: 20),

            // 3. Preview gambar jika ada
            if (_selectedImage != null) ...[
              SizedBox(
                height: 150,
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              
              // Generate Content button below the image
              ElevatedButton(
                onPressed: _isLoading ? null : _generateContent,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Generate Content'),
              ),
            ],
            const SizedBox(height: 20),

            // 4. Area hasil (scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoading
                      ? const Center(child: Text('Loading...'))
                      : Builder(
                          builder: (_) {
                            // Jika keluaran mengandung JSON, tampilkan
                            final jsonMatch = RegExp(r'\{.*\}', dotAll: true)
                                .firstMatch(_generatedContent)
                                ?.group(0);

                            if (jsonMatch != null &&
                                jsonMatch.contains('"code": 500') &&
                                jsonMatch.contains('overloaded')) {
                              return const Text(
                                  'Model overload, coba sesaat lagi');
                            }

                            return Text(
                              (jsonMatch != null) 
                                  ? jsonMatch 
                                  : (_generatedContent.isEmpty
                                      ? 'Generated content will appear here'
                                      : _generatedContent),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
