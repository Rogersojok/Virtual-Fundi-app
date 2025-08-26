import 'package:flutter/material.dart';
import '../screens/feedback_screen.dart';
import 'package:virtualfundi/screens/adminLogin.dart';

import 'package:virtualfundi/theme/theme.dart';


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
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text(
                'Sarah Abs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: const Text(
                'sarah@abs.com',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/profile.PNG'),
                  radius: 35,
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondaryPurple,
                    AppColors.secondaryPurpleDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              otherAccountsPictures: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: const Icon(
                    Icons.settings,
                    color: AppColors.secondaryPurple,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home_rounded,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      // Add navigation for home here
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.favorite_rounded,
                    title: 'Favorites',
                    onTap: () {
                      Navigator.pop(context);
                      // Add navigation for favorites here
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.work_outline_rounded,
                    title: 'Workflow',
                    onTap: () {
                      Navigator.pop(context);
                      // Add navigation for workflow here
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.update_rounded,
                    title: 'Updates',
                    onTap: () {
                      Navigator.pop(context);
                      // Add navigation for updates here
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.extension_rounded,
                    title: 'Plugins',
                    onTap: () {
                      Navigator.pop(context);
                      // Add navigation for plugins here
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.feedback_rounded,
                    title: 'Feedback',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FeedbackScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'Admin',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminLoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Footer section with app version or additional info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Virtual Fundi v1.0',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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


  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
            ? AppColors.primaryOrange.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primaryOrange
                : AppColors.primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected 
                ? Colors.white
                : AppColors.primaryOrange,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected 
                ? AppColors.primaryOrange
                : Colors.grey.shade700,
            fontSize: 15,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),
    );
   }
}
