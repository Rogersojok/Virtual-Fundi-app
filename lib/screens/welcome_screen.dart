import 'package:flutter/material.dart';
import 'package:virtualfundi/screens/signin_screen.dart';
import 'package:virtualfundi/screens/signup_screen.dart';
import 'package:virtualfundi/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image covering the full screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpeg', // Path to your background image
              fit: BoxFit.cover, // Ensures the image covers the entire screen
              color: Colors.black.withOpacity(0.3), // Adding a slight dark overlay for contrast
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Centered Text Content
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
                            fontSize: 75,
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
                    'Your gateway to a virtual learning experience.',
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
          // Buttons Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Padding around the button section
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10), // Button-specific padding
                      child: WelcomeButton(
                        buttonText: 'Sign Up',
                        onTap: const SignUpScreen(),
                        color: Colors.transparent, // Ensure button color is set to transparent
                        textColor: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Add space between the buttons
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10), // Button-specific padding
                      child: WelcomeButton(
                        buttonText: 'Log In',
                        onTap: const SignInScreen(),
                        color: Colors.orange,
                        textColor: Colors.white,
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
