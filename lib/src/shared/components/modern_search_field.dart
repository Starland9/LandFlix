import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/themes/colors.dart';

class ModernSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool isLoading;

  const ModernSearchField({
    super.key,
    required this.controller,
    this.hintText = "Rechercher un film ou une série...",
    this.onSubmitted,
    this.onChanged,
    this.isLoading = false,
  });

  @override
  State<ModernSearchField> createState() => _ModernSearchFieldState();
}

class _ModernSearchFieldState extends State<ModernSearchField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: _isFocused ? const EdgeInsets.all(2) : null,
            decoration: BoxDecoration(
              gradient: _isFocused ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(_isFocused ? 14 : 16),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                onSubmitted: (value) => widget.onSubmitted?.call(),
                onTap: () {
                  setState(() => _isFocused = true);
                  _animationController.forward();
                },
                onTapOutside: (_) {
                  setState(() => _isFocused = false);
                  _animationController.reverse();
                  FocusScope.of(context).unfocus();
                },
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 16,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  suffixIcon: widget.isLoading
                      ? Container(
                          margin: const EdgeInsets.all(16),
                          width: 20,
                          height: 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPurple,
                            ),
                          ),
                        )
                      : widget.controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            widget.controller.clear();
                            widget.onChanged?.call('');
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textTertiary,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
