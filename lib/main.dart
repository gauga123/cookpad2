import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'utils/routes.dart';
import 'screens/login_screen.dart';
import 'screens/admin_page.dart';
import 'screens/main_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Khởi tạo Firebase Messaging chỉ khi không phải web
    if (!kIsWeb) {
      try {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
        await messaging.subscribeToTopic('all');
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
          final videoLink = message.data['videoLink'];
          if (videoLink != null && videoLink.isNotEmpty) {
            print('Video link received in foreground: $videoLink');
          }
        });
      } catch (e) {
        print('Error initializing Firebase Messaging: $e');
      }
    } else {
      print('Firebase Messaging is not supported on web.');
    }

    runApp(const MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  final videoLink = message.data['videoLink'];
  if (videoLink != null && videoLink.isNotEmpty) {
    print('Video link received: $videoLink');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF232323),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF232323),
            elevation: 0,
          ),
        ),
        initialRoute: AppRoutes.welcome,
        routes: AppRoutes.getRoutes(),
        onGenerateRoute: (settings) {
          return null;
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Page not found')),
            ),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading auth state'));
        }

        if (snapshot.hasData) {
          if (!kIsWeb) {
            try {
              final userId = snapshot.data!.uid;
              FirebaseMessaging.instance.subscribeToTopic(userId);
              print('Subscribed to topic: $userId');
            } catch (e) {
              print('Error subscribing to topic: $e');
            }
          } else {
            print('Topic subscription is not supported on web.');
          }

          return FutureBuilder<String>(
            future: AuthService().getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (roleSnapshot.hasError) {
                return const Center(child: Text('Error loading user role'));
              }

              final role = roleSnapshot.data ?? 'user';
              return role == 'admin' ? const AdminPage() : const MainScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}

class MyAppState extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
