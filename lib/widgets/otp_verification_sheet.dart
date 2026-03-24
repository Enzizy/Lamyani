import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/emailjs_service.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';

class OtpVerificationSheet extends StatefulWidget {
  const OtpVerificationSheet({
    super.key,
    required this.email,
    required this.initialChallenge,
    required this.onResend,
  });

  final String email;
  final OtpChallenge initialChallenge;
  final Future<OtpChallenge> Function() onResend;

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  static const Duration _resendCooldown = Duration(seconds: 30);
  static const int _maxFailedAttempts = 5;

  final TextEditingController _otpController = TextEditingController();

  late OtpChallenge _challenge;
  Timer? _ticker;
  Duration _timeLeft = Duration.zero;
  Duration _resendTimeLeft = Duration.zero;
  String? _errorText;
  bool _resending = false;
  int _failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _challenge = widget.initialChallenge;
    _syncTimeLeft();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _syncTimeLeft());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _syncTimeLeft() {
    final remaining = _challenge.expiresAt.difference(DateTime.now());
    final resendRemaining = _challenge.expiresAt
        .subtract(const Duration(minutes: 15))
        .add(_resendCooldown)
        .difference(DateTime.now());
    if (!mounted) {
      return;
    }
    setState(() {
      _timeLeft = remaining.isNegative ? Duration.zero : remaining;
      _resendTimeLeft = resendRemaining.isNegative ? Duration.zero : resendRemaining;
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0');
    final resendSeconds = _resendTimeLeft.inSeconds.toString().padLeft(2, '0');

    return SafeArea(
      top: false,
      child: Padding(
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
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.peachSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.peachSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 36,
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Verify your email',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit OTP to ${_maskEmail(widget.email)}. Enter it below to finish creating your Lamyani account.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _OtpMetaPill(
                  icon: Icons.schedule_rounded,
                  label: _timeLeft == Duration.zero
                      ? 'Code expired'
                      : 'Valid for $minutes:$seconds',
                ),
                _OtpMetaPill(
                  icon: Icons.shield_outlined,
                  label:
                      '${_maxFailedAttempts - _failedAttempts} attempts left',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                letterSpacing: 10,
              ),
              decoration: InputDecoration(
                hintText: '------',
                errorText: _errorText,
              ),
              onChanged: (value) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
                if (value.trim().length == 6) {
                  _verifyOtp();
                }
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Paste the 6-digit code exactly as it appears in your email.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resending || _resendTimeLeft > Duration.zero
                      ? null
                      : _resendOtp,
                  child: Text(
                    _resending
                        ? 'Resending...'
                        : _resendTimeLeft > Duration.zero
                            ? 'Resend in ${resendSeconds}s'
                            : 'Resend OTP',
                    style: const TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Verify OTP',
              icon: Icons.verified_rounded,
              onPressed: _verifyOtp,
            ),
          ],
        ),
      ),
    );
  }

  void _verifyOtp() {
    final entered = _otpController.text.trim();
    if (_challenge.isExpired) {
      setState(() => _errorText = 'OTP expired. Request a new code.');
      return;
    }
    if (_failedAttempts >= _maxFailedAttempts) {
      setState(() => _errorText = 'Too many incorrect attempts. Request a new OTP.');
      return;
    }
    if (entered.length != 6) {
      setState(() => _errorText = 'Enter the 6-digit OTP.');
      return;
    }
    if (entered != _challenge.code) {
      _failedAttempts += 1;
      setState(() {
        _errorText = _failedAttempts >= _maxFailedAttempts
            ? 'Too many incorrect attempts. Request a new OTP.'
            : 'OTP is incorrect. Try again.';
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _resendOtp() async {
    setState(() {
      _resending = true;
      _errorText = null;
    });

    try {
      final challenge = await widget.onResend();
      if (!mounted) {
        return;
      }
      _otpController.clear();
      setState(() {
        _challenge = challenge;
        _failedAttempts = 0;
      });
      _syncTimeLeft();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('A new OTP was sent to ${_maskEmail(widget.email)}.'),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) {
      return email;
    }

    final local = parts.first;
    final domain = parts.last;
    if (local.length <= 2) {
      return '${local[0]}***@$domain';
    }

    return '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}@$domain';
  }
}

class _OtpMetaPill extends StatelessWidget {
  const _OtpMetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryOrange),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
