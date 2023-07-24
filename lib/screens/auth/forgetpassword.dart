import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../resources/auth_methords.dart';
import '../../utils/background.dart';
import '../../utils/utils.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isResettingPassword = false;

  Future<void> _resetPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final _auth = AuthMethods();
      final email = _emailController.text.trim();

      setState(() {
        _isResettingPassword = true;
      });

      try {
        await _auth.resetPassword(_emailController.text.trim(), context);
        showSnackBar(context, 'Password reset email sent!');
      } catch (error) {
        showSnackBar(context, error.toString());
      }

      setState(() {
        _isResettingPassword = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      cursorColor: kPrimaryColor,
                      onSaved: (email) {},
                      decoration: InputDecoration(
                        hintText: 'Your email',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(defaultPadding),
                          child: Icon(Icons.email),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Hero(
                      tag: 'reset_password_btn',
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _resetPassword(context);
                          },
                          child: _isResettingPassword
                              ? SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.purple,
                                  ),
                                )
                              : Text(
                                  'Send Mail'.toUpperCase(),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
