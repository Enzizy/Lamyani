import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;

  bool get _isNetwork {
    final uri = Uri.tryParse(source);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.hasAuthority;
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return _AppImagePlaceholder(width: width, height: height);
        },
        errorBuilder: (_, _, _) =>
            _AppImagePlaceholder(width: width, height: height),
      );
    }

    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, _, _) => _AppImagePlaceholder(width: width, height: height),
    );
  }
}

class _AppImagePlaceholder extends StatelessWidget {
  const _AppImagePlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFFFF8F2),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 40,
        color: AppColors.mutedText,
      ),
    );
  }
}
