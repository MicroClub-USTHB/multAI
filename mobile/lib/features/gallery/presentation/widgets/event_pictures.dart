import 'package:flutter/material.dart';
import 'pictures_grid.dart';

class EventPictures extends StatelessWidget {
  final List<String> pictures;
  const EventPictures({required this.pictures, super.key});

  @override
  Widget build(BuildContext context) {
    return PicturesGrid(pictures: pictures);
  }
}
