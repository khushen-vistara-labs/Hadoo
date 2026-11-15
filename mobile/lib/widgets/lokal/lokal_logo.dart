import 'package:flutter/material.dart';

/// The original Hadoo mark. The class name stays stable for inherited views.
class LokalLogo extends StatelessWidget {
  const LokalLogo({super.key, this.size = 28});
  static const asset = 'assets/branding/hadoo-mark.png';
  static const stickerAsset = asset;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Hadoo',
    child: Image.asset(asset, width: size, height: size,
      fit: BoxFit.contain, excludeFromSemantics: true),
  );
}
