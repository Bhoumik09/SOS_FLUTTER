import 'package:emergency_app/screens/emergency_option.dart';
import 'package:flutter/material.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Repeats the animation infinitely in reverse
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: ElevatedButton(
                onPressed: () {
                  // Your button action
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyOption(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,

                  shape: const CircleBorder(
                    side: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  padding: const EdgeInsets.all(
                      100.0), // Makes the button large enough to appear circular
                ),
                child: const Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 50, // Adjust text size as needed
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
