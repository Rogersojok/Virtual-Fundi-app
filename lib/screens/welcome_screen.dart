import 'package:flutter/material.dart';
import 'package:virtualfundi/screens/signin_screen.dart';
import 'package:virtualfundi/screens/signup_screen.dart';
import 'package:virtualfundi/widgets/welcome_button.dart';
import 'package:virtualfundi/services/post_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      AppInitializationService().runInitialization();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen Background Image with a subtle dark overlay for visual contrast
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpeg', // Background image path
              fit: BoxFit.cover, // Ensures the image fills the screen
              color: Colors.black.withOpacity(0.3), // Dark overlay with transparency
              colorBlendMode: BlendMode.darken, // Blend mode for the overlay effect
            ),
          ),
          // Centered Welcome Message
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome To!\n',
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Colors.orange,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: '\nVirtual Fundi',
                          style: TextStyle(
                            fontSize: 75.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(3.0, 3.0),
                                blurRadius: 8.0,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '', // Placeholder for additional text if needed
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Bottom Buttons for "Sign Up" and "Log In"
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Outer padding around the button section
              child: Row(
                children: [
                  // Sign Up Button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0), // Vertical padding for the button
                      child: WelcomeButton(
                        buttonText: 'Sign Up',
                        onTap: const SignUpScreen(),
                        color: Colors.transparent, // Transparent button background
                        textColor: Colors.orange, // Text color matching theme
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Spacing between the buttons
                  // Log In Button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0), // Vertical padding for the button
                      child: WelcomeButton(
                        buttonText: 'Log In',
                        onTap: const SignInScreen(),
                        color: Colors.orange, // Button color aligned with theme
                        textColor: Colors.white, // Text color for contrast
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
