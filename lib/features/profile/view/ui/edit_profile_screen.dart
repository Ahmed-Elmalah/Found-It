import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/constants/app_limits.dart';
import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/utils/validators.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/app_text_field.dart';
import 'package:found_it/features/profile/domain/entities/profile_failure.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/view/cubit/profile_cubit.dart';
import 'package:found_it/features/profile/view/cubit/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  final UserProfileEntity profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _addressController =
        TextEditingController(text: widget.profile.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<ProfileCubit>();
    final success = await cubit.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (success && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdatedSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.editProfile,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.failure != null) {
            final l10n = AppLocalizations.of(context);
            final msg = state.failure == ProfileFailureType.network
                ? l10n.connectionErrorMessage
                : l10n.genericErrorMessage;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsetsDirectional.all(16.r),
              children: [
                SizedBox(height: 8.h),
                AppTextField(
                  label: l10n.fullNameLabel,
                  controller: _nameController,
                  hint: l10n.fullNameHint,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.length < AppLimits.fullNameMinLength) {
                      return l10n.nameTooShort;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  label: l10n.phoneLabel,
                  controller: _phoneController,
                  hint: l10n.phoneHint,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isNotEmpty && !Validators.isValidEgyptianPhone(text)) {
                      return l10n.invalidPhone;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  label: l10n.addressLabel,
                  controller: _addressController,
                  hint: l10n.addressHint,
                ),
                SizedBox(height: 32.h),
                AppButton(
                  label: l10n.saveProfile,
                  isLoading: state.isUpdating,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
