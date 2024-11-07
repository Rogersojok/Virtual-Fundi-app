import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget? child;
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onForwardPressed;

  const CustomScaffold({
    Key? key,
    this.child,
    this.title = '',
    this.onBackPressed,
    this.onForwardPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  alignment: Alignment.center,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF003366),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFFFD700),
                        width: 4.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (onBackPressed != null)
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: onBackPressed,
                        ),
                      Expanded(
                        child: Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Navigation dropdown menu on the right side
                      PopupMenuButton<String>(
                        icon: Icon(Icons.menu, color: Colors.white),
                        onSelected: (value) {
                          // Handle menu selection here
                          switch (value) {
                            case 'Contact Us':
                            // Navigate to Contact Us page
                              break;
                            case 'About Fundi Bots':
                            // Navigate to About Fundi Bots page
                              break;
                            case 'Settings':
                            // Navigate to Settings page
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'Contact Us',
                              child: Row(
                                children: [
                                  Icon(Icons.contact_phone, color: Colors.black), // Icon for Contact Us
                                  SizedBox(width: 8),
                                  Text('Contact Us'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'About Fundi Bots',
                              child: Row(
                                children: [
                                  Icon(Icons.info, color: Colors.black), // Icon for About Fundi Bots
                                  SizedBox(width: 8),
                                  Text('About Fundi Bots'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Settings',
                              child: Row(
                                children: [
                                  Icon(Icons.settings, color: Colors.black), // Icon for Settings
                                  SizedBox(width: 8),
                                  Text('Settings'),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                      if (onForwardPressed != null)
                        IconButton(
                          icon: Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: onForwardPressed,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: child ?? const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
