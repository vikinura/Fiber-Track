import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.logoutConfirmationTitle),
          content: const Text(AppStrings.logoutConfirmationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              child: Text(
                AppStrings.logout,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          Text(
            AppStrings.theme,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.p12),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, currentMode) {
              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                child: Column(
                  children: [
                    RadioGroup<ThemeMode>(
                      groupValue: currentMode,
                      onChanged: (mode) {
                        if (mode != null) {
                          context.read<ThemeCubit>().setThemeMode(mode);
                        }
                      },
                      child: Column(
                        children: const [
                          RadioListTile<ThemeMode>(
                            title: Text(AppStrings.themeSystem),
                            subtitle: Text(
                              'Mengikuti pengaturan tema perangkat',
                            ),
                            value: ThemeMode.system,
                          ),
                          Divider(height: 1),
                          RadioListTile<ThemeMode>(
                            title: Text(AppStrings.themeLight),
                            subtitle: Text(
                              'Tampilan dengan latar belakang terang',
                            ),
                            value: ThemeMode.light,
                          ),
                          Divider(height: 1),
                          RadioListTile<ThemeMode>(
                            title: Text(AppStrings.themeDark),
                            subtitle: Text(
                              'Tampilan dengan latar belakang gelap',
                            ),
                            value: ThemeMode.dark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSizes.p32),
          AppButton(
            text: AppStrings.logout,
            isOutlined: true,
            icon: Icon(
              Icons.logout_rounded,
              size: AppSizes.iconSm,
              color: theme.colorScheme.error,
            ),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}
