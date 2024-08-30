import 'package:flutter/material.dart';
import 'package:virtualfundi/screens/signup_screen.dart';
import 'package:virtualfundi/widgets/custom_scaffold.dart';
import 'package:virtualfundi/widgets/welcome_button.dart';
import '../database/database.dart';
import '../utills/animateAButton.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true; // State to manage password visibility

  @override
  void initState() {
    super.initState();
    final dbHelper = DatabaseHelper();
    dbHelper.initializeDatabase();
  }

  final _formSignInKey = GlobalKey<FormState>();
  int? userId;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      // Display error
      return;
    }

    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    // get user with the provided email
    final user = await dbHelper.getUser(email);

    // check if the email exists
    if (user?.email != null) {
      print('User Exist');
      // go ahead and check if password matches
      if (user?.password == password) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged in successfully')));
        userId = await dbHelper.getUserId(email);
        // Navigate to home screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (e) => HomeScreen(userId: userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong password')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found')));
    }
  }

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
          // Login Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600, // Limit the form width for larger screens
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensures the column doesn't take more space than needed
                  children: [
                    // Login Form Container
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent.withOpacity(0.9), Colors.blueAccent.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo or Header
                          const SizedBox(
                            height: 80,
                            child: Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          // Form
                          Form(
                            key: _formSignInKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'User name',
                                    hintText: 'Enter your User name',
                                    hintStyle: TextStyle(color: Colors.white),
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword, // Toggle password visibility
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    hintStyle: TextStyle(color: Colors.white),
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                // Login Button
                                ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                  child: Text('Login'),
                                ),
                                const SizedBox(height: 20.0),
                                // Divider with Text
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        thickness: 0.7,
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        'Or',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        thickness: 0.7,
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                // Social Login Buttons (Placeholder)
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Add your social media login buttons here
                                    // e.g., Facebook, Google
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                // Don't Have an Account
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Don\'t have an account? ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SignUpScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Sign up',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        ],
      ),
    );
  }
}
