import 'package:flutter/material.dart';

class JobApplicationForm extends StatelessWidget {
  const JobApplicationForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Only light theme colors
    final primaryColor =  Colors.green;
    final backgroundColor = const Color(0xFFF6F7F8);
    final formBackgroundColor = Colors.white;
    final borderColor = const Color(0xFFD1D5DB);
    final textColor = const Color(0xFF1F2937);
    final labelColor = const Color(0xFF4B5563);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: backgroundColor.withAlpha((0.8 * 255).toInt()),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: labelColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Apply for Caregiver',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFileUploader('CV', 'Upload CV', 'upload_file_rounded', formBackgroundColor, borderColor, labelColor),
                    const SizedBox(height: 24),
                    _buildFileUploader('Passport Image', 'Upload Passport Image', 'upload_file_rounded', formBackgroundColor, borderColor, labelColor),
                    const SizedBox(height: 24),
                    _buildFileUploader('License Photo', 'Upload License Photo', 'upload_file_rounded', formBackgroundColor, borderColor, labelColor),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Statement of Purpose',
                      hintText: 'Write a brief statement about your career goals...',
                      isTextArea: true,
                      primaryColor: primaryColor,
                      formBackgroundColor: formBackgroundColor,
                      borderColor: borderColor,
                      labelColor: labelColor,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Expected Salary (SGD)',
                      hintText: 'Enter expected monthly salary',
                      keyboardType: TextInputType.number,
                      primaryColor: primaryColor,
                      formBackgroundColor: formBackgroundColor,
                      borderColor: borderColor,
                      labelColor: labelColor,
                    ),
                    const SizedBox(height: 24),
                    _buildDropdownField(
                      label: 'Work Experience',
                      primaryColor: primaryColor,
                      formBackgroundColor: formBackgroundColor,
                      borderColor: borderColor,
                      labelColor: labelColor,
                      options: ['Select experience', '0-1 years', '1-3 years', '3-5 years', '5+ years'],
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'English Proficiency',
                      hintText: 'e.g. Basic, Conversational, Fluent',
                      primaryColor: primaryColor,
                      formBackgroundColor: formBackgroundColor,
                      borderColor: borderColor,
                      labelColor: labelColor,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Submit logic here
                        },
                        child: const Text(
                          'Submit Application',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploader(String label, String placeholder, String iconName, Color formBackgroundColor, Color borderColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: formBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.upload_file_rounded, color: labelColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  placeholder,
                  style: TextStyle(
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool isTextArea = false,
    required Color primaryColor,
    required Color formBackgroundColor,
    required Color borderColor,
    required Color labelColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          maxLines: isTextArea ? 5 : 1,
          style: TextStyle(color: labelColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: labelColor),
            filled: true,
            fillColor: formBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required Color primaryColor,
    required Color formBackgroundColor,
    required Color borderColor,
    required Color labelColor,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: formBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: options.first,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: labelColor),
              style: TextStyle(color: labelColor),
              onChanged: (String? newValue) {},
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}