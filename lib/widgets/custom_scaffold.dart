import 'package:flutter/material.dart';
import '../screens/feedback_screen.dart';
import 'package:virtualfundi/screens/adminLogin.dart';

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
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Sarah Abs'),
              accountEmail: Text('sarah@abs.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/profile.PNG'), // Replace with your image path
              ),
              decoration: BoxDecoration(
                color: Color(0xFF6A0DAD), // Purple background
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.black),
                    title: Text('Home'),
                    onTap: () {
                      // Add navigation for home here
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite, color: Colors.black),
                    title: Text('Favourites'),
                    onTap: () {
                      // Add navigation for favourites here
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.work_outline, color: Colors.black),
                    title: Text('Workflow'),
                    onTap: () {
                      // Add navigation for workflow here
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.update, color: Colors.black),
                    title: Text('Updates'),
                    onTap: () {
                      // Add navigation for updates here
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.extension, color: Colors.black),
                    title: Text('Plugins'),
                    onTap: () {
                      // Add navigation for plugins here
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications, color: Colors.black),
                    title: Text('Feedback'),
                    onTap: () {
                      // Navigate to FeedbackScreen when "Feedback" is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FeedbackScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.admin_panel_settings, color: Colors.black),
                    title: Text('Admin'),
                    onTap: () {
                      // Navigate to FeedbackScreen when "Feedback" is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminLoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF6A0DAD), // Purple background
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          if (onBackPressed != null)
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: onBackPressed,
            ),
          if (onForwardPressed != null)
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: onForwardPressed,
            ),
        ],
      ),
      body: child ?? const SizedBox.shrink(),
    );
  }
}
