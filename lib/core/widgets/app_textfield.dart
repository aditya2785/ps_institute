import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;

  final bool isPassword;
  final bool isMultiline;

  final int? maxLines;
  final int? minLines;

  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final EdgeInsets padding;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.isPassword = false,
    this.isMultiline = false,
    this.maxLines,
    this.minLines,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.padding = const EdgeInsets.only(bottom: 16),
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- LABEL ----------------
          Text(
            widget.label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),

          // ---------------- FIELD ----------------
          TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            keyboardType: widget.isMultiline
                ? TextInputType.multiline
                : widget.keyboardType,

            maxLines: widget.isMultiline ? widget.maxLines ?? 4 : 1,
            minLines: widget.isMultiline ? widget.minLines ?? 1 : 1,

            obscureText: widget.isPassword ? _obscure : false,

            style: theme.textTheme.bodyLarge,

            decoration: InputDecoration(
              hintText: widget.hint,

              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: theme.colorScheme.onSurface,
                      ),
                      child: widget.prefixIcon!,
                    )
                  : null,

              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                    )
                  : widget.suffixIcon,

              // IMPORTANT: Let theme.dart control fill, borders, colors
              filled: theme.inputDecorationTheme.filled,
              fillColor: theme.inputDecorationTheme.fillColor,
              hintStyle: theme.inputDecorationTheme.hintStyle,
              enabledBorder:
                  theme.inputDecorationTheme.enabledBorder,
              focusedBorder:
                  theme.inputDecorationTheme.focusedBorder,
              border: theme.inputDecorationTheme.border,
            ),
          ),
        ],
      ),
    );
  }
}
