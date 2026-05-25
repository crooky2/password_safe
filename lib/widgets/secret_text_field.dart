import "package:flutter/material.dart";
import "package:flutter/services.dart";

class SecretTextField extends StatefulWidget {
  const SecretTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.onSubmitted,
    this.borderRadius = 12,
    this.enableBorder = false,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final double borderRadius;
  final bool enableBorder;

  @override
  State<SecretTextField> createState() => _SecretTextFieldState();
}

class _SecretTextFieldState extends State<SecretTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: widget.enableBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              )
            : null,
        suffixIcon: IconButton(
          tooltip: _obscureText ? "Show" : "Hide",
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(
            _obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          ),
        )
      )
    );
  }
}