import 'package:flutter/material.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/models/user_profile.dart';

/// Circular avatar: photo (from memory bytes) or initials.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.profile, this.radius = 24});

  final UserProfile? profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bytes = profile?.photoBytes;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.softPink,
      backgroundImage: bytes == null ? null : MemoryImage(bytes),
      child: bytes != null
          ? null
          : Text(
              profile?.initials ?? 'B',
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedRose,
              ),
            ),
    );
  }
}
