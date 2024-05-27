import 'package:flutter/material.dart';
import 'package:filmlerfirebase/Firebase/FirebaseService.dart';

class Kayit extends StatefulWidget {

  @override
  State<Kayit> createState() => _KayitState();
}

class _KayitState extends State<Kayit> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  String? _errorMessage;

  Future<void> _signUp() async {
    try {
      await _firebaseService.signUp(
        _emailController.text,
        _passwordController.text,
      );
      Navigator.pop(context); // Kayıt işleminden sonra giriş ekranına dön
    } catch (e) {
      setState(() {
        _errorMessage = 'Kayıt başarısız: $e';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmailField(),
            const SizedBox(height: 20.0),
            _buildPasswordField(),
            const SizedBox(height: 20.0),
            _buildSignUpButton(),
            _buildLoginButton(),
            if (_errorMessage != null) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF153448),
      title: const Text(
        "Kullanıcı Kayıt",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  TextField _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'E-posta',
      ),
    );
  }

  TextField _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Şifre',
      ),
    );
  }

  ElevatedButton _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _signUp,
      child: const Text('Kayıt Ol'),
    );
  }

  TextButton _buildLoginButton() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text("Giriş Yap"),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
