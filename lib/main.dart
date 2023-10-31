import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/about_us.dart';
import 'package:gt_daily/authentication/pages/events/add_new_event.dart';
import 'package:gt_daily/authentication/pages/events/event_details_page.dart';
import 'package:gt_daily/authentication/pages/give_feedback.dart';
import 'package:gt_daily/authentication/pages/jobs/job_details.dart';
import 'package:gt_daily/authentication/pages/messaging/chat_page.dart';
import 'package:gt_daily/authentication/pages/notifications/notifications_page.dart';
import 'package:gt_daily/authentication/pages/projects/add_project_page.dart';
import 'package:gt_daily/authentication/pages/contact_us.dart';
import 'package:gt_daily/authentication/pages/projects/project_details.dart';
import 'package:gt_daily/authentication/pages/projects/saved_projects.dart';
import 'package:gt_daily/authentication/pages/user%20account/edit_account_page.dart';
import 'package:gt_daily/authentication/providers/projects_provider.dart';
import 'package:gt_daily/global/homepage.dart';
import 'package:provider/provider.dart';

import 'authentication/gates/auth_gate.dart';
import 'authentication/pages/messaging/chat_list_page.dart';
import 'authentication/pages/projects/project_archive.dart';
import 'authentication/pages/user authentication/password_reset.dart';
import 'authentication/pages/user authentication/phone_verification.dart';
import 'authentication/pages/user authentication/register.dart';
import 'authentication/pages/projects/supervised_projects.dart';
import 'authentication/providers/connectivity_provider.dart';
import 'authentication/providers/user_provider.dart';
import 'authentication/repository/firebase_messaging.dart';
import 'firebase_options.dart';

// Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FireMessaging().initNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[800]!),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: GoogleFonts.openSansTextTheme(),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle:  TextStyle(
            color: Colors.grey[100],
          ),
        ),
      ),
      routes: {
        '/': (context) => const AuthGate(),
        '/register': (context) => const RegisterPage(),
        '/reset-password': (context) => const PasswordResetPage(),
        '/verify-phone': (context) => const PhoneVerificationPage(),
        '/home': (context) => MyHomePage(pageIndex: 0),
        '/add-project': (context) => const NewProjectPage(),
        '/edit-profile': (context) => const EditAccount(),
        '/about-us': (context) => const AboutUsPage(),
        '/contact-us': (context) => const ContactUsPage(),
        '/supervised-projects': (context) => const SupervisedProjects(),
        '/messaging': (context) => ChatListPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/saved-projects': (context) => const SavedProjects(),
        '/archive': (context) => const ProjectArchive(),
        '/new-event': (context) => const AddNewEventPage(),
        '/feedback': (context) => const GiveFeedbackPage(),
      },
      // todo: handle route navigation from clicking notifications
      onGenerateRoute: (settings) {
        final name = settings.name;
        final args = settings.arguments as Map<String, dynamic>;

        // Chat Page
        if (name == '/chat-page') {
          return MaterialPageRoute(
            builder: (context) => ChatPage(
              roomId: args['room-id']!,
              receiverEmail: args['receiver-email']!,
            ),
          );
        }

        // Event Details Page
        if (name == '/event-details') {
          return MaterialPageRoute(
            builder: (context) =>
                EventDetailsPage(eventId: args['event-details']['id']),
          );
        }

        // Project Details Page
        if (name == '/project-details') {
          return MaterialPageRoute(
            builder: (context) => ProjectDetails(
                projectData: args['project-data'], goToComment: false),
          );
        }

        // Job Details Page
        if (name == '/job-details') {
          return MaterialPageRoute(
            builder: (context) => JobDetailsPage(jobId: args['job-details']['id']),
          );
        }

        ///xeed Go To Home Otherwise
        return null;
      },
    );
  }
}
