import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_railtech/services/auth_service.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  bool _isObscured = true;

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                "Register Account",
                style: TextStyle(
                    color: Colors.black,
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
              _signup(context),
              const SizedBox(
                height: 30,
              ),
              _signin(context),
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
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 18),
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
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 18),
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

  Widget _signup(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0D6EFD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 60),
          elevation: 0,
        ),
        onPressed: () async {
          await AuthService().signup(
              email: _emailController.text,
              password: _passwordController.text,
              context: context);
        },
        child: const Text(
          "Register",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _signin(context) {
    return RichText(
      text: TextSpan(
        text: "Already have an account? ",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        children: [
          TextSpan(
            text: "Sign In",
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushReplacementNamed(context, '/signin');
              },
          ),
        ],
      ),
    );
  }
}
