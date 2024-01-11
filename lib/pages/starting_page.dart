import 'dart:math';
import 'dart:ui';
import 'package:flashcards/model/db.dart';
import 'package:flashcards/utils.dart';
import 'package:flashcards/widgets/default_body.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class StartingPage extends StatelessWidget {
  const StartingPage({
    super.key,
  });

  SnackBar _snackBar(String msg) {
    return SnackBar(
        content: Text(
      msg,
      textAlign: TextAlign.center,
    ));
  }

  Future<bool> tryLogin(BuildContext context, String email, String password,
      bool autoLogin) async {
    try {
      await Provider.of<DatabaseModel>(context, listen: false)
          .login(email, password, autoLogin);
      // if (context.mounted) {
      // openApp(context);
      // }
      return true;
    } on ClientException catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_snackBar(err.response["message"].toString()));
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultBody(
        child: Consumer<DatabaseModel>(
          builder: (context, value, child) => FutureBuilder(
              future: value.autoLogin(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    return Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 5),
                          child: Container(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withAlpha(100),
                            padding: const EdgeInsets.all(25),
                            child: LoginWidget(onLogin: tryLogin),
                          ),
                        ),
                      ),
                    );
                }
              }),
        ),
      ),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key, required this.onLogin});
  final Future<bool> Function(BuildContext, String, String, bool) onLogin;

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _autoLogin = (kIsWeb) ? false : true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      setState(() {
        _loading = true;
      });
      bool success = await widget.onLogin(context, email, password, _autoLogin);

      if (success) {}

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: min(width * 0.7, 400),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autofillHints: const [AutofillHints.username],
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Login',
                  icon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username or your email';
                  }
                  // You can add more sophisticated email validation logic if needed
                  return null;
                },
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              addSpacing(height: 16),
              TextFormField(
                autofillHints: const [AutofillHints.password],
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  icon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  // You can add more sophisticated password validation logic if needed
                  return null;
                },
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              addSpacing(height: 24.0),
              if (!kIsWeb)
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-Login'),
                  value: _autoLogin,
                  onChanged: (value) {
                    setState(() {
                      _autoLogin = value!;
                    });
                  },
                ),
              ElevatedButton(
                onPressed: _loading ? null : _handleLogin,
                child: _loading
                    ? const LinearProgressIndicator()
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
