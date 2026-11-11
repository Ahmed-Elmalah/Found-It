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
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/view/cubit/sign_up_cubit.dart';
import 'package:found_it/features/auth/view/widgets/auth_footer_link.dart';
import 'package:found_it/features/auth/view/widgets/auth_header.dart';

/// Sign up screen (Figma P07 / P08 "email already exists" state). The
/// [SignUpCubit] is provided by the router.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _password.dispose();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _submit() {
    final cubit = context.read<SignUpCubit>();
    FocusScope.of(context).unfocus();
    if (cubit.state.isSubmitting) return;
    if (_formKey.currentState!.validate()) {
      cubit.submit(
        SignUpParams(
          fullName: _name.text,
          email: _email.text,
          phone: Validators.normalizeEgyptianPhone(_phone.text)!,
          address: _address.text,
          password: _password.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final cubit = context.read<SignUpCubit>();

    return BlocConsumer<SignUpCubit, SignUpState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == SignUpStatus.success,
      listener: (context, state) => context.go(AppRoutes.city),
      builder: (context, state) {
        final failed = state.status == SignUpStatus.failure;
        final emailInUse =
            failed && state.failure == AuthFailureType.emailAlreadyInUse;

        String bannerTitle = l10n.genericErrorTitle;
        String bannerMessage = l10n.genericErrorMessage;
        if (emailInUse) {
          bannerTitle = l10n.registrationFailedTitle;
          bannerMessage = l10n.emailInUseMessage;
        } else if (failed && state.failure == AuthFailureType.weakPassword) {
          bannerTitle = l10n.weakPasswordTitle;
          bannerMessage = l10n.weakPasswordMessage;
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
                        SizedBox(height: 8.h),
                        // The icon has matchTextDirection, so it points to
                        // the right in Arabic.
                        IconButton(
                          onPressed: _back,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          iconSize: 20.r,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: colors.onSurface,
                          tooltip: MaterialLocalizations.of(context)
                              .backButtonTooltip,
                        ),
                        SizedBox(height: 16.h),
                        AuthHeader(title: l10n.signUpTitle),
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
                                  label: l10n.fullNameLabel,
                                  hint: l10n.fullNameHint,
                                  prefixIcon: Icons.person_outline,
                                  controller: _name,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  onChanged: (_) => cubit.clearError(),
                                  validator: (value) {
                                    if (!Validators.isNotEmpty(value)) {
                                      return l10n.fieldRequired;
                                    }
                                    if (!Validators.isValidFullName(value)) {
                                      return l10n.nameTooShort;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                AppTextField(
                                  label: l10n.emailLabel,
                                  hint: l10n.emailHint,
                                  prefixIcon: Icons.mail_outline,
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  hasError: emailInUse,
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
                                  label: l10n.phoneLabel,
                                  hint: l10n.phoneHint,
                                  prefixIcon: Icons.phone_iphone,
                                  prefixText: '+20',
                                  forceLtr: true,
                                  controller: _phone,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumberNational,
                                  ],
                                  onChanged: (_) => cubit.clearError(),
                                  validator: (value) {
                                    if (!Validators.isNotEmpty(value)) {
                                      return l10n.fieldRequired;
                                    }
                                    if (!Validators.isValidEgyptianPhone(
                                      value,
                                    )) {
                                      return l10n.invalidPhone;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                AppTextField(
                                  label: l10n.addressLabel,
                                  hint: l10n.addressHint,
                                  prefixIcon: Icons.home_outlined,
                                  controller: _address,
                                  keyboardType: TextInputType.streetAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.fullStreetAddress,
                                  ],
                                  onChanged: (_) => cubit.clearError(),
                                ),
                                SizedBox(height: 16.h),
                                AppTextField(
                                  label: l10n.passwordLabel,
                                  hint: l10n.passwordHint,
                                  prefixIcon: Icons.lock_outline,
                                  isPassword: true,
                                  helperText: l10n.passwordHelper,
                                  controller: _password,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  onChanged: (_) => cubit.clearError(),
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (value) {
                                    if (!Validators.isNotEmpty(value)) {
                                      return l10n.fieldRequired;
                                    }
                                    if (!Validators.isValidPassword(value)) {
                                      return l10n.passwordTooShort;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        AppButton(
                          label: l10n.createAccountButton,
                          isLoading: state.isSubmitting,
                          onPressed: _submit,
                        ),
                        const Spacer(),
                        SizedBox(height: 24.h),
                        AuthFooterLink(
                          text: l10n.haveAccount,
                          actionText: l10n.logInLink,
                          onTap: _back,
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
