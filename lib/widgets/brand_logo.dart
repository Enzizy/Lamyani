import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 120, this.showShadow = false});

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.asset('assets/Lamyani Logo.png', fit: BoxFit.cover),
      ),
    );
  }
}
