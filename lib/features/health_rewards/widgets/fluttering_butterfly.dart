import 'package:flutter/material.dart';

class FlutteringButterfly extends StatefulWidget {
  const FlutteringButterfly({
    super.key,
    required this.imagePath,
    required this.width,
    this.reverseDirection = false,
  });

  final String imagePath;
  final double width;
  final bool reverseDirection;

  @override
  State<FlutteringButterfly> createState() => _FlutteringButterflyState();
}

class _FlutteringButterflyState extends State<FlutteringButterfly>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _verticalAnimation;
  late final Animation<double> _horizontalAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _verticalAnimation = Tween<double>(
      begin: -4,
      end: 5,
    ).animate(curvedAnimation);

    _horizontalAnimation = Tween<double>(
      begin: -4,
      end: 4,
    ).animate(curvedAnimation);

    _rotationAnimation = Tween<double>(
      begin: -0.035,
      end: 0.035,
    ).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: Image.asset(
        widget.imagePath,
        width: widget.width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
      ),
      builder: (context, child) {
        final double horizontalValue = widget.reverseDirection
            ? -_horizontalAnimation.value
            : _horizontalAnimation.value;

        return Transform.translate(
          offset: Offset(horizontalValue, _verticalAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
    );
  }
}
