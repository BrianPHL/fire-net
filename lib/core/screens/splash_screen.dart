import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _loadingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the glow effect (subtle and slow)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Scale animation for the icon (very subtle breathing)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Loading indicator animation (slow rotation)
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Concentric circles with pulsating glow
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow circle (animates with pulse)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 200 * _pulseAnimation.value,
                  height: 200 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.danger.withValues(alpha: 0.12),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Middle ring (static accent circle)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),

            // Fire icon (scales with breathing animation, fills circle)
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  size: 56,
                  color: AppColors.danger,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // FireNet text below the pulse (red color)
        const Text(
          'FireNet',
          style: TextStyle(
            color: AppColors.danger,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use theme-aware background color
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background gradient lines (tech aesthetic)
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPainter(isDark: isDark),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo with pulse glow
                _buildAnimatedLogo(),

                const SizedBox(height: 50),

                // Tagline
                Text(
                  'Real-time Safety Monitoring',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 60),

                // Loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: AnimatedBuilder(
                    animation: _loadingController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _LoadingIndicatorPainter(
                            progress: _loadingController.value),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Status text
                Text(
                  'Initializing System',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for background decorative lines
class _BackgroundPainter extends CustomPainter {
  final bool isDark;

  _BackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.danger.withValues(alpha: isDark ? 0.05 : 0.08)
      ..strokeWidth = 1;

    // Vertical lines
    for (double i = 0; i < size.width; i += 80) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double i = 0; i < size.height; i += 80) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => oldDelegate.isDark != isDark;
}

/// Custom painter for animated loading indicator
class _LoadingIndicatorPainter extends CustomPainter {
  final double progress;

  _LoadingIndicatorPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.danger.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Animated gradient arc
    final paint = Paint()
      ..color = AppColors.danger
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final sweepAngle = progress * 2 * 3.14159;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      sweepAngle,
      2.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_LoadingIndicatorPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
