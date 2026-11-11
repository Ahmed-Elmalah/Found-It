import 'package:flutter/material.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// Report tab placeholder - the create report flow is a separate user story
/// and replaces this screen later.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).tabReport)),
    );
  }
}
