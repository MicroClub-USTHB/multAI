import 'package:flutter/material.dart';
import 'pictures_grid.dart';

class AllPictures extends StatelessWidget {
  final List<String> pictures;
  const AllPictures({required this.pictures, super.key});

  @override
  Widget build(BuildContext context) {
    return PicturesGrid(pictures: pictures);
  }
}
