import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/mock_data.dart';

class LocationService {
  LocationService._();

  static Future<LocationPermissionStatus> requestLocationPermission() async {
    if (kIsWeb) {
      return LocationPermissionStatus.granted;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.disabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.granted;
  }

  static Future<Position> getCurrentPosition() async {
    final permissionStatus = await requestLocationPermission();

    if (permissionStatus == LocationPermissionStatus.disabled) {
      throw const LocationException(
        'Location services are turned off on this device.',
      );
    }
    if (permissionStatus == LocationPermissionStatus.denied) {
      throw const LocationException('Location permission was denied.');
    }
    if (permissionStatus == LocationPermissionStatus.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied. Enable it in settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  static double distanceInKm({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    final meters = Geolocator.distanceBetween(
      fromLatitude,
      fromLongitude,
      toLatitude,
      toLongitude,
    );
    return meters / 1000;
  }

  static String formatDistanceKm(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  static Future<void> openDirections(StoreItem store) async {
    final lat = store.latitude;
    final lng = store.longitude;
    final encodedLabel = Uri.encodeComponent(store.name);

    final geoUri = Uri.parse('geo:0,0?q=$lat,$lng($encodedLabel)');
    final appleMapsUri = Uri.parse(
      'http://maps.apple.com/?ll=$lat,$lng&q=$encodedLabel',
    );
    final openStreetMapUri = Uri.parse(
      'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=17/$lat/$lng',
    );

    if (!kIsWeb && Platform.isAndroid && await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
      return;
    }

    if (!kIsWeb && Platform.isIOS && await canLaunchUrl(appleMapsUri)) {
      await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
      return;
    }

    await launchUrl(openStreetMapUri, mode: LaunchMode.externalApplication);
  }
}

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum LocationPermissionStatus { granted, denied, deniedForever, disabled }
