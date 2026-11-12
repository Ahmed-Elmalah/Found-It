import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/constants/app_durations.dart';
import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/utils/validators.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/app_text_field.dart';
import 'package:found_it/features/auth/view/widgets/auth_back_button.dart';
import 'package:found_it/features/auth/view/widgets/auth_footer_link.dart';
import 'package:found_it/features/auth/view/widgets/auth_header.dart';

/// Forgot password screen (Figma P09 / dark P42). UI only for now: a valid
/// email just shows a "coming soon" snackbar.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      // TODO(stage: password reset): once SMTP is set up, replace this
      // snackbar with the real reset email (Supabase resetPasswordForEmail)
      // and a new-password screen opened through a deep link.
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.resetComingSoon),
            duration: AppDurations.snackBar,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    const AuthBackButton(),
                    SizedBox(height: 16.h),
                    AuthHeader(
                      title: l10n.forgotPassword,
                      subtitle: l10n.forgotPasswordSubtitle,
                    ),
                    SizedBox(height: 24.h),
                    Form(
                      key: _formKey,
                      child: AppTextField(
                        label: l10n.emailLabel,
                        hint: l10n.emailHint,
                        prefixIcon: Icons.mail_outline,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (!Validators.isNotEmpty(value)) {
                            return l10n.fieldRequired;
                          }
                          if (!Validators.isValidEmail(value)) {
                            return l10n.invalidEmail;
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    AppButton(
                      label: l10n.sendResetLinkButton,
                      onPressed: _submit,
                    ),
                    const Spacer(),
                    SizedBox(height: 24.h),
                    AuthFooterLink(
                      text: l10n.rememberedIt,
                      actionText: l10n.backToLogin,
                      onTap: () => AuthBackButton.goBack(context),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
