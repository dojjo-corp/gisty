import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/pages/login.dart';
import 'package:gt_daily/global/homepage.dart';

import 'authentication/gates/auth_gate.dart';
import 'authentication/pages/phone_number.dart';
import 'authentication/pages/phone_verification.dart';
import 'authentication/pages/register.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[800]!),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/enter-phone': (context) => const EnterPhonePage(),
        '/verify-phone': (context) => const PhoneverificationPage(),
        '/home': (context) => const MyHomePage(title: 'Gisty'),
      },
    );
  }
}
