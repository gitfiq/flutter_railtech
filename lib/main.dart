import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_railtech/pages/detailpage.dart';
import 'package:flutter_railtech/pages/errorpage.dart';
import 'package:flutter_railtech/pages/homepage.dart';
import 'package:flutter_railtech/pages/bookinformpage.dart';
import 'package:flutter_railtech/pages/loginpage.dart';
import 'package:flutter_railtech/pages/recordpage.dart';
import 'package:flutter_railtech/pages/signinpage.dart';
import 'package:flutter_railtech/pages/signuppage.dart';
import 'package:flutter_railtech/pages/workerrecordpage.dart';
import 'package:flutter_railtech/services/navigational_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? lastVisitedRoute;
  Map<String, dynamic>? arguments;
  User? user;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    prefs = await SharedPreferences.getInstance();
    lastVisitedRoute = prefs.getString('lastVisitedRoute') ?? '/login';
    String? lastVisitedRouteArgs = prefs.getString('lastVisitedRouteArgs');

    if (lastVisitedRouteArgs != null) {
      arguments = jsonDecode(lastVisitedRouteArgs);
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Ensure the user data is up-to-date
      user = FirebaseAuth.instance.currentUser;
    } else {
      lastVisitedRoute = '/login';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_navigatorKey.currentContext != null) {
        Navigator.pushReplacementNamed(
          _navigatorKey.currentContext!,
          lastVisitedRoute!,
          arguments: arguments,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MRT Monitoring System',
        navigatorObservers: [RouteObserverSingleton.instance],
        navigatorKey: _navigatorKey,
        initialRoute: '/login',
        onGenerateRoute: (RouteSettings settings) {
          final arguments = settings.arguments as Map<String, dynamic>?;

          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(
                builder: (context) => const Loginpage(),
                settings: const RouteSettings(name: '/login'),
              );
            case '/logincredential':
              final email = arguments?['email'] as String;
              return MaterialPageRoute(
                builder: (context) => Logincredentialpage(email: email),
                // settings: RouteSettings(
                //     name: '/logincredential', arguments: {'email': email}),
              );
            case '/signup':
              return MaterialPageRoute(
                builder: (context) => const Signuppage(),
                settings: const RouteSettings(name: '/signup'),
              );
            case '/signin':
              return MaterialPageRoute(
                builder: (context) => const Signinpage(),
                settings: const RouteSettings(name: '/signin'),
              );
            case '/homepage':
              return MaterialPageRoute(
                builder: (context) => const Homepage(),
                settings: const RouteSettings(name: '/homepage'),
              );
            case '/details':
              final stationName = arguments?['stationName'] as String;
              return MaterialPageRoute(
                builder: (context) => Detailpage(stationName: stationName),
                // settings: RouteSettings(
                //     name: '/details', arguments: {'stationName': stationName}),
              );
            case '/workersrecord':
              final workerName = arguments?['workerName'] as String;
              return MaterialPageRoute(
                builder: (context) => Workerrecordpage(workerName: workerName),
                // settings: RouteSettings(
                //     name: '/workersrecord',
                //     arguments: {'workerName': workerName}),
              );
            case '/record':
              return MaterialPageRoute(
                builder: (context) => const Recordpage(),
                settings: const RouteSettings(name: '/record'),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const Errorpage(),
              );
          }
        });
  }
}










 // // Fetch the last visited route from SharedPreferences
  // Future<void> _getLastVisitedRoute() async {
  //   prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     lastVisitedRoute = prefs.getString('lastVisitedRoute') ?? '/login';
  //     String? lastVisitedRouteArgs = prefs.getString('lastVisitedRouteArgs');

  //     if (lastVisitedRouteArgs != null) {
  //       arguments = jsonDecode(lastVisitedRouteArgs);
  //     }
  //   });
  // }

  // void _checkUserSignedIn() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     await user.reload(); // Ensure the user data is up-to-date
  //     user = FirebaseAuth.instance.currentUser;

  //     // prefs = await SharedPreferences.getInstance();
  //     // String? lastVisitedRoute =
  //     //     prefs.getString('lastVisitedRoute') ?? '/homepage';
  //     // String? lastVisitedRouteArgs = prefs.getString('lastVisitedRouteArgs');
  //     // Map<String, dynamic>? arguments;

  //     // if (lastVisitedRouteArgs != null) {
  //     //   arguments = jsonDecode(lastVisitedRouteArgs);
  //     // }

  //     print("Navigating to: $lastVisitedRoute");

  //     // WidgetsBinding.instance.addPostFrameCallback((_) {
  //     //   if (_navigatorKey.currentContext != null) {
  //     //     Navigator.pushReplacementNamed(
  //     //         _navigatorKey.currentContext!, lastVisitedRoute);
  //     //   }
  //     // });

  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (_navigatorKey.currentContext != null) {
  //         Navigator.pushReplacementNamed(
  //           _navigatorKey.currentContext!,
  //           lastVisitedRoute!,
  //           arguments: arguments,
  //         );
  //       }
  //     });
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (_navigatorKey.currentContext != null) {
  //         Navigator.pushReplacementNamed(
  //             _navigatorKey.currentContext!, '/login');
  //       }
  //     });
  //   }
  // }
