import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/core/events/reports_changed_notifier.dart';
import 'package:found_it/core/preferences/app_preferences_cubit.dart';
import 'package:found_it/core/services/device_token_sync.dart';
import 'package:found_it/core/services/notification_service.dart';
import 'package:found_it/features/auth/data/auth_data_source.dart';
import 'package:found_it/features/auth/data/auth_repository_impl.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/get_current_user_use_case.dart';
import 'package:found_it/features/auth/domain/has_active_session_use_case.dart';
import 'package:found_it/features/auth/domain/login_use_case.dart';
import 'package:found_it/features/auth/domain/logout_use_case.dart';
import 'package:found_it/features/auth/domain/signup_use_case.dart';
import 'package:found_it/features/auth/domain/watch_auth_state_use_case.dart';
import 'package:found_it/features/auth/view/cubit/auth_cubit.dart';
import 'package:found_it/features/auth/view/cubit/login_cubit.dart';
import 'package:found_it/features/auth/view/cubit/resend_timer_cubit.dart';
import 'package:found_it/features/auth/view/cubit/sign_up_cubit.dart';
import 'package:found_it/features/chat/data/chat_remote_data_source.dart';
import 'package:found_it/features/chat/data/chat_repository_impl.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';
import 'package:found_it/features/chat/domain/use_cases/confirm_ownership_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_chat_match_details_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_my_chats_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_signed_image_url_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_unread_messages_count_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/mark_messages_read_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/reject_chat_match_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/send_message_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/upload_chat_image_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/watch_messages_use_case.dart';
import 'package:found_it/features/chat/view/cubit/chat_badge_cubit.dart';
import 'package:found_it/features/chat/view/cubit/chat_cubit.dart';
import 'package:found_it/features/chat/view/cubit/chat_list_cubit.dart';
import 'package:found_it/features/city/data/city_remote_data_source.dart';
import 'package:found_it/features/city/data/city_repository_impl.dart';
import 'package:found_it/features/city/domain/city_repository.dart';
import 'package:found_it/features/city/domain/get_cities_use_case.dart';
import 'package:found_it/features/city/domain/select_city_use_case.dart';
import 'package:found_it/features/city/view/cubit/city_cubit.dart';
import 'package:found_it/features/claim/data/claim_remote_data_source.dart';
import 'package:found_it/features/claim/data/claim_repository_impl.dart';
import 'package:found_it/features/claim/domain/repositories/claim_repository.dart';
import 'package:found_it/features/claim/domain/use_cases/get_claim_questions_use_case.dart';
import 'package:found_it/features/claim/domain/use_cases/submit_claim_answers_use_case.dart';
import 'package:found_it/features/claim/view/cubit/claim_cubit.dart';
import 'package:found_it/features/explore/data/explore_remote_data_source.dart';
import 'package:found_it/features/explore/data/explore_repository_impl.dart';
import 'package:found_it/features/explore/domain/explore_repository.dart';
import 'package:found_it/features/explore/domain/get_categories_use_case.dart'
    as explore;
import 'package:found_it/features/explore/domain/get_city_areas_use_case.dart'
    as explore;
