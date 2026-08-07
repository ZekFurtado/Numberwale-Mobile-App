import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInputField extends StatefulWidget {
  const OTPInputField({
    super.key,
    required this.onCompleted,
    this.length = 6,
    this.hasError = false,
    this.onChanged,
    this.autoFillStream,
  });

  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final int length;
  final bool hasError;

  /// Emits an OTP code (e.g. read from an incoming SMS) to be filled into
  /// the input boxes automatically.
  final Stream<String>? autoFillStream;

  @override
  State<OTPInputField> createState() => _OTPInputFieldState();
}

class _OTPInputFieldState extends State<OTPInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  StreamSubscription<String>? _autoFillSubscription;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _autoFillSubscription = widget.autoFillStream?.listen(_handlePaste);
  }

  @override
  void dispose() {
    _autoFillSubscription?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpValue {
    return _controllers.map((c) => c.text).join();
  }

  void _handlePaste(String text) {
    // Remove any non-digit characters
    final digits = text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return;

    // Fill the controllers with the pasted digits
    for (int i = 0; i < widget.length && i < digits.length; i++) {
      _controllers[i].text = digits[i];
    }

    // Focus the next empty field or the last field
    final nextEmptyIndex = _controllers.indexWhere((c) => c.text.isEmpty);
    if (nextEmptyIndex != -1) {
      _focusNodes[nextEmptyIndex].requestFocus();
    } else {
      _focusNodes[widget.length - 1].requestFocus();
      if (_otpValue.length == widget.length) {
        widget.onCompleted(_otpValue);
      }
    }

    widget.onChanged?.call(_otpValue);
  }

  void _onTextChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      _handlePaste(value);
      return;
    }

    if (value.isNotEmpty) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field, unfocus and call onCompleted if all filled
        _focusNodes[index].unfocus();
        if (_otpValue.length == widget.length) {
          widget.onCompleted(_otpValue);
        }
      }
    }

    widget.onChanged?.call(_otpValue);
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        // Move to previous field
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = widget.hasError
        ? theme.colorScheme.error
        : theme.colorScheme.outline.withOpacity(0.3);
    final focusedBorderColor = widget.hasError
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return AutofillGroup(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          widget.length,
          (index) => SizedBox(
            width: 48,
            height: 56,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) => _onKeyEvent(index, event),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                // The first box accepts the OS's full autofilled code (iOS
                // fills one field with the whole code); the rest stay single
                // digit for manual entry.
                maxLength: index == 0 ? widget.length : 1,
                autofillHints: index == 0
                    ? const [AutofillHints.oneTimeCode]
                    : null,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: focusedBorderColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: widget.hasError
                      ? theme.colorScheme.errorContainer.withOpacity(0.1)
                      : theme.colorScheme.surface,
                ),
                onChanged: (value) => _onTextChanged(index, value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
