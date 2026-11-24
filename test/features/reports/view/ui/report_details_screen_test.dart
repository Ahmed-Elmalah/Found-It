import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/events/reports_changed_notifier.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/status_chip.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/entities/match_report_summary.dart';
import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';
import 'package:found_it/features/matches/domain/use_cases/get_match_details_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_count_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/reject_match_use_case.dart';
import 'package:found_it/features/matches/view/cubit/matches_cubit.dart';
import 'package:found_it/features/matches/view/widgets/potential_matches_section.dart';
import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';
import 'package:found_it/features/recovery/domain/repositories/recovery_repository.dart';
import 'package:found_it/features/recovery/domain/use_cases/get_match_contact_use_case.dart';
import 'package:found_it/features/recovery/domain/use_cases/mark_item_recovered_use_case.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_cubit.dart';
import 'package:found_it/features/recovery/view/widgets/mark_recovered_button.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/manual_match_result_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_details_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/create_manual_match_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_report_details_use_case.dart';
import 'package:found_it/features/reports/view/cubit/report_details_cubit.dart';
import 'package:found_it/features/reports/view/ui/report_details_screen.dart';

import '../../../../helpers/test_app.dart';

class _FakeReportsRepo implements ReportsRepository {
  bool notFound = false;
  bool isOwner = false;
  bool hasPrivateDetails = false;
  String? secretDetails;
  String reportType = 'lost';
  String reportStatus = 'active';
  bool isBlocked = false;
  String? activeMatchId;
  bool createManualMatchCalled = false;
  ManualMatchResultEntity matchResult = const ManualMatchResultEntity(
    matchId: 'match_123',
    status: 'chatting',
    claimStatus: 'none',
    isNew: true,
  );

  ReportDetailsEntity get report => ReportDetailsEntity(
        id: 'rep_1',
        refCode: '#RPT-1001',
        ownerName: 'Test User',
        cityId: 'city_cairo',
        cityNameEn: 'Cairo',
        cityNameAr: 'القاهرة',
        areaId: 'area_1',
        areaNameEn: 'Nasr City',
        areaNameAr: 'مدينة نصر',
        categoryId: 'cat_1',
        categoryNameEn: 'Wallet',
        categoryNameAr: 'محفظة',
        categoryIcon: 'wallet',
        title: 'Lost Leather Wallet',
        description: 'Black leather wallet with cards',
        type: reportType,
        status: reportStatus,
        itemDate: DateTime(2026, 11, 15),
        createdAt: DateTime(2026, 11, 15),
        updatedAt: DateTime(2026, 11, 15),
        images: const ['https://example.com/wallet.jpg'],
        isMine: isOwner,
        hasPrivateDetails: hasPrivateDetails,
        privateDetails: isOwner ? (secretDetails ?? 'Secret serial: 9988') : null,
        iAmBlocked: isBlocked,
        myMatchId: activeMatchId,
      );

  @override
  Future<ReportDetailsEntity> getReportDetails(String reportId) async {
    if (notFound) {
      throw const ReportFailure(ReportFailureType.notFound);
    }
    return report;
  }

  @override
  Future<ManualMatchResultEntity> createManualMatch(String reportId) async {
    createManualMatchCalled = true;
    return matchResult;
  }

  @override
  Future<String> createReport(CreateReportParams params) => throw UnimplementedError();
  @override
  Future<List<CategoryEntity>> getCategories() => throw UnimplementedError();
  @override
  Future<List<AreaEntity>> getCityAreas({required String cityId, required String lang}) =>
      throw UnimplementedError();
  @override
  Future<List<ReportEntity>> getMyReports({String? status}) => throw UnimplementedError();
  @override
  Future<ReportCountsEntity> getMyReportsCounts() => throw UnimplementedError();
  @override
  Future<String> getSelectedCityId() => throw UnimplementedError();
  @override
  Future<void> softDeleteReport(String reportId) => throw UnimplementedError();
  @override
  Future<ReportEntity> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
    String? privateDetails,
    List<Map<String, dynamic>>? questions,
  }) =>
      throw UnimplementedError();
}

class _FakeMatchesRepo implements MatchesRepository {
  List<MatchEntity> matches = const [];

