import 'dart:ui';
import 'package:flutter/material.dart';

class AuraBackground extends StatelessWidget {
  const AuraBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base light background
        Container(
          color: const Color(0xFFF4F8F7),
        ),
        
        // Teal Spot top-left
        Positioned(
          top: -120,
          left: -120,
          width: 320,
          height: 320,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F766E).withValues(alpha: 0.15),
            ),
          ),
        ),
        
        // Emerald Mint Spot bottom-right
        Positioned(
          bottom: -100,
          right: -100,
          width: 300,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withValues(alpha: 0.14),
            ),
          ),
        ),

        // Emergency Rose Spot middle-right
        Positioned(
          top: 180,
          right: -80,
          width: 250,
          height: 250,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF43F5E).withValues(alpha: 0.08),
            ),
          ),
        ),

        // Glassmorphism Blur filter
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
            child: const SizedBox.expand(),
          ),
        ),
        
        // Actual page contents
        Positioned.fill(child: child),
      ],
    );
  }
}
