import 'package:flutter/material.dart';
import 'package:flutter_task_app/resources/auth_methords.dart';
import 'package:flutter_task_app/screens/auth/components/already_have_an_account_acheck.dart';
import 'package:flutter_task_app/screens/chat/chat_screen.dart';
import 'package:flutter_task_app/screens/chat/user_list_screen.dart';

import '../../../utils/colors.dart';
import '../../../utils/utils.dart';
import '../forgetpassword.dart';
import '../signup_screen.dart';

class LoginForm extends StatefulWidget {
  final Function(String email) onForgotPassword;

  LoginForm({
    Key? key,
    required this.onForgotPassword,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLogined = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            decoration: InputDecoration(
              hintText: "Your email",
              prefixIcon: const Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.email),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Your password",
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          Hero(
            tag: "login_btn",
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLogined = true;
                    });
                    final _auth = AuthMethods();
                    final response = await _auth.loginUser(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    showSnackBar(context, response);
                    setState(() {
                      isLogined = false;
                    });
                    if (response == 'success') {
                      Navigator.pushReplacementNamed(
                        context,
                        UserListScreen.route,
                      );
                    }
                  }
                },
                child: isLogined
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.purple,
                        ),
                      )
                    : Text(
                        "Login".toUpperCase(),
                      ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgetPasswordScreen(),
                  ));
            },
            child: const Text(
              "Forgot Password?",
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