  @override
  Future<List<MatchEntity>> getMyMatches({String? reportId}) async => matches;
  @override
  Future<int> getMyMatchesCount() async => matches.length;
  @override
  Future<MatchEntity> getMatchDetails(String matchId) => throw UnimplementedError();
  @override
  Future<void> rejectMatch(String matchId) => throw UnimplementedError();
}

class _FakeRecoveryRepo implements RecoveryRepository {
  bool markItemRecoveredCalled = false;
  String? lastRecoveredMatchId;

  @override
  Future<HandoverContactEntity> getMatchContact(String matchId) =>
      throw UnimplementedError();
  @override
  Future<void> markItemRecovered(String matchId) async {
    markItemRecoveredCalled = true;
    lastRecoveredMatchId = matchId;
  }
}

void main() {
  group('ReportDetailsScreen Widget Test', () {
    late _FakeReportsRepo fakeReportsRepo;
    late _FakeMatchesRepo fakeMatchesRepo;
    late _FakeRecoveryRepo fakeRecoveryRepo;

    setUp(() {
      fakeReportsRepo = _FakeReportsRepo();
      fakeMatchesRepo = _FakeMatchesRepo();
      fakeRecoveryRepo = _FakeRecoveryRepo();

      sl.reset();
      sl.registerFactory<ReportDetailsCubit>(
        () => ReportDetailsCubit(
          GetReportDetailsUseCase(fakeReportsRepo),
          CreateManualMatchUseCase(fakeReportsRepo),
        ),
      );
      sl.registerFactory<MatchesCubit>(
        () => MatchesCubit(
          getMyMatches: GetMyMatchesUseCase(fakeMatchesRepo),
          getMatchDetails: GetMatchDetailsUseCase(fakeMatchesRepo),
          rejectMatchUseCase: RejectMatchUseCase(fakeMatchesRepo),
          getMyMatchesCount: GetMyMatchesCountUseCase(fakeMatchesRepo),
        ),
      );
      sl.registerFactory<RecoveryCubit>(
        () => RecoveryCubit(
          getMatchContact: GetMatchContactUseCase(fakeRecoveryRepo),
          markItemRecovered: MarkItemRecoveredUseCase(fakeRecoveryRepo),
          reportsChangedNotifier: ReportsChangedNotifier(),
        ),
      );
    });

    tearDown(() {
      sl.reset();
    });

    testWidgets('renders report details, gallery, chips, title and claim button for non-owner',
        (tester) async {
      fakeReportsRepo.isOwner = false;

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_1'),
        padded: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('Lost Leather Wallet'), findsOneWidget);
      expect(find.text('#RPT-1001'), findsOneWidget);
      expect(find.byType(StatusChip), findsNWidgets(2));
      expect(find.text('Black leather wallet with cards'), findsOneWidget);
      expect(find.text('I Found This'), findsOneWidget);
    });

    testWidgets('renders edit icon in AppBar when user is owner', (tester) async {
      fakeReportsRepo.isOwner = true;

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_1'),
        padded: false,
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.text('I Found This'), findsNothing);
    });

    testWidgets('renders not found state when report does not exist', (tester) async {
      fakeReportsRepo.notFound = true;

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_missing'),
        padded: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('Report not found'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });

    testWidgets('masks private verification details and never displays phone or email for non-owner',
        (tester) async {
      fakeReportsRepo.isOwner = false;
      fakeReportsRepo.hasPrivateDetails = true;
      fakeReportsRepo.secretDetails = 'CONFIDENTIAL_ENGRAVING_1234';

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_1'),
        padded: false,
      );
      await tester.pumpAndSettle();

      // Mask card is visible with warning
      expect(find.text('Private verification details'), findsOneWidget);
      expect(
        find.text('Private verification details are hidden to protect the owner.'),
        findsOneWidget,
      );
      // The secret string itself is NOT rendered
      expect(find.text('CONFIDENTIAL_ENGRAVING_1234'), findsNothing);

      // Verify no phone numbers or email patterns are displayed on screen
      expect(find.textContaining(RegExp(r'01[0125]\d{8}')), findsNothing);
      expect(find.textContaining(RegExp(r'@')), findsNothing);
    });

    testWidgets('shows private verification details to the report owner with owner notice',
        (tester) async {
      fakeReportsRepo.isOwner = true;
      fakeReportsRepo.hasPrivateDetails = true;
      fakeReportsRepo.secretDetails = 'CONFIDENTIAL_ENGRAVING_1234';

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_1'),
        padded: false,
      );
      await tester.pumpAndSettle();

      // The secret string is rendered for the owner
      expect(find.text('Private verification details'), findsOneWidget);
      expect(find.text('CONFIDENTIAL_ENGRAVING_1234'), findsOneWidget);
      expect(find.text('Only you can see these verification details.'), findsOneWidget);
    });

    testWidgets(
        'displays "This is Mine" on found report, and tapping it calls createManualMatch and navigates to chat',
        (tester) async {
      fakeReportsRepo.isOwner = false;
      fakeReportsRepo.reportType = 'found';
      fakeReportsRepo.matchResult = const ManualMatchResultEntity(
        matchId: 'match_chat_1',
        status: 'chatting',
        claimStatus: 'none',
        isNew: true,
      );

      final router = GoRouter(
        initialLocation: '/reports/rep_1',
        routes: [
          GoRoute(
            path: '/reports/:id',
            builder: (_, state) =>
                ReportDetailsScreen(reportId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/chat/:matchId',
            builder: (_, state) =>
                Scaffold(body: Text('CHAT: ${state.pathParameters['matchId']}')),
          ),
        ],
      );

      await pumpTestRouterApp(tester, router);
      await tester.pumpAndSettle();

      expect(find.text('This is Mine'), findsOneWidget);
      await tester.tap(find.text('This is Mine'));
      await tester.pumpAndSettle();

      expect(fakeReportsRepo.createManualMatchCalled, isTrue);
      expect(find.text('CHAT: match_chat_1'), findsOneWidget);
    });

    testWidgets(
        'displays "I Found This" on lost report, and if claim is pending navigates to verify screen',
        (tester) async {
      fakeReportsRepo.isOwner = false;
      fakeReportsRepo.reportType = 'lost';
      fakeReportsRepo.matchResult = const ManualMatchResultEntity(
        matchId: 'match_verify_1',
        status: 'pending',
        claimStatus: 'pending',
        isNew: true,
      );

      final router = GoRouter(
        initialLocation: '/reports/rep_1',
        routes: [
          GoRoute(
            path: '/reports/:id',
            builder: (_, state) =>
                ReportDetailsScreen(reportId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/matches/:id/verify',
            builder: (_, state) =>
                Scaffold(body: Text('VERIFY: ${state.pathParameters['id']}')),
          ),
        ],
      );

      await pumpTestRouterApp(tester, router);
      await tester.pumpAndSettle();

      expect(find.text('I Found This'), findsOneWidget);
      await tester.tap(find.text('I Found This'));
      await tester.pumpAndSettle();

      expect(find.text('VERIFY: match_verify_1'), findsOneWidget);
    });

    testWidgets('displays "Open Chat" when user already has an active match on report',
        (tester) async {
      fakeReportsRepo.isOwner = false;
      fakeReportsRepo.activeMatchId = 'active_match_55';

      final router = GoRouter(
        initialLocation: '/reports/rep_1',
        routes: [
          GoRoute(
            path: '/reports/:id',
            builder: (_, state) =>
                ReportDetailsScreen(reportId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/chat/:matchId',
            builder: (_, state) =>
                Scaffold(body: Text('CHAT: ${state.pathParameters['matchId']}')),
          ),
        ],
      );

      await pumpTestRouterApp(tester, router);
      await tester.pumpAndSettle();

      expect(find.text('Open Chat'), findsOneWidget);
      await tester.tap(find.text('Open Chat'));
      await tester.pumpAndSettle();

      expect(find.text('CHAT: active_match_55'), findsOneWidget);
    });

    testWidgets('displays disabled "You can\'t claim this item" when i_am_blocked is true',
        (tester) async {
      fakeReportsRepo.isOwner = false;
      fakeReportsRepo.isBlocked = true;

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_1'),
        padded: false,
      );
      await tester.pumpAndSettle();

      expect(find.text("You can't claim this item"), findsOneWidget);
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('owner view renders Edit Report button and navigates to edit screen',
        (tester) async {
      fakeReportsRepo.isOwner = true;

      final router = GoRouter(
        initialLocation: '/reports/rep_1',
        routes: [
          GoRoute(
            path: '/reports/:id',
            builder: (_, state) =>
                ReportDetailsScreen(reportId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.editReport,
            builder: (_, _) => const Scaffold(body: Text('EDIT_SCREEN')),
          ),
        ],
      );

      await pumpTestRouterApp(tester, router);
      await tester.pumpAndSettle();

      final editBtnFinder = find.text('Edit Report');
      await tester.ensureVisible(editBtnFinder);
      await tester.pumpAndSettle();
      expect(editBtnFinder, findsOneWidget);
      await tester.tap(editBtnFinder);
      await tester.pumpAndSettle();

      expect(find.text('EDIT_SCREEN'), findsOneWidget);
    });

    testWidgets(
        'owner view renders MarkRecoveredButton when activeMatchId or matches exist',
        (tester) async {
      fakeReportsRepo.isOwner = true;
      fakeReportsRepo.activeMatchId = 'match_rec_1';
      fakeReportsRepo.reportStatus = 'active';

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_1'),
        padded: false,
      );
      await tester.pumpAndSettle();

      final markRecFinder = find.byType(MarkRecoveredButton);
      await tester.ensureVisible(markRecFinder);
      await tester.pumpAndSettle();
      expect(markRecFinder, findsOneWidget);
    });

    testWidgets(
        'owner view hides Edit Report and MarkRecoveredButton when report is already recovered',
        (tester) async {
      fakeReportsRepo.isOwner = true;
      fakeReportsRepo.activeMatchId = 'match_rec_1';
      fakeReportsRepo.reportStatus = 'recovered';

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_1', key: Key('rep_rec')),
        padded: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Report'), findsNothing);
      expect(find.byType(MarkRecoveredButton), findsNothing);
    });

    testWidgets(
        'owner view displays PotentialMatchesSection when matches exist, and navigates on view all and match tap',
        (tester) async {
      fakeReportsRepo.isOwner = true;
      fakeMatchesRepo.matches = [
        MatchEntity(
          matchId: 'match_99',
          status: 'potential',
          similarity: 88,
          source: 'auto',
          ownershipVerified: false,
          iAmFinder: false,
          createdAt: DateTime(2026, 11, 20),
          otherUserName: 'Omar Tarek',
          otherReport: MatchReportSummary(
            id: 'other_rep_2',
            refCode: '#RPT-9002',
            type: 'found',
            title: 'Found Black Leather Wallet',
            image: 'https://example.com/other.jpg',
            cityNameEn: 'Cairo',
            cityNameAr: 'القاهرة',
            areaNameEn: 'Maadi',
            areaNameAr: 'المعادي',
            categoryNameEn: 'Wallet',
            categoryNameAr: 'محفظة',
            itemDate: DateTime(2026, 11, 20),
            status: 'active',
          ),
        ),
      ];

      final router = GoRouter(
        initialLocation: '/reports/rep_1',
        routes: [
          GoRoute(
            path: '/reports/:id',
            builder: (_, state) =>
                ReportDetailsScreen(reportId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/matches',
            builder: (_, state) =>
                Scaffold(body: Text('MATCHES_PAGE: ${state.uri.queryParameters['reportId']}')),
          ),
          GoRoute(
            path: '/matches/:id/compare',
            builder: (_, state) =>
                Scaffold(body: Text('COMPARE_PAGE: ${state.pathParameters['id']}')),
          ),
        ],
      );

      await pumpTestRouterApp(tester, router);
      await tester.pumpAndSettle();

      final sectionFinder = find.byType(PotentialMatchesSection);
      await tester.ensureVisible(sectionFinder);
      await tester.pumpAndSettle();
      expect(sectionFinder, findsOneWidget);
      expect(find.text('Found Black Leather Wallet'), findsOneWidget);

      // Tap View all
      final viewAllFinder = find.text('View all');
      expect(viewAllFinder, findsOneWidget);
      await tester.tap(viewAllFinder);
      await tester.pumpAndSettle();

      expect(find.text('MATCHES_PAGE: rep_1'), findsOneWidget);
    });
  });
}
