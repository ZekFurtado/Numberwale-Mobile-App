import 'package:flutter/material.dart';

class PasswordInputField extends StatefulWidget {
  const PasswordInputField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.hintText,
    this.showStrengthIndicator = false,
    this.showRequirements = false,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool showStrengthIndicator;
  final bool showRequirements;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;
  PasswordStrength _strength = PasswordStrength.weak;

  @override
  void initState() {
    super.initState();
    if (widget.showStrengthIndicator) {
      widget.controller.addListener(_updateStrength);
    }
  }

  @override
  void dispose() {
    if (widget.showStrengthIndicator) {
      widget.controller.removeListener(_updateStrength);
    }
    super.dispose();
  }

  void _updateStrength() {
    setState(() {
      _strength = _calculatePasswordStrength(widget.controller.text);
    });
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength++;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength++;

    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) strength++;

    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  bool _hasMinLength() => widget.controller.text.length >= 8;
  bool _hasUppercase() => widget.controller.text.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase() => widget.controller.text.contains(RegExp(r'[a-z]'));
  bool _hasNumber() => widget.controller.text.contains(RegExp(r'[0-9]'));
  bool _hasSpecialChar() =>
      widget.controller.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  Color _getStrengthColor() {
    final theme = Theme.of(context);
    switch (_strength) {
      case PasswordStrength.weak:
        return theme.colorScheme.error;
      case PasswordStrength.medium:
        return const Color(0xFFFBBF24); // Yellow
      case PasswordStrength.strong:
        return theme.colorScheme.tertiary; // Green
    }
  }

  String _getStrengthText() {
    switch (_strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double _getStrengthProgress() {
    switch (_strength) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText ?? 'Enter your password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),

        // Password strength indicator
        if (widget.showStrengthIndicator &&
            widget.controller.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _getStrengthProgress(),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(_getStrengthColor()),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getStrengthText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getStrengthColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],

        // Password requirements checklist
        if (widget.showRequirements &&
            widget.controller.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          _RequirementItem(
            text: 'At least 8 characters',
            isMet: _hasMinLength(),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            text: 'Contains uppercase letter',
            isMet: _hasUppercase(),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            text: 'Contains lowercase letter',
            isMet: _hasLowercase(),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            text: 'Contains number',
            isMet: _hasNumber(),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            text: 'Contains special character',
            isMet: _hasSpecialChar(),
          ),
        ],
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({
    required this.text,
    required this.isMet,
  });

  final String text;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isMet ? theme.colorScheme.tertiary : theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            decoration: isMet ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong,
}
