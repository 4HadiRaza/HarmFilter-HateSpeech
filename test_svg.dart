import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  SvgPicture.network(
    'url', 
    placeholderBuilder: (c) => Container(),
  );
}
