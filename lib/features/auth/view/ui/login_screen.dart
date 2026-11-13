import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/utils/validators.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/app_text_field.dart';
import 'package:found_it/core/widgets/error_banner.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/view/cubit/login_cubit.dart';
import 'package:found_it/features/auth/view/widgets/auth_footer_link.dart';
import 'package:found_it/features/auth/view/widgets/auth_header.dart';

/// Login screen (Figma P05 / P06 error state). The [LoginCubit] is provided
/// by the router.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<LoginCubit>();
    FocusScope.of(context).unfocus();
    if (cubit.state.isSubmitting) return;
    if (_formKey.currentState!.validate()) {
      cubit.submit(email: _email.text, password: _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final cubit = context.read<LoginCubit>();

    // No navigation here on success: the router's redirect sends the user
    // to Home (or City if no city yet) as soon as AuthCubit sees the login.
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final failed = state.status == LoginStatus.failure;
        final invalidCredentials =
            failed && state.failure == AuthFailureType.invalidCredentials;

        String bannerTitle = l10n.genericErrorTitle;
        String bannerMessage = l10n.genericErrorMessage;
        if (invalidCredentials) {
          bannerTitle = l10n.invalidCredentialsTitle;
          bannerMessage = l10n.invalidCredentialsMessage;
        } else if (failed && state.failure == AuthFailureType.network) {
          bannerTitle = l10n.connectionErrorTitle;
          bannerMessage = l10n.connectionErrorMessage;
        }

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
                        SizedBox(height: 40.h),
                        AuthHeader(
                          title: l10n.loginTitle,
                          subtitle: l10n.loginSubtitle,
                        ),
                        SizedBox(height: 16.h),
                        if (failed) ...[
                          ErrorBanner(
                            title: bannerTitle,
                            message: bannerMessage,
                          ),
                          SizedBox(height: 16.h),
                        ],
                        AutofillGroup(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                AppTextField(
                                  label: l10n.emailLabel,
                                  hint: l10n.emailHint,
                                  prefixIcon: Icons.mail_outline,
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  hasError: invalidCredentials,
                                  onChanged: (_) => cubit.clearError(),
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
                                SizedBox(height: 16.h),
                                AppTextField(
                                  label: l10n.passwordLabel,
                                  hint: l10n.passwordHint,
                                  prefixIcon: Icons.lock_outline,
                                  isPassword: true,
                                  controller: _password,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  hasError: invalidCredentials,
                                  onChanged: (_) => cubit.clearError(),
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (value) =>
                                      Validators.isNotEmpty(value)
                                      ? null
                                      : l10n.fieldRequired,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.forgotPassword),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: colors.primary,
                            ),
                            child: Text(
                              l10n.forgotPassword,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        AppButton(
                          label: l10n.loginButton,
                          isLoading: state.isSubmitting,
                          onPressed: _submit,
                        ),
                        const Spacer(),
                        SizedBox(height: 24.h),
                        AuthFooterLink(
                          text: l10n.noAccount,
                          actionText: l10n.signUpLink,
                          onTap: () => context.push(AppRoutes.signUp),
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
      },
    );
  }
}
