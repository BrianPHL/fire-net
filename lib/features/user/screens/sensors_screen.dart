import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/sensor_node.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/layouts/app_scaffold.dart';
import '../../auth/auth_service.dart';
import '../user_service.dart';
import '../widgets/sensor_card.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  final _authService = AuthService();
  final _userService = UserService();

  Future<void> _handleLogout() async {
    final confirmed = await ErrorDialogHelper.showConfirmationDialog(
      context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (!confirmed) {
      return;
    }

    try {
      await _authService.signOut();

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.startup,
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(
        context,
        AuthService.getLogoutErrorMessage(error),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(
        context,
        'Unable to logout. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Sensor Network',
      showBackButton: true,
      onLogout: _handleLogout,
      body: SafeArea(
        child: StreamBuilder<List<SensorNode>>(
          stream: _userService.streamSensorNodes(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final sensors = snapshot.data ?? <SensorNode>[];
            if (sensors.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                return SensorCard(
                  sensor: sensor,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.sensorDetail,
                      arguments: sensor,
                    );
                  },
                );
              },
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemCount: sensors.length,
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'Failed to read live sensor data from Firebase.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.danger, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'No sensor data yet. Start your ESP32 sender to stream readings.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textTertiary, fontSize: 15),
        ),
      ),
    );
  }
}
