import 'dart:math';
import 'dart:ui';
import 'package:flashcards/cubits/auth.dart';
import 'package:flashcards/presentation/home_page.dart';
import 'package:flashcards/utils.dart';
import 'package:flashcards/presentation/widgets/default_body.dart';
import 'package:flashcards/presentation/widgets/my_snack_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  static const String route = "/login";
  const LoginPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: DefaultBody(
        child: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is SuccessAuthState && state.autoLogin) {
              print("builder");
              Future.microtask(
                  () => Navigator.pushNamed(context, HomePage.route));
            }

            final cubit = context.read<AuthCubit>();
            return LoginBackgroud(
              child: LoginForm(
                onLogin: (username, password, autologin) {
                  cubit.login(username, password);
                },
                onOfflineMode: () => cubit.guestLogin(),
              ),
            );
          },
          listener: (context, state) {
            if ((state is SuccessAuthState) || state is GuestAuthState) {
              print("listener");
              Navigator.pushNamed(context, HomePage.route);
            } else if (state is ErrorAuthState) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(quickSnack(state.message));
            }
          },
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm(
      {super.key, required this.onLogin, required this.onOfflineMode});
  final void Function(String, String, bool) onLogin;
  final void Function() onOfflineMode;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _autoLogin = (kIsWeb) ? false : true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;
      widget.onLogin(email, password, _autoLogin);
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
              BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                final isLoading = state is LoadingAuthState;
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      child: isLoading
                          ? const LinearProgressIndicator()
                          : const Text('Login'),
                    ),
                    addSpacing(height: 16.0),
                    ElevatedButton(
                      onPressed:
                          isLoading ? null : () => widget.onOfflineMode(),
                      child: const Text('Offline mode'),
                    ),
                  ],
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}

class LoginBackgroud extends StatelessWidget {
  final Widget child;
  const LoginBackgroud({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 5),
          child: Container(
            color:
                Theme.of(context).colorScheme.secondaryContainer.withAlpha(100),
            padding: const EdgeInsets.all(25),
            child: child,
          ),
        ),
      ),
    );
  }
}