import 'package:found_it/features/explore/domain/get_city_by_id_use_case.dart';
import 'package:found_it/features/explore/domain/search_reports_use_case.dart';
import 'package:found_it/features/explore/view/cubit/search_cubit.dart';
import 'package:found_it/features/home/data/home_remote_data_source.dart';
import 'package:found_it/features/home/data/home_repository_impl.dart';
import 'package:found_it/features/home/domain/repositories/home_repository.dart';
import 'package:found_it/features/home/domain/use_cases/get_home_feed_use_case.dart';
import 'package:found_it/features/home/view/cubit/home_cubit.dart';
import 'package:found_it/features/matches/data/matches_remote_data_source.dart';
import 'package:found_it/features/matches/data/matches_repository_impl.dart';
import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';
import 'package:found_it/features/matches/domain/use_cases/get_match_details_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_count_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/reject_match_use_case.dart';
import 'package:found_it/features/matches/view/cubit/matches_cubit.dart';
import 'package:found_it/features/notifications/data/notifications_remote_data_source.dart';
import 'package:found_it/features/notifications/data/notifications_repository_impl.dart';
import 'package:found_it/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:found_it/features/notifications/domain/use_cases/get_my_notifications_use_case.dart';
import 'package:found_it/features/notifications/domain/use_cases/mark_notifications_read_use_case.dart';
import 'package:found_it/features/notifications/domain/use_cases/watch_notifications_use_case.dart';
import 'package:found_it/features/notifications/view/cubit/notifications_cubit.dart';
import 'package:found_it/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:found_it/features/onboarding/data/onboarding_repository_impl.dart';
import 'package:found_it/features/onboarding/domain/complete_onboarding_use_case.dart';
import 'package:found_it/features/onboarding/domain/is_first_launch_use_case.dart';
import 'package:found_it/features/onboarding/domain/onboarding_repository.dart';
import 'package:found_it/features/onboarding/view/cubit/onboarding_cubit.dart';
import 'package:found_it/features/onboarding/view/cubit/splash_cubit.dart';
import 'package:found_it/features/profile/data/profile_data_source.dart';
import 'package:found_it/features/profile/data/profile_repository_impl.dart';
import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';
import 'package:found_it/features/profile/domain/use_cases/get_active_cities_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/set_my_city_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:found_it/features/profile/view/cubit/profile_cubit.dart';
import 'package:found_it/features/recovery/data/recovery_remote_data_source.dart';
import 'package:found_it/features/recovery/data/recovery_repository_impl.dart';
import 'package:found_it/features/recovery/domain/repositories/recovery_repository.dart';
import 'package:found_it/features/recovery/domain/use_cases/get_match_contact_use_case.dart';
import 'package:found_it/features/recovery/domain/use_cases/mark_item_recovered_use_case.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_cubit.dart';
import 'package:found_it/features/reports/data/reports_remote_data_source.dart';
import 'package:found_it/features/reports/data/reports_repository_impl.dart';
import 'package:found_it/features/reports/data/services/photo_picker_service.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/create_manual_match_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/create_report_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_categories_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_city_areas_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_counts_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_report_details_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_selected_city_id_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/soft_delete_report_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/update_report_use_case.dart';
import 'package:found_it/features/reports/view/cubit/create_report_cubit.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_cubit.dart';
import 'package:found_it/features/reports/view/cubit/report_details_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ---------------------------------------------------------------
  // Rules (follow them in every feature):
  //   registerLazySingleton -> data sources, repositories, use cases
  //   registerFactory       -> Cubits (a fresh one per screen)
  //   registerSingleton     -> things created at startup (e.g. SharedPreferences)
  //
  // Registration order inside a feature:
  //   data source -> repository -> use cases -> cubit
  //
  // Example for a feature:
  //   sl
  //     ..registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl())
  //     ..registerLazySingleton<AuthRepository>(
  //         () => AuthRepositoryImpl(sl()))
  //     ..registerLazySingleton(() => LoginUseCase(sl()))
  //     ..registerFactory(() => LoginCubit(sl()));
  // ---------------------------------------------------------------

  // ---------------------------------------------------------------
  // External: shared by ALL features. Registered once, here only.
  //   Data sources get them with sl(), e.g.
  //   ..registerLazySingleton<CityLocalDataSource>(
  //       () => CityLocalDataSourceImpl(sl<SharedPreferences>()))
  // Supabase.initialize() must run before this (see main.dart).
  // ---------------------------------------------------------------
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<SupabaseClient>(Supabase.instance.client)
    ..registerSingleton<AppPreferencesCubit>(
      AppPreferencesCubit(
        prefs,
        onLocaleChanged: (_) async {
          // Section 8: `p_lang` is the language saved with the device token,
          // so a language change has to re-save it.
          final sync = sl<DeviceTokenSync>();
          if (!sync.isSignedIn()) return;
          await sync.onSignedIn();
        },
      ),
    )
    ..registerLazySingleton<ReportsChangedNotifier>(
      () => ReportsChangedNotifier(),
    );

  _registerAuth();
  _registerNotifications();
  _registerOnboarding();
  _registerCity();
  _registerHome();
  _registerReports();
  _registerProfile();
  _registerExplore();
  _registerChat();
  _registerMatches();
  _registerClaim();
  _registerRecovery();
}

