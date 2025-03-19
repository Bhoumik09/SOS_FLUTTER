import 'package:emergency_app/screens/emergency_form.dart';
import 'package:emergency_app/widgets/option_buttons.dart';
import 'package:flutter/material.dart';

class EmergencyOption extends StatefulWidget {
  const EmergencyOption({super.key});

  @override
  State<EmergencyOption> createState() => _EmergencyOptionState();
}

class _EmergencyOptionState extends State<EmergencyOption> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OptionButton(
                title: 'Fire Emergency',
                color: Colors.orange,
                icon: Icons.local_fire_department,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyForm(type: 'fire'),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              OptionButton(
                title: 'Crime Emergency',
                color: Colors.red,
                icon: Icons.warning,
                onPressed: () {},
              ),
              const SizedBox(
                height: 20,
              ),
              OptionButton(
                title: 'Medical Emergency',
                color: Colors.blue,
                icon: Icons.local_hospital,
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}
