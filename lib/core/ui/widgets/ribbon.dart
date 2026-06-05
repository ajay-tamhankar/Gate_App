import 'package:flutter/material.dart';

import '../theme.dart';

/// Renders text painted with the signature rainbow ribbon gradient.
/// Use sparingly for KPI numbers, headline accents, brand words.
class RibbonText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const RibbonText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => VistarTokens.ribbon
          .createShader(Rect.fromLTWH(0, 0, rect.width, rect.height)),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// A primary action button whose fill is the ribbon gradient.
class RibbonButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool dense;
  final bool fullWidth;

  const RibbonButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.dense = false,
    this.fullWidth = false,
  });

  @override
  State<RibbonButton> createState() => _RibbonButtonState();
}

class _RibbonButtonState extends State<RibbonButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    final padding = widget.dense
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 9)
        : const EdgeInsets.symmetric(horizontal: 18, vertical: 13);

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        gradient: disabled
            ? LinearGradient(colors: [
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
              ])
            : VistarTokens.ribbon,
        borderRadius: BorderRadius.circular(VistarTokens.radiusSm),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: VistarTokens.pink
                      .withValues(alpha: _hover ? 0.55 : 0.40),
                  blurRadius: _hover ? 38 : 28,
                  spreadRadius: -14,
                  offset: const Offset(0, 14),
                ),
              ],
      ),
      transform: Matrix4.translationValues(0, _hover && !disabled ? -1 : 0, 0),
      child: Row(
        mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.loading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          else if (widget.icon != null)
            Icon(widget.icon, color: Colors.white, size: 18),
          if ((widget.loading || widget.icon != null)) const SizedBox(width: 9),
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: disabled ? null : widget.onPressed,
        child: widget.fullWidth
            ? SizedBox(width: double.infinity, child: child)
            : child,
      ),
    );
  }
}

/// Thin 5×16 ribbon-gradient accent used beside section titles.
class RibbonAccentBar extends StatelessWidget {
  final double width;
  final double height;

  const RibbonAccentBar({super.key, this.width = 5, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: VistarTokens.ribbon,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
