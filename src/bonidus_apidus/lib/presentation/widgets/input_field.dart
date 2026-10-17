import 'package:flutter/material.dart';
import 'package:bonidus_apidus/core/constants/app_constants.dart';
import 'package:bonidus_apidus/core/theme/colours.dart';

class InputField extends StatelessWidget {
  final String title;
  final String placeholder;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const InputField({
    super.key,
    required this.title,
    required this.placeholder,
    this.onChanged,
    this.readOnly = false,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            onChanged: onChanged,
            readOnly: readOnly,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColours.searchInputBackground,
              hintText: placeholder,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.inputFieldBorderRadius),
                borderSide: const BorderSide(
                  color: AppColours.accent,
                  width: AppConstants.borderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.inputFieldBorderRadius),
                borderSide: const BorderSide(
                  color: AppColours.accent,
                  width: AppConstants.borderWidth,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.inputFieldBorderRadius),
                borderSide: const BorderSide(
                  color: AppColours.alert,
                  width: AppConstants.borderWidth,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.inputFieldBorderRadius),
                borderSide: const BorderSide(
                  color: AppColours.alert,
                  width: AppConstants.borderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}