# Lamyani

Flutter customer app for Lamyani ordering, account signup, branches, cart, and checkout.

## Run

```bash
flutter pub get
flutter run --dart-define=EMAILJS_PRIVATE_KEY=your_emailjs_private_key
```

## Build APK

```bash
flutter build apk --dart-define=EMAILJS_PRIVATE_KEY=your_emailjs_private_key
```

## EmailJS OTP

The signup OTP flow uses EmailJS. The private key is intentionally not committed in source.

Required build-time define:

```bash
--dart-define=EMAILJS_PRIVATE_KEY=your_emailjs_private_key
```

Configured non-secret EmailJS values live in:

- `lib/config/emailjs_config.dart`
