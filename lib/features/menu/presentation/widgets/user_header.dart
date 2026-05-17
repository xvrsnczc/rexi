import 'package:flutter/material.dart';

/// Cabecera del drawer: foto, nombre, email, verificado, Perfil / Salir.
class UserHeader extends StatelessWidget {
  const UserHeader({
    super.key,
    required this.displayName,
    required this.email,
    required this.onProfile,
    required this.onLogout,
    this.verified = false,
  });

  final String displayName;
  final String email;
  final VoidCallback onProfile;
  final VoidCallback onLogout;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE91E8C),
            Color(0xFF7B2CBF),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 48, color: Color(0xFF7B2CBF)),
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
            ),
            const SizedBox(height: 14),
            Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7B2CBF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: onProfile,
                    child: const Text('Perfil'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B4A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: onLogout,
                    child: const Text('Salir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
