import 'package:flutter/material.dart';
import 'join_screen.dart';

// Define custom color constants based on Tailwind config
class AppColors {
  static const Color primary = Color(0xFF10B981);
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color backgroundDark = Color(0xFF101C22);
  static const Color foregroundLight = Color(0xFF111827);
  static const Color foregroundDark = Color(0xFFF9FAFB);
  static const Color subtleLight = Color(0xFF6B7280);
  static const Color subtleDark = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
}


class ApplicationStatusPage extends StatelessWidget {
  const ApplicationStatusPage({super.key});

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
                color: isDarkMode ? AppColors.backgroundDark.withOpacity(0.8) : AppColors.backgroundLight.withOpacity(0.8),
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
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 48.0),
                        child: Text(
                          'Application Status',
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
                    // Application Status Card
                    _buildApplicationStatusCard(context, isDarkMode),
                    const SizedBox(height: 32),
                    // Video Call Card
                    _buildVideoCallCard(context, isDarkMode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build the application status card
  Widget _buildApplicationStatusCard(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  'Application for Caregiver',
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
                      icon: Icons.check,
                      title: 'Application Submitted',
                      subtitle: 'June 15, 2026',
                      isCompleted: true,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineStep(
                      context: context,
                      icon: Icons.search,
                      title: 'Under Review',
                      subtitle: 'June 18, 2026',
                      isCompleted: true,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineStep(
                      context: context,
                      icon: Icons.calendar_month,
                      title: 'Interview Scheduled',
                      subtitle: 'June 22, 2026 at 10:00 AM',
                      isCompleted: false,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineStep(
                      context: context,
                      icon: Icons.handshake,
                      title: 'Offer Extended',
                      subtitle: '',
                      isCompleted: false,
                      isDarkMode: isDarkMode,
                      isPending: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for building each timeline step
  Widget _buildTimelineStep({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isDarkMode,
    bool isPending = false,
  }) {
    Color iconBackgroundColor;
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      iconBackgroundColor = AppColors.primary;
      iconColor = Colors.white;
      textColor = isDarkMode ? AppColors.foregroundDark : AppColors.foregroundLight;
    } else if (isPending) {
      iconBackgroundColor = isDarkMode ? AppColors.backgroundDark : Colors.white;
      iconColor = isDarkMode ? AppColors.subtleDark : AppColors.subtleLight;
      textColor = isDarkMode ? AppColors.subtleDark : AppColors.subtleLight;
    } else {
      iconBackgroundColor = isDarkMode ? AppColors.primary.withOpacity(0.3) : AppColors.primary.withOpacity(0.2);
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
            border: isPending ? Border.all(color: isDarkMode ? AppColors.borderDark : AppColors.borderLight, width: 2) : null,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? AppColors.subtleDark : AppColors.subtleLight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Method to build the video call card
  Widget _buildVideoCallCard(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video Call Interview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.foregroundDark : AppColors.foregroundLight,
                  ),
                ),
                Text(
                  'with Employer',
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Your interview is scheduled. Please be ready on time.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? AppColors.subtleDark : AppColors.subtleLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Countdown timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeBox('01', 'DAYS', isDarkMode),
                    const Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    _buildTimeBox('14', 'HOURS', isDarkMode),
                    const Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    _buildTimeBox('32', 'MINS', isDarkMode),
                  ],
                ),
                const SizedBox(height: 16),
                // Join Now button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to JoinScreen with a placeholder selfCallerId
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const JoinScreen(selfCallerId: 'some_caller_id'), // Placeholder
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? const Color(0xFF4B5563) : AppColors.primary,
                      foregroundColor: isDarkMode ? const Color(0xFF9CA3AF) : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Join Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "The 'Join Now' button is now enabled and will take you to the Join Screen.",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? AppColors.subtleDark : AppColors.subtleLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build each time box for the countdown
  Widget _buildTimeBox(String value, String label, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppColors.subtleDark : AppColors.subtleLight,
            ),
          ),
        ],
      ),
    );
  }
}