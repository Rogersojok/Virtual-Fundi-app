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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
