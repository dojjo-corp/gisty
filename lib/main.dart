import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/pages/about_us.dart';
import 'package:gt_daily/authentication/pages/notifications_page.dart';
import 'package:gt_daily/authentication/pages/projects/add_project_page.dart';
import 'package:gt_daily/authentication/pages/contact_us.dart';
import 'package:gt_daily/authentication/pages/projects/saved_projects.dart';
import 'package:gt_daily/authentication/pages/user%20account/edit_account_page.dart';
import 'package:gt_daily/authentication/pages/user%20authentication/login.dart';
import 'package:gt_daily/authentication/providers/projects_provider.dart';
import 'package:gt_daily/global/homepage.dart';
import 'package:provider/provider.dart';

import 'authentication/gates/auth_gate.dart';
import 'authentication/pages/messaging/chat_list_page.dart';
import 'authentication/pages/user authentication/password_reset.dart';
import 'authentication/pages/user authentication/phone_verification.dart';
import 'authentication/pages/user authentication/register.dart';
import 'authentication/pages/projects/supervised_projects.dart';
import 'authentication/providers/user_provider.dart';
// import 'authentication/repository/firebase_messaging.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        '/reset-password': (context) => const PasswordResetPage(),
        '/verify-phone': (context) => const PhoneverificationPage(),
        '/home': (context) => MyHomePage(pageIndex: 0),
        '/add-project': (context) => const NewProjectPage(),
        '/edit-profile': (context) => const EditAccount(),
        '/about-us': (context) => const AboutUsPage(),
        '/contact-us': (context) => const ContactUsPage(),
        '/supervised-projects': (context) => const SupervisedProjects(),
        '/messaging': (context) =>  ChatListPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/saved-projects': (context) => const SavedProjects(),
      },
    );
  }
}
