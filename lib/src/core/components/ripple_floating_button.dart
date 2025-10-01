import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';

class RippleFloatingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final bool showRipple;

  const RippleFloatingButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56,
    this.showRipple = true,
  });

  @override
  State<RippleFloatingButton> createState() => _RippleFloatingButtonState();
}

class _RippleFloatingButtonState extends State<RippleFloatingButton>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    if (widget.showRipple) {
      _startRippleAnimation();
    }
  }

  void _startRippleAnimation() {
    _rippleController.repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _scaleController.forward();
  }

  void _onTapUp(_) {
    _scaleController.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? '',
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox(
                width: widget.size + 40,
                height: widget.size + 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple effects
                    if (widget.showRipple) ...[
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            width: widget.size + (40 * _rippleAnimation.value),
                            height: widget.size + (40 * _rippleAnimation.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    (widget.backgroundColor ??
                                            AppColors.primaryPurple)
                                        .withValues(
                                          alpha:
                                              0.3 *
                                              (1 - _rippleAnimation.value),
                                        ),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            width: widget.size + (20 * _rippleAnimation.value),
                            height: widget.size + (20 * _rippleAnimation.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    (widget.backgroundColor ??
                                            AppColors.primaryPurple)
                                        .withValues(
                                          alpha:
                                              0.5 *
                                              (1 - _rippleAnimation.value),
                                        ),
                                width: 1.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    // Main button
                    Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (widget.backgroundColor ??
                                        AppColors.primaryPurple)
                                    .withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(widget.size / 2),
                          onTap: widget.onPressed,
                          child: Icon(
                            widget.icon,
                            color: widget.foregroundColor ?? Colors.white,
                            size: widget.size * 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PulsingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleFactor;

  const PulsingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 1000),
    this.scaleFactor = 1.1,
  });

  @override
  State<PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: GestureDetector(onTap: widget.onPressed, child: widget.child),
        );
      },
    );
  }
}
