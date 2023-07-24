import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../login_screen.dart';
import '../signup_screen.dart';

class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple, elevation: 0),
            onPressed: () {
              Navigator.pushNamed(context, LoginScreen.route);
            },
            child: Text(
              "Login".toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, SignUpScreen.route);
            },
            style: ElevatedButton.styleFrom(
                primary: kPrimaryLightColor, elevation: 0),
            child: Text(
              "Sign Up".toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
