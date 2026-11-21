import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';

/// Card showing the other party's verified contact information on the handover screen.
class VerifiedContactCard extends StatelessWidget {
  final HandoverContactEntity contact;

  const VerifiedContactCard({
    super.key,
    required this.contact,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 18.r,
                color: colors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  l10n.contactInfoTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Name
          _ContactRow(
            icon: Icons.person_outline_rounded,
            label: l10n.contactName,
            value: contact.fullName,
          ),

          // Phone
          if (contact.phone != null && contact.phone!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _ContactRow(
              icon: Icons.phone_outlined,
              label: l10n.contactPhone,
              value: contact.phone!,
              onCopy: () => _copyToClipboard(
                context,
                contact.phone!,
                l10n.contactPhone,
              ),
            ),
          ],

          // Email
          if (contact.email.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _ContactRow(
              icon: Icons.email_outlined,
              label: l10n.contactEmail,
              value: contact.email,
              onCopy: () => _copyToClipboard(
                context,
                contact.email,
                l10n.contactEmail,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16.r, color: colors.onSurfaceVariant),
        SizedBox(width: 8.w),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 12.sp,
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: Icon(Icons.copy_rounded, size: 16.r),
            color: colors.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Copy',
          ),
      ],
    );
  }
}
