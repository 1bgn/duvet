import 'package:flutter/material.dart';
import 'package:projects/domain/model/styled_element.dart';

class BookData{
  final List<StyledElement> elements;
  final BoxConstraints size;
  final int countWordsInBook;

  BookData({required this.elements, required this.size, required this.countWordsInBook});
}