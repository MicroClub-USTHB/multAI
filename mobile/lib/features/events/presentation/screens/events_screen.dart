import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Text('Events', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
