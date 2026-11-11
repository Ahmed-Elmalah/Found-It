import 'package:flutter/material.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// Messages tab placeholder - the chat feature is a separate user story and
/// replaces this screen later.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).tabMessages)),
    );
  }
}
