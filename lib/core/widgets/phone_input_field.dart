import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    this.initialCountryCode = 'US',
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String initialCountryCode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: enabled
            ? Colors.white
            : Colors.grey.shade100,
      ),
      initialCountryCode: initialCountryCode,
      enabled: enabled,
      onChanged: (phone) {
        if (onChanged != null) {
          onChanged!(phone.completeNumber);
        }
      },
      validator: (phone) {
        if (validator != null) {
          return validator!(phone?.completeNumber);
        }
        if (phone == null || phone.completeNumber.isEmpty) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
      invalidNumberMessage: 'Invalid phone number',
      dropdownIconPosition: IconPosition.trailing,
      flagsButtonPadding: const EdgeInsets.symmetric(horizontal: 12),
      showCountryFlag: true,
      showDropdownIcon: true,
    );
  }
}
