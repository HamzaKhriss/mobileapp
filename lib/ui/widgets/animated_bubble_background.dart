import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBubbleBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const AnimatedBubbleBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  State<AnimatedBubbleBackground> createState() =>
      _AnimatedBubbleBackgroundState();
}

class _AnimatedBubbleBackgroundState extends State<AnimatedBubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _createBubbles();
    _controller.repeat();
  }

  void _createBubbles() {
    const int bubbleCount = 6; // Reduced from 12 to 6
    _bubbles = [];

    for (int i = 0; i < bubbleCount; i++) {
      _bubbles.add(Bubble(
        id: i,
        initialX: math.Random().nextDouble(),
        initialY: math.Random().nextDouble(),
        size: 60 + math.Random().nextDouble() * 100, // Reduced max size
        speed: 0.2 + math.Random().nextDouble() * 0.4, // Reduced speed
        color: _getBubbleColor(i),
        phase: math.Random().nextDouble() * 2 * math.pi, // Phase offset
      ));
    }
  }

  Color _getBubbleColor(int index) {
    final colors = widget.isDark
        ? [
            const Color(0xFF1ABC9C).withOpacity(0.15),
            const Color(0xFF68D8C5).withOpacity(0.12),
            Colors.white.withOpacity(0.08),
          ]
        : [
            const Color(0xFF1ABC9C).withOpacity(0.12),
            const Color(0xFF68D8C5).withOpacity(0.10),
            Colors.white.withOpacity(0.15),
          ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? [
                      const Color(0xFF1E1E1E),
                      const Color(0xFF282B2B),
                      const Color(0xFF1ABC9C).withOpacity(0.05),
                    ]
                  : [
                      const Color(0xFFF3F3F3),
                      Colors.white,
                      const Color(0xFF1ABC9C).withOpacity(0.03),
                    ],
            ),
          ),
        ),
        // Animated bubbles with RepaintBoundary for performance
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: _bubbles.map((bubble) {
                  return _buildBubble(bubble, _controller.value);
                }).toList(),
              );
            },
          ),
        ),
        // Child content
        widget.child,
      ],
    );
  }

  Widget _buildBubble(Bubble bubble, double progress) {
    // Pre-calculate expensive operations
    final time = progress * 2 * math.pi + bubble.phase;
    final slowTime = progress * math.pi + bubble.phase;

    // Simplified movement calculations
    final waveX = math.sin(time) * 0.08;
    final waveY = math.cos(slowTime) * 0.12;

    final x = (bubble.initialX + waveX + progress * 0.05) % 1.1 - 0.05;
    final y = (bubble.initialY + waveY - progress * bubble.speed) % 1.1 - 0.05;

    // Simplified scale animation
    final scale = 0.8 + math.sin(time * 0.5) * 0.2;

    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: bubble.size,
          height: bubble.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Simple circle instead of complex clipper
            color: bubble.color,
            // Removed expensive box shadow
          ),
        ),
      ),
    );
  }
}

class Bubble {
  final int id;
  final double initialX;
  final double initialY;
  final double size;
  final double speed;
  final Color color;
  final double phase;

  Bubble({
    required this.id,
    required this.initialX,
    required this.initialY,
    required this.size,
    required this.speed,
    required this.color,
    required this.phase,
  });
}
