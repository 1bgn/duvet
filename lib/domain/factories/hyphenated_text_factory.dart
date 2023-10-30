import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/hyphenator/hyphenator.dart';
import 'package:projects/domain/model/hyphenated_text.dart';
import 'package:projects/domain/model/styled_element.dart';
import 'package:projects/domain/text_decorator/text_decorator.dart';
import 'package:projects/domain/xml_decoder/xml_decoder.dart';
import 'package:projects/test_xml/xml_tester.dart';
import 'package:xml/xml.dart';

class HyphenatedTextFactory {
  static final Hyphenator _hyphenator = Hyphenator();

  static HyphenatedText fromXml(
      {required double maxWidth,String xmlText = '''<?xml version="1.0"?>
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
    final sections = document
        .findAllElements("body")
        .map((e) => XmlDecoder.decodeXml(e))
        .expand((element) => element).toList();
    final elements = TextDecorator.combine(sections);
    // final elements = sections.map((e) => TextDecorator.fb2Decorate(e)).toList();
    print(elements.length);
    print(sections.length);

    sections.take(100).forEach((element) {
      print(element);
    });
    return HyphenatedText(
        text: TextSpan(
            text: "",
            children: TextDecorator.layoutElements(maxWidth, elements).map((e) => e.inlineSpan).toList(),
            style: TextStyle(color: Colors.black)));
  }
}
