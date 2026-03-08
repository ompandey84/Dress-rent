import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/theme.dart';

class FavoriteButton extends StatefulWidget {
  final String productId;
  final double size;
  final EdgeInsets padding;
  final Color? defaultColor;
  final Color backgroundColor;

  const FavoriteButton({
    super.key,
    required this.productId,
    this.size = 16,
    this.padding = const EdgeInsets.all(8),
    this.defaultColor,
    this.backgroundColor = Colors.white,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    context.read<AppState>().toggleFavorite(widget.productId);
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<AppState>().wishlistProductIds.contains(widget.productId);

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                isFavorite ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
                color: isFavorite ? Colors.red : (widget.defaultColor ?? AppTheme.textLight),
                size: widget.size,
              ),
            );
          },
        ),
      ),
    );
  }
}
