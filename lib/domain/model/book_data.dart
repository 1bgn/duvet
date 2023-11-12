import 'package:flutter/material.dart';
import 'package:projects/domain/model/styled_element.dart';

class BookData{
  final List<StyledElement> elements;
  final BoxConstraints size;
  final int countWordsInBook;
  late final List<StyledElement> _originalElements;

  BookData({required this.elements, required this.size, required this.countWordsInBook}){
    _originalElements = List.from(elements);
  }
  void resetElements() {
    elements.clear();
    elements.addAll(List.from(_originalElements));
}
}