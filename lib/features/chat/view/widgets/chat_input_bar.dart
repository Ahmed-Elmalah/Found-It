import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:found_it/core/localization/app_localizations.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    required this.onSendImage,
    this.isClosed = false,
    this.isSending = false,
  });

  final ValueChanged<String> onSendMessage;
  final void Function(Uint8List bytes, String extension) onSendImage;
  final bool isClosed;
  final bool isSending;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late final TextEditingController _controller;
  final ImagePicker _picker = ImagePicker();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _canSend) {
      setState(() => _canSend = hasText);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    HapticFeedback.lightImpact();
    widget.onSendMessage(text);
    _controller.clear();
  }

  Future<void> _handlePickImage() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pick(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pick(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').lastOrNull ?? 'jpg';
      widget.onSendImage(bytes, ext);
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (widget.isClosed) {
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Text(
            l10n.chatClosedMessage,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : Colors.white,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Photo / Attachment Button
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              size: 22.sp,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            onPressed: widget.isSending ? null : _handlePickImage,
          ),

          // Expanding Multiline Text Field
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: l10n.chatInputPlaceholder,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.55),
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 8.h,
                  ),
                ),
              ),
            ),
          ),

          // Send Button
          GestureDetector(
            onTap: _canSend && !widget.isSending ? _handleSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 38.r,
              height: 38.r,
              margin: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _canSend
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2F5BEA), Color(0xFF1D4ED8)],
                      )
                    : null,
                color: _canSend
                    ? null
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_upward_rounded,
                  size: 20.sp,
                  color: _canSend
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
