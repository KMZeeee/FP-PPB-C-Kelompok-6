import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_picker.dart';
import '../services/ocr_api.dart';
import 'result_ocr_screen.dart'; // import layar hasil

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final OcrApiService _ocrService = OcrApiService();

  bool _isLoading = false;
  File? _selectedImage;
  String _generatedContent = '';

  Future<void> _pickImage() async {
    final file = await _imagePickerService.pickImageFromGallery();
    if (file != null) {
      setState(() => _selectedImage = file);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final file = await _imagePickerService.pickImageFromCamera();
    if (file != null) {
      setState(() => _selectedImage = file);
    }
  }

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

      // Navigasi ke layar hasil
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(jsonContent: _generatedContent),
        ),
      );
    } catch (e) {
      setState(() {
        _generatedContent = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baca Struk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('From Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('From Camera'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: Image.file(_selectedImage!, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _generateContent,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Generate Content'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
