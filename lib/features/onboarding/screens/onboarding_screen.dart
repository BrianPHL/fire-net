import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to FireNet',
      description: 'Real-time fire, gas, and smoke detection for your safety',
      icon: Icons.security_rounded,
      color: AppColors.danger,
    ),
    OnboardingPage(
      title: 'Multi-Node Monitoring',
      description: 'Monitor multiple sensor nodes across your space in real-time',
      icon: Icons.router_outlined,
      color: AppColors.danger,
    ),
    OnboardingPage(
      title: 'Instant Alerts',
      description: 'Receive immediate notifications when hazards are detected',
      icon: Icons.notifications_active_rounded,
      color: AppColors.danger,
    ),
    OnboardingPage(
      title: 'Historical Tracking',
      description: 'View detailed alert history and system diagnostics',
      icon: Icons.history_rounded,
      color: AppColors.danger,
    ),
    OnboardingPage(
      title: 'Stay Protected',
      description: 'Start monitoring your space now for complete peace of mind',
      icon: Icons.shield_rounded,
      color: AppColors.danger,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.jumpToPage(_pages.length - 1);
  }

  void _getStarted() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Page view with onboarding slides
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_pages[index]);
            },
          ),

          // Top bar with skip button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button (visible after first page)
                    _currentPage > 0
                        ? IconButton(
                            onPressed: _previousPage,
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                            color: AppColors.textPrimary,
                          )
                        : const SizedBox(width: 48),
                    // Skip button
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _skipToEnd,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation and indicators
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildIndicator(index),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Navigation buttons
                    Row(
                      children: [
                        // Previous button
                        if (_currentPage > 0)
                          OutlinedButton(
                            onPressed: _previousPage,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              side: const BorderSide(
                                color: AppColors.danger,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios,
                                  color: AppColors.danger,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(width: 12),

                        // Next / Get Started button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _currentPage == _pages.length - 1
                                ? _getStarted
                                : _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _currentPage == _pages.length - 1
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Get Started',
                                        style: TextStyle(
                                          color: AppColors.darkTextPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppColors.darkTextPrimary,
                                        size: 16,
                                      ),
                                    ],
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Next',
                                        style: TextStyle(
                                          color: AppColors.darkTextPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppColors.darkTextPrimary,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentPage;
    return GestureDetector(
      onTap: () => _pageController.jumpToPage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 8,
        width: isActive ? 24 : 8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.danger : AppColors.danger.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon or illustration area
        Container(
          width: 120,
          height: 120,
          margin: const EdgeInsets.only(bottom: 48),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.color.withValues(alpha: 0.15),
          ),
          child: Icon(
            page.icon,
            size: 64,
            color: page.color,
          ),
        ),

        // Title - uses theme-aware text color
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Builder(
            builder: (context) => Text(
              page.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Description - uses theme-aware text color
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Builder(
            builder: (context) => Text(
              page.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
