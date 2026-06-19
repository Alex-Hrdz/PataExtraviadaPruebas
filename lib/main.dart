import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PataExtraviada());
}

class PataExtraviada extends StatelessWidget {
  const PataExtraviada({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PataExtraviada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
