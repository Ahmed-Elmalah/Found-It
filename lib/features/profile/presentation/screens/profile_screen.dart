import 'package:flutter/material.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// Profile tab placeholder - the profile feature is a separate user story
/// and replaces this screen later.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).tabProfile)),
    );
  }
}
