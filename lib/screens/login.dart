import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [EmailAuthProvider()],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Home()));
        }),
        AuthStateChangeAction<UserCreated>((context, state) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Home()));
        }),
      ],
    );
  }
}
