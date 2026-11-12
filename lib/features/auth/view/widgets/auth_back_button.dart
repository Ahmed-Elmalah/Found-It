import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';

/// The thin "<" back button at the top start of the auth screens
/// (Sign up, Forgot password, Verify email). Points right in Arabic.
///
/// Goes back if there is a page to go back to, otherwise to [fallback]
/// (Login by default).
///
///   const AuthBackButton()
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.fallback = AppRoutes.login});

  /// Where to go when there is nothing to pop.
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => goBack(context, fallback: fallback),
      // matchTextDirection: true -> flips to ">" in Arabic.
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      iconSize: 20.r,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      color: Theme.of(context).colorScheme.onSurface,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }

  /// Pops if possible, otherwise goes to [fallback]. Also used by the
  /// "Log in" / "Back to login" footer links.
  static void goBack(
    BuildContext context, {
    String fallback = AppRoutes.login,
  }) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallback);
    }
  }
}
