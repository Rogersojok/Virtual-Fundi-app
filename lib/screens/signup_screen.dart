import 'package:flutter/material.dart';
import 'package:virtualfundi/screens/signin_screen.dart';
import 'package:virtualfundi/widgets/custom_scaffold.dart';
//import 'package:virtualfundi/widgets/animateAButton.dart';
import '../database/database.dart';
import '../utills/animateAButton.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool _passwordVisible = false; // To control password visibility

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signup() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    String username = _nameController.text;
    String school = _schoolController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (username.isEmpty || school.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final user = await dbHelper.getUser(email);

    if (user?.email != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User already exists')));
    } else {
      final insertUser = User(
        name: username,
        password: password,
        school: school,
        email: email,
      );
      await dbHelper.insertUser(insertUser);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ),
      );
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
          // Signup Form
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
                    // Signup Form Container
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
                            offset: const Offset(0, 5),
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
                                'Sign Up',
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
                            key: _formSignupKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Full Name Field
                                TextFormField(
                                  controller: _nameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your full name';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    hintText: 'Enter your full name',
                                    hintStyle: TextStyle(color: Colors.white),
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                // School Field
                                TextFormField(
                                  controller: _schoolController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your school';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'School',
                                    hintText: 'Enter your school',
                                    hintStyle: TextStyle(color: Colors.white),
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
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
                                    labelText: 'Email',
                                    hintText: 'Enter your email',
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
                                  obscureText: !_passwordVisible, // Toggle password visibility
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
                                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                // Agree to Terms Checkbox
                                Row(
                                  children: [
                                    Checkbox(
                                      value: agreePersonalData,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          agreePersonalData = value!;
                                        });
                                      },
                                      activeColor: Colors.blueAccent,
                                    ),
                                    const Text(
                                      'I agree to the processing of ',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Personal Data',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                // Signup Button
                                ElevatedButton(
                                  onPressed: _signup,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                  child: Text('Sign Up'),
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
                                // Social Signup Buttons (Placeholder)
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Add your social media signup buttons here
                                    // e.g., Facebook, Google
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                // Already have an account
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Already have an account? ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SignInScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
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
