import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Stream<QuerySnapshot> getMovies() {
    return _firestore.collection('Movies').snapshots();
  }

  Future<DocumentSnapshot> getMovieDetails(String filmId) async {
    return await _firestore.collection('Movies').doc(filmId).get();
  }

  Future<void> deleteMovie(String filmId, String imageUrl) async {
    // Firebase Firestore'dan filmi sil
    await _firestore.collection('Movies').doc(filmId).delete();

    // Firebase Storage'dan resmi sil
    if (imageUrl.isNotEmpty) {
      Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await imageRef.delete();
    }

    // Film silindiğinde categories koleksiyonundan da silinmeli
    QuerySnapshot categorySnapshots = await _firestore.collection('categories').get();
    categorySnapshots.docs.forEach((doc) async {
      String categoryId = doc.id;
      await _firestore.collection('categories').doc(categoryId).update({
        'movieIds': FieldValue.arrayRemove([filmId])
      });
    });
  }



  Future<String> uploadImage(File image) async {
    final Reference ref = FirebaseStorage.instance.ref().child('images').child('${DateTime.now()}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> addMovie(String name, String imageUrl, String director, String rating, String stars, String year, String category) async {
    DocumentReference movieRef = await _firestore.collection('Movies').add({
      'Name': name,
      'ImageUrl': imageUrl,
      'Director': director,
      'Rating': rating,
      'Stars': stars,
      'Year': year,
      'Category': category,
    });

    await _firestore.collection('categories').doc(category).update({
      'movieIds': FieldValue.arrayUnion([movieRef.id])
    });
  }

  Stream<QuerySnapshot> getMoviesByCategory(String category) {
    return _firestore.collection('Movies').where('Category', isEqualTo: category).snapshots();
  }
}

