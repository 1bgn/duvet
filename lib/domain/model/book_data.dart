import 'package:flutter/material.dart';
import 'package:projects/domain/model/decoded_xml.dart';
import 'package:projects/domain/model/styled_element.dart';

class BookData{
  final DecodedXml decodedXml;
  final BoxConstraints size;
  final int countWordsInBook;
  late final List<StyledElement> _originalElements;

  BookData({required this.decodedXml, required this.size, required this.countWordsInBook}){
    _originalElements = List.from(decodedXml.elements);

  }
  void resetElements() {
    decodedXml.elements.clear();
    decodedXml.elements.addAll(List.from(_originalElements));
}
}