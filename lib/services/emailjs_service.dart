import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../config/emailjs_config.dart';

class EmailJsService {
  EmailJsService._();

  static final Random _random = Random.secure();
  static final Uri _sendUri = Uri.parse(
    'https://api.emailjs.com/api/v1.0/email/send',
  );

  static Future<OtpChallenge> sendRegistrationOtp(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      throw const EmailJsException('Email is required.');
    }
    if (EmailJsConfig.privateKey.isEmpty) {
      throw const EmailJsException(
        'Email verification is not configured. Set EMAILJS_PRIVATE_KEY at build time.',
      );
    }

    final code = (_random.nextInt(900000) + 100000).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 15));

    final response = await http.post(
      _sendUri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': EmailJsConfig.serviceId,
        'template_id': EmailJsConfig.templateId,
        'user_id': EmailJsConfig.publicKey,
        'accessToken': EmailJsConfig.privateKey,
        'template_params': {
          'to_email': trimmedEmail,
          'passcode': code,
          'expires_at': _formatExpiry(expiresAt),
          'company_name': EmailJsConfig.companyName,
          'website_link': EmailJsConfig.websiteLink,
          'logo_url': EmailJsConfig.logoUrl,
        },
      }),
    );

    if (response.statusCode != 200) {
      final body = response.body.trim();
      throw EmailJsException(
        body.isEmpty ? 'Failed to send OTP email.' : 'Failed to send OTP email: $body',
      );
    }

    return OtpChallenge(code: code, expiresAt: expiresAt);
  }

  static String _formatExpiry(DateTime value) {
    final hour = value.hour > 12 ? value.hour - 12 : value.hour == 0 ? 12 : value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final meridiem = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.month}/${value.day}/${value.year} $hour:$minute $meridiem';
  }
}

class OtpChallenge {
  const OtpChallenge({
    required this.code,
    required this.expiresAt,
  });

  final String code;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class EmailJsException implements Exception {
  const EmailJsException(this.message);

  final String message;

  @override
  String toString() => message;
}
