import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/hyphenator/hyphenator.dart';
import 'package:projects/domain/model/decoded_xml.dart';
import 'package:projects/domain/model/hyphenated_text.dart';
import 'package:projects/domain/model/styled_element.dart';
import 'package:projects/domain/text_decorator/text_decorator.dart';
import 'package:projects/domain/xml_decoder/xml_decoder.dart';
import 'package:projects/test_xml/xml_tester.dart';
import 'package:xml/xml.dart';

import '../model/page_bundle.dart';

class HyphenatedTextFactory {
  static final Hyphenator _hyphenator = Hyphenator();
  static List<StyledElement>? _elements;
  static List<StyledElement> get elements=>_elements!;
  static late PageBundle currentBundle;
  static PageController pageController = PageController(initialPage: 1);
  static int lastPage = -1;
  static List<PageBundle> pages = [];
  static DecodedXml elementsFromXml(
      {
        String xmlText = '''<?xml version="1.0"?>
    <bookshelf>
      <book>
        <title lang="en">Growing a Language</title>
        <price>29.99</price>
      </book>
      <book>
        <title lang="en">Learning XML</title>
        <price>39.95</price>
      </book>
      <price>132.00</price>
    </bookshelf>'''}) {

      final document = XmlDocument.parse(xmlText);
      final annotation =  document.findAllElements("annotation");
      final List<dynamic> elements = document.findAllElements("body").toList();
      final binaries = document.findAllElements("binary").toList();

      // if(annotation.isNotEmpty){
      //   elements.insert(0, annotation.first);
      // }
      final body = elements
          .map((e) => XmlDecoder.decodeXml(e))
          .expand((element) => element)
          .toList();
      print("LEN ${elements.length}");
      // body.take(10000).forEach((element) {
      //   print("FIRST TEXT $element");
      // });
     return  DecodedXml(elements: TextDecorator.combine(body),binaries: binaries.asMap().map((key, value) => MapEntry(value.getAttribute("id")??Random().nextInt(1000000000000).toString(), value)));

  }

}
