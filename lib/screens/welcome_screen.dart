import 'package:flutter/material.dart';
import 'package:virtualfundi/screens/signin_screen.dart';
import 'package:virtualfundi/screens/signup_screen.dart';
import 'package:virtualfundi/widgets/welcome_button.dart';
import 'package:virtualfundi/services/post_service.dart';
import 'package:virtualfundi/theme/theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Initialize app
    AppInitializationService().runInitialization(context);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryOrange.withOpacity(0.1),
              AppColors.secondaryPurple.withOpacity(0.05),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background Image with Modern Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/background.jpeg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
            // Gradient Overlay for Modern Look
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Top Spacer
                  SizedBox(height: size.height * 0.1),

                  // Welcome Content
                  Expanded(
                    flex: 3,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Welcome Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: AppColors.primaryOrange.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Welcome To',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryOrange,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // App Title with Modern Typography
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.8),
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Virtual Fundi',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: size.width * 0.15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.1,
                                    letterSpacing: -1,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0, 4),
                                        blurRadius: 12,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      Shadow(
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                        color: AppColors.primaryOrange.withOpacity(0.2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Subtitle
                              Text(
                                'www.fundibots.org',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 0.5,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Feature highlights
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      color: AppColors.primaryOrange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.trending_up,
                                      color: AppColors.accentGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Buttons Section
                  Expanded(
                    flex: 1,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Buttons Row
                            Row(
                              children: [
                                // Sign Up Button
                                Expanded(
                                  child: WelcomeButton(
                                    buttonText: 'Sign Up',
                                    onTap: const SignUpScreen(),
                                    color: Colors.transparent,
                                    textColor: AppColors.primaryOrange,
                                    isOutlined: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Log In Button
                                Expanded(
                                  child: WelcomeButton(
                                    buttonText: 'Log In',
                                    onTap: const SignInScreen(),
                                    color: AppColors.primaryOrange,
                                    textColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Terms and Privacy
                            Text(
                              'By continuing, you agree to our Terms & Privacy Policy',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}