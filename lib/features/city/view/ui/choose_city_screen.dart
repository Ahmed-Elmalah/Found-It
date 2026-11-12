import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/error_banner.dart';
import 'package:found_it/features/auth/view/cubit/auth_cubit.dart';
import 'package:found_it/features/city/view/cubit/city_cubit.dart';
import 'package:found_it/features/city/view/widgets/city_radio_tile.dart';

/// Choose your city screen (Figma P11, P12, P13 / P44, P45, P46).
class ChooseCityScreen extends StatelessWidget {
  const ChooseCityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final cubit = context.read<CityCubit>();

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<CityCubit, CityState>(
          listener: (context, state) {
            if (state.status == CityStatus.success && state.selectedCityId != null) {
              context.read<AuthCubit>().cityChanged(state.selectedCityId!);
              context.go(AppRoutes.home);
            }
          },
          builder: (context, state) {
            final hasLocationError = state.hasLocationRequiredError;
            final isGeneralError =
                state.status == CityStatus.failure && state.errorMessage != null;

            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40.h),
                        Text(
                          l10n.chooseCityTitle,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          l10n.chooseCitySubtitle,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        if (hasLocationError) ...[
                          ErrorBanner(
                            title: l10n.locationRequiredTitle,
                            message: l10n.locationRequiredMessage,
                          ),
                          SizedBox(height: 16.h),
                        ] else if (isGeneralError) ...[
                          ErrorBanner(
                            title: l10n.genericErrorTitle,
                            message: l10n.genericErrorMessage,
                          ),
                          SizedBox(height: 16.h),
                        ],
                        if (state.isLoading)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (state.cities.isEmpty &&
                            state.status == CityStatus.failure)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: cubit.loadCities,
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.retry),
                              ),
                            ),
                          )
                        else
                          for (int i = 0; i < state.cities.length; i++) ...[
                            if (i > 0) SizedBox(height: 12.h),
                            CityRadioTile(
                              city: state.cities[i],
                              isSelected:
                                  state.selectedCityId == state.cities[i].id,
                              onTap: () => cubit.selectCity(state.cities[i].id),
                            ),
                          ],
                        const Spacer(),
                        SizedBox(height: 24.h),
                        AppButton(
                          label: l10n.continueButton,
                          isLoading: state.isSubmitting,
                          onPressed: cubit.submit,
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
