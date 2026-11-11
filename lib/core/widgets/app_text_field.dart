import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/theme/app_theme.dart';

/// Labelled text field used by every form (login, sign up, report...).
///
/// All texts come from the caller (no hardcoded strings).
///
///   AppTextField(
///     label: l10n.email,
///     hint: l10n.emailHint,
///     prefixIcon: Icons.mail_outline,
///     controller: _emailController,
///     validator: (v) => v == null || v.isEmpty ? l10n.required : null,
///   )
///
///   AppTextField(label: l10n.password, isPassword: true, prefixIcon: Icons.lock_outline)
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.prefixText,
    this.controller,
    this.validator,
    this.isPassword = false,
    this.hasError = false,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofillHints,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? prefixText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool isPassword;

  /// Forces the red border even when there is no error message.
  final bool hasError;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasPrefix = widget.prefixIcon != null || widget.prefixText != null;
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius.r),
      borderSide: BorderSide(color: colors.error, width: 1.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          autofillHints: widget.autofillHints,
          enabled: widget.enabled,
          obscureText: widget.isPassword && _obscured,
          // keyboards must not learn / suggest passwords
          enableSuggestions: !widget.isPassword,
          autocorrect: !widget.isPassword,
          style: TextStyle(fontSize: 16.sp, color: colors.onSurface),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(fontSize: 16.sp, color: colors.onSurfaceVariant),
            helperText: widget.helperText,
            helperStyle:
                TextStyle(fontSize: 13.sp, color: colors.onSurfaceVariant),
            errorStyle: TextStyle(fontSize: 13.sp, color: colors.error),
            prefixIcon: hasPrefix
                ? Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: 16.w,
                      // Flutter adds a 4px gap after the prefix, so 12 + 4
                      // gives the 16 gap from the design (text at 52).
                      end: 12.w,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.prefixIcon != null)
                          Icon(
                            widget.prefixIcon,
                            size: 20.r,
                            color: colors.onSurfaceVariant,
                          ),
                        if (widget.prefixIcon != null &&
                            widget.prefixText != null)
                          SizedBox(width: 12.w),
                        if (widget.prefixText != null)
                          Text(
                            widget.prefixText!,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: colors.onSurface,
                            ),
                          ),
                      ],
                    ),
                  )
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 22.r,
                      color: colors.onSurfaceVariant,
                    ),
                  )
                : null,
            enabledBorder: widget.hasError ? errorBorder : null,
            focusedBorder: widget.hasError ? errorBorder : null,
          ),
        ),
      ],
    );
  }
}
