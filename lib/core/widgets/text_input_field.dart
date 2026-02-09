import 'package:flutter/material.dart';
import 'package:numberwale/core/utils/context_extension.dart';

class TextInputField extends StatelessWidget {
  const TextInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    this.obscureText,
    this.controller,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled,
  });

  final String label;
  final String hintText;
  final Icon icon;
  final bool? obscureText;
  final int? maxLength;
  final bool? enabled;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Future<void> Function(String? pincode)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.onSurface.withOpacity(0.05),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            enabled: enabled,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: context.colorScheme.onSurface.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: context.colorScheme.onSurface.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              // focusedBorder:
              //     OutlineInputBorder(borderRadius: BorderRadius.circular(5),),
              hintText: hintText,
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.5),
              ),
              prefixIcon: icon,
            ),
            maxLength: maxLength,
            obscureText: obscureText ?? false,
          ),
        ),
      ],
    );
  }
}
