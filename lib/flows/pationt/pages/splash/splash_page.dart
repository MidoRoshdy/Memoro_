import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/string_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 2200), _navigateNext);
  }

  Future<void> _navigateNext() async {
    final shouldAutoLogin = await AuthService.shouldAutoLogin();
    if (shouldAutoLogin) {
      final caregiver = await AuthService.isCurrentUserCaregiver();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed(caregiver ? AppRouter.doctorHome : AppRouter.home);
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRouter.chooseFlow);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxLogoWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Image.asset(
                AppAssets.memoroBrandLogo,
                width: maxLogoWidth.clamp(200.0, 340.0),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
