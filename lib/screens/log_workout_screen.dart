import 'package:flutter/material.dart';

class LogWorkoutScreen extends StatelessWidget {
  const LogWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.blueAccent),
          SizedBox(height: 20),
          Text(
            'Log Workout',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Form inputs will be built here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}