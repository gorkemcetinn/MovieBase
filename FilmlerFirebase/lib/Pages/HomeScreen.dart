import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmlerfirebase/Firebase/FirebaseService.dart';
import 'package:filmlerfirebase/Pages/AddMovie.dart';
import 'package:filmlerfirebase/Pages/MovieDetailScreen.dart';
import 'package:filmlerfirebase/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedCategory = 'Aksiyon';

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return Login();
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryTabs(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Ana Sayfa', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.black,
      elevation: 4,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            child: Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['Aksiyon', 'Komedi', 'Drama', 'Korku'].map((category) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Text(category),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder(
      stream: _firebaseService.getMoviesByCategory(_selectedCategory),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return _buildError(snapshot.error);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final QueryDocumentSnapshot movie = snapshot.data!.docs[index];
            final Map<String, dynamic>? data = movie.data() as Map<String, dynamic>?; // Dönüş türü belirtildi
            final imageUrl = data?['ImageUrl'] ?? ''; // null check
            final title = data?['Name'] ?? ''; // Film başlığını al
            return _buildGridTile(movie, imageUrl, title); // _buildGridTile'a movie değişkenini geç
          },
        );
      },
    );
  }




  Widget _buildError(error) {
    return Center(child: Text('Error: $error'));
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildGridTile(QueryDocumentSnapshot movie, String imageUrl, String title) {
    return InkWell(
      onTap: () {
        // Film detaylarına git
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: movie, filmId: movie.id)),
        );
      },
      child: GridTile(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }


  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddMovie()),
        );
      },
      backgroundColor: Colors.black,
      child: Icon(Icons.add, color: Colors.white),
    );
  }
}

