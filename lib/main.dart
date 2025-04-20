import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/role_selection.dart'; // You can have other imports for your pages and services

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Firebase initialization
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krushi App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const RoleSelectionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
