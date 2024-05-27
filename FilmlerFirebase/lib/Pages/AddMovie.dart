import 'package:flutter/material.dart';
import 'package:filmlerfirebase/Firebase/FirebaseService.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddMovie extends StatefulWidget {
  const AddMovie({Key? key}) : super(key: key);

  @override
  State<AddMovie> createState() => _AddMovieState();
}

class _AddMovieState extends State<AddMovie> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _starsController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  File? _image;
  String _selectedCategory = 'Aksiyon'; // Başlangıçta Aksiyon kategorisini seçili olarak belirle

  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Film Ekle'),
      ),
      body: SingleChildScrollView( // SingleChildScrollView kullanarak içeriği kaydırılabilir hale getir
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextFormField(
                  controller: _nameController,
                  labelText: 'Film İsmi',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir isim girin';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _directorController,
                  labelText: 'Yönetmen',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen yönetmeni girin';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _ratingController,
                  labelText: 'Puan',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen puanı girin';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _starsController,
                  labelText: 'Baş Rol',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen baş rol girin';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _yearController,
                  labelText: 'Yapım Yılı',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen yapım yılı girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildCategoryDropdown(), // Kategori dropdown
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _getImage,
                  child: Text('Resim Seç'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addFilm,
                  child: Text('Ekle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      validator: validator,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory.isNotEmpty ? _selectedCategory : null, // DropdownButtonFormField'ı pasif hale getir
      items: ['Aksiyon', 'Komedi', 'Drama', 'Korku']
          .map((category) => DropdownMenuItem(
        value: category,
        child: Text(category),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
      decoration: InputDecoration(labelText: 'Kategori'),
    );
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addFilm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Resim URL'sini Firebase Storage'a yükle
        String imageUrl = '';
        if (_image != null) {
          imageUrl = await _firebaseService.uploadImage(_image!);
        }

        // Firestore'a filmi ekle
        await _firebaseService.addMovie(
          _nameController.text,
          imageUrl,
          _directorController.text,
          _ratingController.text,
          _starsController.text,
          _yearController.text,
          _selectedCategory, // Seçilen kategori
        );

        // Başarı mesajını göster
        _showSnackBar('Film başarıyla eklendi.');

        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Film eklenirken bir hata oluştu: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
