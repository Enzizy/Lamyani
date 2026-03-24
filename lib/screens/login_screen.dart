import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/primary_button.dart';
import 'app_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!AuthService.isAvailable) {
      _showMessage('Firebase auth is configured for mobile in this project.');
      return;
    }

    setState(() => _submitting = true);

    try {
      await AuthService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pushAndRemoveUntil(AppMotion.route(const AppShell()), (route) => false);
    } catch (error) {
      _showMessage(AuthService.messageFor(error));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openSignup() {
    Navigator.of(
      context,
    ).pushReplacement(AppMotion.route(const SignupScreen()));
  }

  Future<void> _forgotPassword() async {
    final emailController = TextEditingController(text: _emailController.text);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset password',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your account email and we\'ll send a reset link.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 18),
              _AuthField(
                controller: emailController,
                hint: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Send Reset Link',
                onPressed: () async {
                  try {
                    await AuthService.sendPasswordResetEmail(
                      emailController.text,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop();
                    _showMessage('Password reset link sent.');
                  } catch (error) {
                    if (!context.mounted) {
                      return;
                    }
                    _showMessage(AuthService.messageFor(error));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
              child: Row(
                children: [
                  const Hero(tag: 'brand-logo', child: BrandLogo(size: 46)),
                  const SizedBox(width: 12),
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log in to Lamyani',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Access your saved orders, reward points, and exclusive promos.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _AuthLabel('Email Address'),
                      const SizedBox(height: 10),
                      _AuthField(
                        controller: _emailController,
                        hint: 'Enter your email address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required.';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const _AuthLabel('Password'),
                      const SizedBox(height: 10),
                      _AuthField(
                        controller: _passwordController,
                        hint: 'Enter password',
                        obscureText: _hidePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required.';
                          }
                          return null;
                        },
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: _submitting ? 'Signing In...' : 'Log In',
                        onPressed: _submitting ? null : _login,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Need an account? ',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            GestureDetector(
                              onTap: _openSignup,
                              child: const Text(
                                'Create one',
                                style: TextStyle(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthLabel extends StatelessWidget {
  const _AuthLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        fillColor: const Color(0xFFFCFCFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD7DADF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primaryOrange,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
    );
  }
}
