import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/preferences/app_preferences_cubit.dart';
import 'package:found_it/core/router/app_router.dart';
import 'package:found_it/core/theme/app_theme.dart';

class FoundIt extends StatelessWidget {
  const FoundIt({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppPreferencesCubit>.value(
      value: sl<AppPreferencesCubit>(),
      child: BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
        builder: (context, prefs) {
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            builder: (context, child) => MaterialApp.router(
              title: 'FOUND IT',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: prefs.themeMode,
              locale: prefs.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          );
        },
      ),
    );
  }
}
