// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  Future<void> signup(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(
        context,
        '/logincredential',
        arguments: {'email': email},
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      Navigator.pushReplacementNamed(context, '/signup');
    } catch (e) {}
  }

  Future<void> signin(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Predefined admin email and password (replace these with your actual admin credentials)
      const String adminEmail = 'railtechadmin123@rail.com';
      const String adminPassword =
          'railtech123admin'; // You can also use hashed passwords for security

      await Future.delayed(const Duration(seconds: 1));

      // Check if the user is an admin
      if (email == adminEmail && password == adminPassword) {
        Navigator.pushReplacementNamed(context, '/homepage');
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/logincredential',
          arguments: {'email': email},
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      Navigator.pushReplacementNamed(context, '/signin');
    } catch (e) {}
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacementNamed(context, '/login');
  }

  // void checkUserSignedIn(context) async {
  //   User? user = FirebaseAuth.instance.currentUser;

  //   if (user != null) {
  //     // User is signed in, navigate to home page or the last visited page
  //     Navigator.pushReplacementNamed(context, '/home');
  //   } else {
  //     // User is not signed in, navigate to login page
  //     Navigator.pushReplacementNamed(context, '/login');
  //   }
  // }
}
