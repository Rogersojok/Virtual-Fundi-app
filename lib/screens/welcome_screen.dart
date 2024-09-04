import 'package:flutter/material.dart';
import 'package:virtualfundi/screens/signin_screen.dart';
import 'package:virtualfundi/screens/signup_screen.dart';
import 'package:virtualfundi/widgets/custom_scaffold.dart';
import 'package:virtualfundi/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Stack(
        children: [
          // Background Image covering the full screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpeg', // Path to your background image
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          // Centered Text Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome To!\n',
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.orange,
                      ),
                    ),
                    TextSpan(
                      text: '\nVirtual Fundi',
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Buttons Section
          const Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: WelcomeButton(
                    buttonText: 'Sign Up',
                    onTap: SignUpScreen(),
                    color: Colors.transparent, // Ensure button color is set to transparent
                    textColor: Colors.orange,
                  ),
                ),
                Expanded(
                  child: WelcomeButton(
                    buttonText: 'Log In',
                    onTap: SignInScreen(),
                    color: Colors.orange,
                    textColor: Colors.white,
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
