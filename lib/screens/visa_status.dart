import 'package:flutter/material.dart';
import 'ApplicationStatusPage.dart';

class VisaStatusPage extends StatelessWidget {
  const VisaStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.backgroundDark.withAlpha((0.8 * 255).toInt())
                    : AppColors.backgroundLight.withAlpha((0.8 * 255).toInt()),
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: isDarkMode ? AppColors.foregroundDark : AppColors.foregroundLight),
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 48.0),
                        child: Text(
                          'Visa Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.foregroundDark : AppColors.foregroundLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildVisaStatusCard(context, isDarkMode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisaStatusCard(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of the card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caregiver Visa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.foregroundDark : AppColors.foregroundLight,
                  ),
                ),
                Text(
                  'Singapore',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? AppColors.subtleDark : AppColors.subtleLight,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
          ),
          // Timeline section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                // Vertical line
                Positioned(
                  left: 20,
                  top: 8,
                  bottom: 8,
                  child: Container(
                    width: 2,
                    color: AppColors.primary,
                  ),
                ),
                Column(
                  children: [
                    _buildTimelineStep(
                      context: context,
                      icon: Icons.calendar_month,
                      title: 'Application Submission Date',
                      subtitle: '2024-01-15',
                      isCompleted: true,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineStep(
                      context: context,
                      icon: Icons.hourglass_top,
                      title: 'Current Status',
                      subtitle: 'Processing',
                      isCompleted: true,
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Info Card for other details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.backgroundDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).toInt()),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      context: context,
                      icon: Icons.timer,
                      label: 'Estimated Processing Time',
                      value: '2–4 weeks',
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.description,
                      label: 'Visa Type',
                      value: 'Caregiver Visa',
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.public,
                      label: 'Destination Country',
                      value: 'Singapore',
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isDarkMode,
  }) {
    Color iconBackgroundColor;
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      iconBackgroundColor = AppColors.primary;
      iconColor = Colors.white;
      textColor = isDarkMode ? AppColors.foregroundDark : AppColors.foregroundLight;
    } else {
      iconBackgroundColor = isDarkMode
          ? AppColors.primary.withAlpha((0.3 * 255).toInt())
          : AppColors.primary.withAlpha((0.2 * 255).toInt());
      iconColor = AppColors.primary;
      textColor = isDarkMode ? AppColors.foregroundDark : AppColors.foregroundLight;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.subtleDark : AppColors.subtleLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.primary.withAlpha((0.3 * 255).toInt())
                : AppColors.primary.withAlpha((0.2 * 255).toInt()),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.foregroundDark : AppColors.foregroundLight,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.subtleDark : AppColors.subtleLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
