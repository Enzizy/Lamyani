import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/emailjs_service.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/otp_verification_sheet.dart';
import '../widgets/primary_button.dart';
import 'app_shell.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypePasswordController = TextEditingController();

  bool _emailUpdates = false;
  bool _hidePassword = true;
  bool _hideRetypePassword = true;
  bool _submitting = false;
  DateTime? _birthDate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  void _openApp() {
    Navigator.of(context).pushReplacement(AppMotion.route(const AppShell()));
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(AppMotion.route(const LoginScreen()));
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      initialDate: DateTime(now.year - 18, now.month, now.day),
    );

    if (selected == null) {
      return;
    }

    _birthDate = selected;
    _birthDateController.text =
        '${selected.month}/${selected.day}/${selected.year}';
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthDate == null) {
      _showMessage('Select your date of birth.');
      return;
    }

    if (!AuthService.isAvailable) {
      _showMessage('Firebase auth is configured for mobile in this project.');
      return;
    }

    setState(() => _submitting = true);

    try {
      final challenge = await EmailJsService.sendRegistrationOtp(
        _emailController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() => _submitting = false);

      final verified = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: AppColors.white,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) {
          return OtpVerificationSheet(
            email: _emailController.text.trim(),
            initialChallenge: challenge,
            onResend: () =>
                EmailJsService.sendRegistrationOtp(_emailController.text),
          );
        },
      );

      if (verified != true) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() => _submitting = true);

      await AuthService.signUp(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        birthDate: _birthDate!,
        email: _emailController.text,
        mobileNumber: '+63${_mobileController.text.trim()}',
        password: _passwordController.text,
        emailUpdates: _emailUpdates,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pushAndRemoveUntil(AppMotion.route(const AppShell()), (route) => false);
    } catch (error) {
      final message = error is EmailJsException
          ? error.message
          : AuthService.messageFor(error);
      _showMessage(message);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _openApp,
                    icon: const Icon(Icons.close_rounded, size: 30),
                  ),
                  const Spacer(),
                  const Hero(tag: 'brand-logo', child: BrandLogo(size: 42)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFF8F2),
                              Color(0xFFFFF1E4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.peachSurface.withValues(alpha: 0.9),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'New member setup',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.primaryOrange,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                const Spacer(),
                                const BrandLogo(size: 34),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: const [
                                Expanded(
                                  child: _SignupBenefit(
                                    icon: Icons.pin_drop_outlined,
                                    label: 'Nearby branches',
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: _SignupBenefit(
                                    icon: Icons.card_giftcard_rounded,
                                    label: 'Rewards access',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Create your Lamyani account',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sign up now to unlock exclusive promos, rewards, and faster checkout.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _SignupLabel('First Name *'),
                      const SizedBox(height: 10),
                      _SignupField(
                        controller: _firstNameController,
                        hint: 'Enter your first name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const _SignupLabel('Last Name *'),
                      const SizedBox(height: 10),
                      _SignupField(
                        controller: _lastNameController,
                        hint: 'Enter your last name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 340;

                          if (narrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SignupLabel('Date of Birth *'),
                                const SizedBox(height: 4),
                                Text(
                                  'Get a treat on your special day!',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              const Expanded(
                                child: _SignupLabel('Date of Birth *'),
                              ),
                              Text(
                                'Get a treat on your special day!',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _SignupField(
                        controller: _birthDateController,
                        hint: 'Select your date of birth',
                        readOnly: true,
                        onTap: _pickBirthDate,
                        suffix: const Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.mutedText,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Birth date is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const _SignupLabel('Email Address *'),
                      const SizedBox(height: 10),
                      _SignupField(
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
                      const SizedBox(height: 8),
                      Text(
                        'A one-time verification code will be sent to this email before your account is created.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _SignupLabel('Mobile Number *'),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 340;

                          if (narrow) {
                            return Column(
                              children: [
                                const _CountryCodeField(compact: true),
                                const SizedBox(height: 10),
                                _SignupField(
                                  controller: _mobileController,
                                  hint: 'Your mobile number',
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Mobile number is required.';
                                    }
                                    if (value.trim().length < 10) {
                                      return 'Enter a valid mobile number.';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              const _CountryCodeField(),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SignupField(
                                  controller: _mobileController,
                                  hint: 'Your mobile number',
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Mobile number is required.';
                                    }
                                    if (value.trim().length < 10) {
                                      return 'Enter a valid mobile number.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      const _SignupLabel('Password *'),
                      const SizedBox(height: 10),
                      _SignupField(
                        controller: _passwordController,
                        hint: 'Enter password',
                        obscureText: _hidePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required.';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters.';
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
                      const SizedBox(height: 18),
                      const _SignupLabel('Retype Password *'),
                      const SizedBox(height: 10),
                      _SignupField(
                        controller: _retypePasswordController,
                        hint: 'Retype password',
                        obscureText: _hideRetypePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Retype your password.';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                        suffix: IconButton(
                          onPressed: () => setState(
                            () => _hideRetypePassword = !_hideRetypePassword,
                          ),
                          icon: Icon(
                            _hideRetypePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _emailUpdates,
                            activeColor: AppColors.primaryOrange,
                            side: const BorderSide(color: Color(0xFFCFD4DA)),
                            onChanged: (value) {
                              setState(() => _emailUpdates = value ?? false);
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 11),
                              child: Text(
                                'Email me about discounts and promotions',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 15),
                          children: const [
                            TextSpan(text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Notice',
                              style: TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: _submitting
                            ? 'Creating Account...'
                            : 'Create Account',
                        onPressed: _submitting ? null : _createAccount,
                        backgroundColor: AppColors.primaryOrange,
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            GestureDetector(
                              onTap: _openLogin,
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _openApp,
                          child: const Text(
                            'Continue as Guest',
                            style: TextStyle(
                              color: AppColors.brownAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

class _SignupLabel extends StatelessWidget {
  const _SignupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
    );
  }
}

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
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

class _CountryCodeField extends StatelessWidget {
  const _CountryCodeField({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? double.infinity : 108,
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7DADF)),
      ),
      child: Row(
        children: [
          const Text(
            'PH',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Text(
            '+63',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 16),
          ),
          const Spacer(),
          if (!compact) const Icon(Icons.keyboard_arrow_down_rounded),
        ],
      ),
    );
  }
}

class _SignupBenefit extends StatelessWidget {
  const _SignupBenefit({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryOrange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.brownAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
