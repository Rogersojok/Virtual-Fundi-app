
import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedElevatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Duration animationDuration;

  const AnimatedElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _AnimatedElevatedButtonState createState() => _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton> {
  bool _isClicked = false;
  Timer? _timer;

  void _animateButton() {
    setState(() {
      _isClicked = !_isClicked;
    });

    // Reset the button state after a delay
    _timer = Timer(widget.animationDuration, () {
      setState(() {
        _isClicked = !_isClicked;
      });
    });

    widget.onPressed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.animationDuration,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isClicked ? Colors.grey : Colors.blue,
          foregroundColor: _isClicked ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
        ),
        onPressed: _animateButton,
        child: Text(
          widget.text,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}