// ---------------------------------------------------------------------
// Explore + smart search (Mohamed, story #2)
// ---------------------------------------------------------------------
void _registerExplore() {
  sl
    ..registerLazySingleton<ExploreRemoteDataSource>(
      () => ExploreRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ExploreRepository>(
      () => ExploreRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => explore.GetCategoriesUseCase(sl()))
    ..registerLazySingleton(() => explore.GetCityAreasUseCase(sl()))
    ..registerLazySingleton(() => GetCityByIdUseCase(sl()))
    ..registerLazySingleton(() => SearchReportsUseCase(sl()))
    ..registerFactory(
      () => SearchCubit(
        getCityById: sl(),
        searchReports: sl(),
        getCategories: sl(),
        getCityAreas: sl(),
        reportsChangedNotifier: sl(),
      ),
    );
}

// ---------------------------------------------------------------------
// City (Youssef) — story #4
// ---------------------------------------------------------------------
void _registerCity() {
  sl
    ..registerLazySingleton<CityRemoteDataSource>(
      () => CityRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CityRepository>(
      () => CityRepositoryImpl(
        remoteDataSource: sl(),
      ),
    )
    ..registerLazySingleton(() => GetCitiesUseCase(sl()))
    ..registerLazySingleton(() => SelectCityUseCase(sl()))
    ..registerFactory(
      () => CityCubit(
        getCitiesUseCase: sl(),
        selectCityUseCase: sl(),
      ),
    );
}

// ---------------------------------------------------------------------
// Home (Youssef) — story #4
// ---------------------------------------------------------------------
void _registerHome() {
  sl
    ..registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => GetHomeFeedUseCase(sl()))
    ..registerFactory(
      () => HomeCubit(
        getHomeFeedUseCase: sl(),
        selectCityUseCase: sl(),
        getCitiesUseCase: sl(),
        getMyMatchesCountUseCase: sl(),
        reportsChangedNotifier: sl(),
      ),
    );
}

// ---------------------------------------------------------------------
// Reports (Ziad: Create Report + Adham: My Reports & Edit/Delete)
// ---------------------------------------------------------------------
void _registerReports() {
  sl
    ..registerLazySingleton<PhotoPickerService>(() => PhotoPickerServiceImpl())
    ..registerLazySingleton<ReportsRemoteDataSource>(
      () => ReportsRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => GetCategoriesUseCase(sl()))
    ..registerLazySingleton(() => GetCityAreasUseCase(sl()))
    ..registerLazySingleton(() => GetSelectedCityIdUseCase(sl()))
    ..registerLazySingleton(() => CreateReportUseCase(sl()))
    ..registerLazySingleton(() => GetMyReportsUseCase(sl()))
    ..registerLazySingleton(() => GetMyReportsCountsUseCase(sl()))
    ..registerLazySingleton(() => UpdateReportUseCase(sl()))
    ..registerLazySingleton(() => SoftDeleteReportUseCase(sl()))
    ..registerLazySingleton(() => GetReportDetailsUseCase(sl()))
    ..registerLazySingleton(() => CreateManualMatchUseCase(sl()))
    ..registerFactory(
      () => CreateReportCubit(
        getCategories: sl(),
        getCityAreas: sl(),
        getSelectedCityId: sl(),
        createReport: sl(),
        photoPicker: sl(),
      ),
    )
    ..registerFactory(() => MyReportsCubit(sl(), sl(), sl(), sl()))
    ..registerFactory(() => ReportDetailsCubit(sl(), sl()));
}

// ---------------------------------------------------------------------
// Auth (Ahmed) — session check + login. Sign up / logout come later.
// ---------------------------------------------------------------------
void _registerAuth() {
  sl
    ..registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(sl()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerLazySingleton(() => HasActiveSessionUseCase(sl()))
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerLazySingleton(() => SignUpUseCase(sl()))
    ..registerFactory(() => LoginCubit(sl()))
    ..registerFactory(() => SignUpCubit(sl()))
    ..registerFactory(() => ResendTimerCubit())
    // Session: login state + profile for the whole app.
    ..registerLazySingleton(() => WatchAuthStateUseCase(sl()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl()))
    ..registerLazySingleton(() => LogoutUseCase(sl()))
    // EXCEPTION to the "cubits are factories" rule: AuthCubit is ONE
    // app-wide instance (started in main.dart, provided in found_it.dart).
    ..registerLazySingleton(
      () {
        final tokenSync = sl<DeviceTokenSync>();
        return AuthCubit(
          watchAuthState: sl(),
          getCurrentUser: sl(),
          logout: sl(),
          hasActiveSession: sl(),
          // Story #5: register the FCM token after login / session restore,
          // and delete it before signOut (Section 8).
          onSignedIn: tokenSync.onSignedIn,
          beforeLogout: tokenSync.beforeLogout,
        );
      },
    );
}

// ---------------------------------------------------------------------
// Notifications / push (Mohamed) — story #5
// ---------------------------------------------------------------------
void _registerNotifications() {
  sl
    ..registerLazySingleton<DeviceTokenSync>(
      () => DeviceTokenSync(
        fetchToken: () async {
          // The backend contract is an FCM registration token. The FID APIs
          // added in firebase_messaging 17 are not usable with
          // `save_device_token`, so keep using the (deprecated) token API.
          // ignore: deprecated_member_use
          return FirebaseMessaging.instance.getToken();
        },
        saveDeviceToken: ({required token, required platform, required lang}) async {
          await sl<SupabaseClient>().rpc(
            'save_device_token',
            params: {
              'p_token': token,
              'p_platform': platform,
              'p_lang': lang,
            },
          );
        },
        deleteDeviceToken: ({required token}) async {
          await sl<SupabaseClient>().rpc(
            'delete_device_token',
            params: {'p_token': token},
          );
        },
        platform: _pushPlatform(),
        languageCode: _pushLanguage,
        // A token can only be saved while a session exists.
        isSignedIn: () => sl<SupabaseClient>().auth.currentSession != null,
      ),
    )
    ..registerLazySingleton<NotificationService>(
      () => NotificationService(
        tokenSync: sl(),
        markRead: (notificationId) async {
          await sl<SupabaseClient>().rpc(
            'mark_notifications_read',
            params: {
              'p_ids': [notificationId],
            },
          );
        },
      ),
    )
    ..registerLazySingleton<NotificationsRemoteDataSource>(
      () => NotificationsRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => GetMyNotificationsUseCase(sl()))
    ..registerLazySingleton(() => MarkNotificationsReadUseCase(sl()))
    ..registerLazySingleton(() => WatchNotificationsUseCase(sl()))
    // App-wide: the screen and the Home bell share the same unread state.
    ..registerLazySingleton<NotificationsCubit>(
      () => NotificationsCubit(
        getMyNotifications: sl(),
        markNotificationsRead: sl(),
        watchNotifications: sl(),
      ),
    );
}

/// `p_platform` — Section 8 allows `'android' | 'ios' | 'web'`.
String _pushPlatform() {
  if (kIsWeb) return 'web';
  return defaultTargetPlatform.name.toLowerCase();
}

/// `p_lang` — the app language, or the phone language when following system.
String _pushLanguage() {
  final selected = sl<AppPreferencesCubit>().state.locale?.languageCode;
  final system = PlatformDispatcher.instance.locale.languageCode;
  return (selected ?? system) == 'ar' ? 'ar' : 'en';
}

// ---------------------------------------------------------------------
// Onboarding + Splash (Ahmed)
// ---------------------------------------------------------------------
void _registerOnboarding() {
  sl
    ..registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => IsFirstLaunchUseCase(sl()))
    ..registerLazySingleton(() => CompleteOnboardingUseCase(sl()))
    ..registerFactory(() => SplashCubit(sl(), sl()))
    ..registerFactory(() => OnboardingCubit(sl()));
}

// ---------------------------------------------------------------------
// Profile & Settings (Adham)
// ---------------------------------------------------------------------
void _registerProfile() {
  sl
    ..registerLazySingleton<ProfileDataSource>(
      () => ProfileDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetProfileUseCase(sl()))
    ..registerLazySingleton(() => UpdateProfileUseCase(sl()))
    ..registerLazySingleton(() => SetMyCityUseCase(sl()))
    ..registerLazySingleton(() => GetActiveCitiesUseCase(sl()))
    ..registerFactory(() => ProfileCubit(sl(), sl(), sl(), sl(), sl(), sl()));
}

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Chat & Messages (Youssef, story #3)
// ---------------------------------------------------------------------
void _registerChat() {
  sl
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => GetMyChatsUseCase(sl()))
    ..registerLazySingleton(() => GetChatMatchDetailsUseCase(sl()))
    ..registerLazySingleton(() => WatchMessagesUseCase(sl()))
    ..registerLazySingleton(() => SendMessageUseCase(sl()))
    ..registerLazySingleton(() => UploadChatImageUseCase(sl()))
    ..registerLazySingleton(() => GetSignedImageUrlUseCase(sl()))
    ..registerLazySingleton(() => MarkMessagesReadUseCase(sl()))
    ..registerLazySingleton(() => ConfirmOwnershipUseCase(sl()))
    ..registerLazySingleton(() => RejectChatMatchUseCase(sl()))
    ..registerLazySingleton(() => GetUnreadMessagesCountUseCase(sl()))
    ..registerLazySingleton(() => ChatBadgeCubit(sl()))
    ..registerFactory(() => ChatListCubit(sl(), chatBadgeCubit: sl()))
    ..registerFactory(
      () => ChatCubit(
        getChatMatchDetailsUseCase: sl(),
        watchMessagesUseCase: sl(),
        sendMessageUseCase: sl(),
        uploadChatImageUseCase: sl(),
        getSignedImageUrlUseCase: sl(),
        markMessagesReadUseCase: sl(),
        confirmOwnershipUseCase: sl(),
        rejectChatMatchUseCase: sl(),
        chatBadgeCubit: sl(),
      ),
    );
}

// ---------------------------------------------------------------------
// Potential Matches (Ziad, story #2)
// ---------------------------------------------------------------------
void _registerMatches() {
  sl
    ..registerLazySingleton<MatchesRemoteDataSource>(
      () => MatchesRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<MatchesRepository>(
      () => MatchesRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => GetMyMatchesUseCase(sl()))
    ..registerLazySingleton(() => GetMatchDetailsUseCase(sl()))
    ..registerLazySingleton(() => RejectMatchUseCase(sl()))
    ..registerLazySingleton(() => GetMyMatchesCountUseCase(sl()))
    ..registerFactory(
      () => MatchesCubit(
        getMyMatches: sl(),
        getMatchDetails: sl(),
        rejectMatchUseCase: sl(),
        getMyMatchesCount: sl(),
      ),
    );
}

// ---------------------------------------------------------------------
// Claim / Verify Ownership (Mohamed, story #6)
// ---------------------------------------------------------------------
void _registerClaim() {
  sl
    ..registerLazySingleton<ClaimRemoteDataSource>(
      () => ClaimRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ClaimRepository>(
      () => ClaimRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => GetClaimQuestionsUseCase(sl()))
    ..registerLazySingleton(() => SubmitClaimAnswersUseCase(sl()))
    ..registerFactory(
      () => ClaimCubit(
        getClaimQuestions: sl(),
        submitClaimAnswers: sl(),
      ),
    );
}

// ---------------------------------------------------------------------
// Recovery & Handover (Ziad, story #4)
// ---------------------------------------------------------------------
void _registerRecovery() {
  sl
    ..registerLazySingleton<RecoveryRemoteDataSource>(
      () => RecoveryRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<RecoveryRepository>(
      () => RecoveryRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => GetMatchContactUseCase(sl()))
    ..registerLazySingleton(() => MarkItemRecoveredUseCase(sl()))
    ..registerFactory(
      () => RecoveryCubit(
        getMatchContact: sl(),
        markItemRecovered: sl(),
        reportsChangedNotifier: sl(),
      ),
    );
}
