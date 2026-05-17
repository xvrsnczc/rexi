import 'package:flutter/material.dart';

/// Avatar con badge verde de verificado.
class AvatarVerified extends StatelessWidget {
  const AvatarVerified({
    super.key,
    this.photoUrl,
    this.radius = 44,
    this.verified = false,
  });

  final String? photoUrl;
  final double radius;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
          child: photoUrl == null
              ? Icon(Icons.person, size: radius * 1.1, color: const Color(0xFF7B2CBF))
              : null,
        ),
        if (verified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
            ),
          ),
      ],
    );
  }
}
