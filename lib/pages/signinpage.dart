import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_railtech/services/auth_service.dart';

class Signinpage extends StatefulWidget {
  const Signinpage({super.key});

  @override
  State<Signinpage> createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
  bool _isObscured = true;

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 145, 232),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                "Sign In ",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 80,
              ),
              _emailAddress(context),
              const SizedBox(
                height: 30,
              ),
              _password(context),
              const SizedBox(
                height: 50,
              ),
              _signin(context),
              const SizedBox(
                height: 30,
              ),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailAddress(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email Address',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(
            height: 16,
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
                filled: true,
                hintText: 'Enter Email',
                hintStyle: const TextStyle(
                    color: Color(0xff6A6A6A),
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
                fillColor: const Color(0xffF7F7F9),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(14))),
          )
        ],
      ),
    );
  }

  Widget _password(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(
            height: 16,
          ),
          TextField(
            obscureText: _isObscured,
            controller: _passwordController,
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
                hintText: 'Enter Password',
                hintStyle: const TextStyle(
                    color: Color(0xff6A6A6A),
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
                filled: true,
                fillColor: const Color(0xffF7F7F9),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(14))),
          )
        ],
      ),
    );
  }

  Widget _signin(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 2, 38, 92),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 60),
          elevation: 0,
        ),
        onPressed: () async {
          await AuthService().signin(
              email: _emailController.text,
              password: _passwordController.text,
              context: context);
        },
        child: const Text(
          "Sign In",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _signup(context) {
    return RichText(
      text: TextSpan(
        text: "New User? ",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: "Sign up",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
          ),
        ],
      ),
    );
  }
}
