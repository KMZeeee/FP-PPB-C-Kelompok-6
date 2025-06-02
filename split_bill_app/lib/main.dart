import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:split_bill_app/firebase_options.dart';
import 'package:split_bill_app/screens/friend_screen.dart';
import 'package:split_bill_app/screens/home_screen.dart';
import 'package:split_bill_app/screens/login_screen.dart';

void main() {
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Color(0xff9ea8db),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/friend': (context) => const FriendScreen(),
      },
    );
  }
}
