import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';

class PrettyNeumorphicButton extends StatefulWidget {
  final Widget label;
  final VoidCallback? onPressed;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final Duration? duration;
  final double? borderRadius;

  const PrettyNeumorphicButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.labelStyle,
    this.padding,
    this.duration,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<PrettyNeumorphicButton> createState() => _PrettyNeumorphicButtonState();
}

class _PrettyNeumorphicButtonState extends State<PrettyNeumorphicButton> {
  bool _isElevated = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) {
              setState(() {
                _isElevated = false;
              });
            }
          : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              setState(() {
                _isElevated = true;
              });
              widget.onPressed!();
            }
          : null,
      onTapCancel: () {
        if (mounted) {
          setState(() {
            _isElevated = true;
          });
        }
      },
      child: AnimatedContainer(
        duration: widget.duration ?? const Duration(milliseconds: 200),
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 42, vertical: 14),
        decoration: BoxDecoration(
          color: widget.onPressed != null ? const Color(0xFF1E2E4F) : Colors.grey,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
          boxShadow: _isElevated
              ? [
                  const BoxShadow(
                    offset: Offset(4, 4),
                    color: Color(0xFF131D31),
                    blurRadius: 10,
                    inset: false,
                  ),
                  const BoxShadow(
                    offset: Offset(-4, -4),
                    color: Color(0xFF293F6D),
                    blurRadius: 10,
                    inset: false,
                  ),
                ]
              : [
                  const BoxShadow(
                    offset: Offset(4, 4),
                    color: Color(0xFF131D31),
                    blurRadius: 10,
                    inset: true,
                  ),
                  const BoxShadow(
                    offset: Offset(-4, -4),
                    color: Color(0xFF293F6D),
                    blurRadius: 10,
                    inset: true,
                  ),
                ],
        ),
        child: Center(
          child: widget.label,
        ),
      ),
    );
  }
}
