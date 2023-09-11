import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/pages/login.dart';

import 'authentication/pages/register.dart';
import 'firebase_options.dart';
import 'global/homepage.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 176, 42, 135)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const LoginPage(),
      routes: {
        '/login':(context) => const LoginPage(),
        '/register':(context) => const RegisterPage(),
      },
    );
  }
}
