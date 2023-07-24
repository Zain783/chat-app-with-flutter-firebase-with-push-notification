import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_task_app/utils/background.dart';

import 'components/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const route = "loginscreen";

  void _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Password reset email sent successfully, show a success message or navigate to a different screen.
    } catch (error) {
      // Handle password reset email sending errors, show an error message or perform any additional operations.
      print('Password reset failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // const LoginScreenTopImage(),
          Row(
            children: [
              const Spacer(),
              Expanded(
                flex: 8,
                child: LoginForm(
                  onForgotPassword: _resetPassword,
                ),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
