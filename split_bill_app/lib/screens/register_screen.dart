import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split_bill_app/services/firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  void register() async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

    await _firestoreService.addPerson(
      uid: userCredential.user!.uid,
      name: _nameController.text,
      email: _emailController.text,
    );

    Navigator.pushReplacementNamed(context, '/login');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('your account has been created!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register your account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 48),
              CircleAvatar(
                radius: 90,
                backgroundColor: Color(0xfff2f4f3),
                child: Icon(Icons.person, size: 100, color: Colors.black),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _nameController,
                cursorColor: Color(0xff9ea8db),
                decoration: const InputDecoration(
                  label: Text('Name'),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff9ea8db)),
                  ),
                  floatingLabelStyle: TextStyle(color: Color(0xff9ea8db)),
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Enter your name',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                cursorColor: Color(0xff9ea8db),
                decoration: const InputDecoration(
                  label: Text('Email'),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff9ea8db)),
                  ),
                  floatingLabelStyle: TextStyle(color: Color(0xff9ea8db)),
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Enter your email',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                cursorColor: Color(0xff9ea8db),
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text('Password'),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff9ea8db)),
                  ),
                  floatingLabelStyle: TextStyle(color: Color(0xff9ea8db)),
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Enter your password',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff9ea8db),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Sign in here!',
                      style: TextStyle(
                        color: Color(0xff9ea8db),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
