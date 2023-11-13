import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/hyphenator/hyphenator.dart';
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
  static List<StyledElement> elementsFromXml(
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
      // if(annotation.isNotEmpty){
      //   elements.insert(0, annotation.first);
      // }
      final body = elements
          .map((e) => XmlDecoder.decodeXml(e))
          .expand((element) => element)
          .toList();

     return  TextDecorator.combine(body);

  }
  static Widget widgetFromXml(
      {required double maxWidth,
      required double maxHeight,
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
    if(_elements ==null){
      final document = XmlDocument.parse(xmlText);
      final sections = document
          .findAllElements("body")
          .map((e) => XmlDecoder.decodeXml(e))
          .expand((element) => element)
          .toList();
      _elements = TextDecorator.combine(sections);
    }
    // final elements = sections.map((e) => TextDecorator.fb2Decorate(e)).toList();

    // print("MEDIUM LINES: ${TextDecorator.mediumMetrics(maxWidth, maxHeight, elements)}");
    return PageView.builder(
      controller: pageController,
      onPageChanged: (int index){

        lastPage = index;

      },
      itemBuilder: (BuildContext context, int index) {
        print("PAGE ${lastPage} $index");
       if(lastPage!=-1){
         if(lastPage<index){
           final nextElements = TextDecorator.skipElement(currentBundle.bottomElement.styledNode.childAndParents.id, elements);
           if(currentBundle.rightPartOfElement!=null){
             nextElements.insert(0, currentBundle.rightPartOfElement!);
           }
           nextElements.take(2).forEach((element) {
             print("TOP ${element.inlineSpan.toPlainText()}");

           });
           currentBundle = TextDecorator.getNextPageBundle(maxWidth, maxHeight, nextElements);
           pages.add(currentBundle);

         }else{
           //ПОКА НЕ ОПНЯТНО ЧТО ДЕЛАТЬ
           currentBundle = pages[index];
           // final previousElements = TextDecorator.takeElement(currentBundle.topElement.styledNode.childAndParents.id, elements);
           // print('previousElements: ${currentBundle.topElement.inlineSpan.toPlainText()}');
           // if(currentBundle.rightPartOfElement!=null){
           //   previousElements.add( currentBundle.rightPartOfElement!);
           // }
           // // previousElements.take(2).forEach((element) {
           // //   print("BOTTOM ${element.inlineSpan.toPlainText()}");
           // //
           // // });
           // currentBundle = TextDecorator.getPreviousPageBundle(maxWidth, maxHeight, previousElements);
         }
       }else{
         currentBundle = TextDecorator.getNextPageBundle(maxWidth, maxHeight, elements);
         pages.add(currentBundle);
       }
        return  RichText(
          text: TextSpan(

              children: currentBundle
                  .currentElements
                  .map((e) => e.inlineSpan)
                  .toList(),
              style: TextStyle(color: Colors.black)),
        );
      },

    );
    return RichText(
      text: TextSpan(
          children: TextDecorator.getNextPageBundle(maxWidth, maxHeight, elements)
              .currentElements
              .map((e) => e.inlineSpan)
              .toList(),
          style: TextStyle(color: Colors.black)),
    );
    // return RichText(text:TextSpan(children:  TextDecorator.getPage(maxWidth, maxHeight, elements).map((e) => e).toList(),style: TextStyle(color:Colors.black)),);
  }
}
