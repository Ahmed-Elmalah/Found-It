import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.onEdit,
  });

  final UserProfileEntity profile;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initial = profile.fullName.trim().isNotEmpty
        ? profile.fullName.trim()[0].toUpperCase()
        : 'U';

    return Container(
      padding: EdgeInsetsDirectional.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outline, width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profile.avatarUrl!,
                      width: 64.r,
                      height: 64.r,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitial(colors, initial),
                    ),
                  )
                : _buildInitial(colors, initial),
          ),
          SizedBox(width: 16.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (profile.phone != null && profile.phone!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    profile.phone!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Edit icon
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                color: colors.primary,
                size: 20.r,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitial(ColorScheme colors, String initial) {
    return Text(
      initial,
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: colors.primary,
      ),
    );
  }
}
