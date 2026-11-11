import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:found_it/core/constants/app_limits.dart';
import 'package:found_it/core/localization/app_localizations.dart';

/// Grid photo uploader (1–4 photos).
/// Rejected photos (wrong type or size) are shown with a red "Rejected" badge.
class PhotoUploaderWidget extends StatelessWidget {
  final List<XFile> photos;
  final Set<int> rejectedIndices;
  final String? errorText;
  final void Function(ImageSource source) onAddPhoto;
  final void Function(int index) onRemovePhoto;

  const PhotoUploaderWidget({
    super.key,
    required this.photos,
    required this.rejectedIndices,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final hasError = errorText != null;

    // Count of valid (non-rejected) photos
    final validCount = photos
        .asMap()
        .entries
        .where((e) => !rejectedIndices.contains(e.key))
        .length;

    final showAddSlot = photos.length < AppLimits.reportMaxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label + counter ────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                text: l10n.photos,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: hasError ? colors.error : colors.onSurface,
                ),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: colors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              l10n.photoCounter(validCount),
              style: TextStyle(
                fontSize: 13.sp,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // ── Photo grid ─────────────────────────────────────────────────────
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            ...photos.asMap().entries.map((entry) {
              final idx = entry.key;
              final file = entry.value;
              final isRejected = rejectedIndices.contains(idx);
              return _PhotoTile(
                file: file,
                isRejected: isRejected,
                onRemove: () => onRemovePhoto(idx),
              );
            }),
            if (showAddSlot)
              _AddTile(
                onTap: () => _showSourceSheet(context, l10n),
              ),
          ],
        ),

        // ── Helper caption ─────────────────────────────────────────────────
        SizedBox(height: 8.h),
        Text(
          l10n.photoHint,
          style: TextStyle(
            fontSize: 12.sp,
            color: colors.onSurfaceVariant,
          ),
        ),

        // ── Inline error ───────────────────────────────────────────────────
        if (hasError) ...[
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 14.r,
                color: colors.error,
              ),
              SizedBox(width: 4.w),
              Text(
                errorText!,
                style: TextStyle(fontSize: 12.sp, color: colors.error),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showSourceSheet(BuildContext context, AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 4.h),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: colors.onSurface,
              ),
              title: Text(
                l10n.takePhoto,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: colors.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onAddPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: colors.onSurface,
              ),
              title: Text(
                l10n.chooseFromGallery,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: colors.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onAddPhoto(ImageSource.gallery);
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

// ── Individual tiles ──────────────────────────────────────────────────────────

class _PhotoTile extends StatelessWidget {
  final XFile file;
  final bool isRejected;
  final VoidCallback onRemove;

  const _PhotoTile({
    required this.file,
    required this.isRejected,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final size = 80.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // ── Tile body ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: isRejected
                ? Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: colors.error, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: colors.error,
                          size: 22.r,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          l10n.photoRejected,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: colors.error,
                          ),
                        ),
                      ],
                    ),
                  )
                : kIsWeb
                    ? Image.network(
                        file.path,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: size,
                          height: size,
                          color: colors.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Image.file(
                        File(file.path),
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: size,
                          height: size,
                          color: colors.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
          ),

          // ── Remove badge ───────────────────────────────────────────────
          PositionedDirectional(
            top: 4.h,
            end: 4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: colors.onSurface,
                  size: 13.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final size = 80.w;

    return GestureDetector(
      onTap: onTap,
      child: DottedBorderContainer(
        size: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: colors.onSurfaceVariant,
              size: 24.r,
            ),
            SizedBox(height: 4.h),
            Text(
              l10n.addPhoto,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A container with a dashed border (using CustomPainter).
class DottedBorderContainer extends StatelessWidget {
  final double size;
  final Widget child;

  const DottedBorderContainer({
    super.key,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: colors.outline),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    const radius = 12.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(radius),
        ),
      );

    final dashPath = _dashPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _dashPath(Path source, double dashWidth, double dashSpace) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        dest.addPath(metric.extractPath(dist, dist + dashWidth), Offset.zero);
        dist += dashWidth + dashSpace;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
