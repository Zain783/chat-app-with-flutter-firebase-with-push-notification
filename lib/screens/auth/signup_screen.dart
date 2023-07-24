import 'package:flutter/material.dart';
import '../../utils/background.dart';
import 'components/signup_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);
static const route="signupscreen";
  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
       child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // const SignUpScreenTopImage(),
            Row(
              children: [
                Spacer(),
                Expanded(
                  flex: 8,
                  child: SignUpForm(),
                ),
                Spacer(),
              ],
            ),
            // const SocalSignUp()
          ],
        ),
      ),
    );
  }
}
