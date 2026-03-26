import 'package:flutter/material.dart';
import '../../../../../core/extensions/responsive_extensions.dart';


class PhotoStackImage extends StatelessWidget {
  const PhotoStackImage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.radius()),
      child: Stack(
        children: [
          Image.asset(
            "assets/images/group.jpg",
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),

          // Example overlays
          Positioned(
            top: 30,
            left: 40,
            child: _circleLabel("YOU", Colors.orange),
          ),
          Positioned(
            top: 80,
            right: 50,
            child: _circleLabel("?", Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _circleLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}