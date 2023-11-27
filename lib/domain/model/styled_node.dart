
import 'package:flutter/material.dart';
import 'package:projects/domain/model/child_and_parents.dart';

class StyledNode {
  final ChildAndParents childAndParents;
  final TextStyle textStyle;
  final TextAlign textAlign;


  StyledNode({required this.childAndParents, required this.textStyle,required this.textAlign});
}