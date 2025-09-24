import 'package:flutter/material.dart';

class DocumentSubmissionPage extends StatelessWidget {
  const DocumentSubmissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black.withOpacity(0.05)
                        : Colors.white.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Documents',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer to balance the back button
                ],
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Document Submission Checklist',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please upload the required documents to complete your profile. Your information is safe with us.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildChecklistItem(
                        context,
                        'Passport',
                        isSubmitted: true,
                      ),
                      const SizedBox(height: 16),
                      _buildChecklistItem(
                        context,
                        'Work Permit',
                        isSubmitted: true,
                      ),
                      const SizedBox(height: 16),
                      _buildChecklistItem(
                        context,
                        'Medical Certificate',
                        isSubmitted: false,
                      ),
                      const SizedBox(height: 16),
                      _buildChecklistItem(
                        context,
                        'Employment Contract',
                        isSubmitted: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Submit button
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(BuildContext context, String title, {required bool isSubmitted}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // Choose icon based on document type
    IconData? leadingIcon;
    switch (title) {
      case 'Passport':
        leadingIcon = Icons.book;
        break;
      case 'Work Permit':
        leadingIcon = Icons.badge;
        break;
      case 'Medical Certificate':
        leadingIcon = Icons.medical_services;
        break;
      case 'Employment Contract':
        leadingIcon = Icons.description;
        break;
      default:
        leadingIcon = Icons.insert_drive_file;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isSubmitted
            ? (isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1))
            : (isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white),
        border: isSubmitted
            ? Border.all(color: primaryColor.withOpacity(0.5))
            : null,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                leadingIcon,
                color: isDarkMode ? Colors.grey[200] : Colors.grey[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          isSubmitted
              ? Row(
            children: [
              Text(
                'Submitted',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ],
          )
              : TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'UPLOAD',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final primaryColor = Colors.green;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.05)
                : Colors.white.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48.0,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Submit All Documents',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}