import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmlerfirebase/Firebase/FirebaseService.dart';

class MovieDetailScreen extends StatefulWidget {
  MovieDetailScreen({required this.filmId, required DocumentSnapshot<Object?> movie});
  final String filmId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  DocumentSnapshot? filmData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilmDetails();
  }

  Future<void> _loadFilmDetails() async {
    try {
      final DocumentSnapshot film = await _firebaseService.getMovieDetails(widget.filmId);
      setState(() {
        filmData = film;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteMovie() async {
    try {
      final DocumentSnapshot<Object?> movieData = await _firebaseService.getMovieDetails(widget.filmId);
      final String imageUrl = movieData['ImageUrl'];

      await _firebaseService.deleteMovie(widget.filmId, imageUrl);
      Navigator.pop(context); // Film silindikten sonra geri dön
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Film başarıyla silindi.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Film silinirken bir hata oluştu: $e')),
      );
    }
  }


  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Emin misiniz?"),
          content: Text("Bu filmi silmek istediğinizden emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Hayır"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteMovie();
              },
              child: Text("Evet"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading ? _buildLoadingIndicator() : _buildFilmDetails(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Film Detayları', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }


  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildFilmDetails() {
    if (filmData == null) {
      return Center(child: Text('Film verisi yüklenemedi'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            filmData!['ImageUrl'] != null
                ? Image.network(filmData!['ImageUrl'])
                : Placeholder(),
            SizedBox(height: 16),
            Text(
              filmData!['Name'] ?? 'Film Adı Bulunamadı',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Çıkış Tarihi: ${filmData!['Year'] ?? 'Bilinmiyor'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Text(
              "Rating: ${filmData!['Rating']} " ?? 'Açıklama Bulunamadı',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showDeleteDialog,
      child: Icon(Icons.delete),
    );
  }
}
