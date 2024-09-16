import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_railtech/pages/detailpage.dart';
import 'package:flutter_railtech/pages/errorpage.dart';
import 'package:flutter_railtech/pages/homepage.dart';
import 'package:flutter_railtech/pages/logincredentialpage.dart';
import 'package:flutter_railtech/pages/loginpage.dart';
import 'package:flutter_railtech/pages/recordpage.dart';
import 'package:flutter_railtech/pages/workerrecordpage.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC8xQg1zCrXHFoVxyPg4VQBzfdj69VEg_c",
      appId: "1:866405918066:web:d7f6beb58274a33097a9eb",
      messagingSenderId: "866405918066",
      projectId: "rail-tech",
    ),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MRT Monitoring System',
        initialRoute: '/login',
        onGenerateRoute: (RouteSettings settings) {
          final arguments = settings.arguments as Map<String, dynamic>?;

          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(
                builder: (context) => const Loginpage(),
              );
            case '/logincredential':
              return MaterialPageRoute(
                builder: (context) => const Logincredentialpage(),
              );
            case '/homepage':
              return MaterialPageRoute(
                builder: (context) => const Homepage(),
              );
            case '/details':
              final stationName = arguments?['stationName'] as String;
              return MaterialPageRoute(
                builder: (context) => Detailpage(stationName: stationName),
              );
            case '/workersrecord':
              final workerName = arguments?['workerName'] as String;
              return MaterialPageRoute(
                builder: (context) => Workerrecordpage(workerName: workerName),
              );
            case '/record':
              return MaterialPageRoute(
                builder: (context) => const Recordpage(),
              );
            default:
              return MaterialPageRoute(
                builder: (context) =>
                    const Errorpage(), // A page for handling unknown routes
              );
          }
        });
  }
}
