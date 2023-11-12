import 'dart:math';

import 'package:xml/xml.dart';

import '../model/child_and_parents.dart';

class XmlDecoder{
  static final inlineTags = ["a"];
  static List<ChildAndParents> decodeXml(XmlNode xmlElement,{int? ID}){
    final descendants = xmlElement.children.where((element) => element.text.trim().isNotEmpty) ;
    List<ChildAndParents> elements = [];
    // print(descendants);
    int id =ID?? Random().nextInt(10000000);
    XmlNode? lastElement = null;
    for (var element in descendants) {

      if(element.nodeType == XmlNodeType.TEXT &&element.text.trim().isNotEmpty){
        elements.add(ChildAndParents(child: element, parents: parents(element),id: id));
      }else if(element.nodeType == XmlNodeType.ELEMENT){
        if(lastElement?.nodeType==XmlNodeType.TEXT){
          elements.addAll(decodeXml(element,ID: id));

        }else{
          elements.addAll(decodeXml(element,));

        }
      }
      lastElement = element;
    }

    return elements;
  }

  static List<XmlElement> parents(XmlNode xmlNode){
    List<XmlElement> p = [];
    if(xmlNode.parentElement!=null){
      p.add( xmlNode.parentElement!);
      p.addAll(parents(xmlNode.parent!));
      return p;
    }
    return p;
  }
}