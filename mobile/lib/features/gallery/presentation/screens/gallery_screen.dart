import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';
 
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Text('Gallery', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
 
 
