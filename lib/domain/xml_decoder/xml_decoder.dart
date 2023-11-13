import 'dart:math';

import 'package:xml/xml.dart';

import '../model/child_and_parents.dart';

class XmlDecoder{
  static final inlineTags = [
    "a","strong","emphasis"
  ];
  static final outlineTags = [
    "p","empty-line"
  ];

  static bool isInOutlineBlock(List<XmlElement> parents1, List<XmlElement> parents2,){
    // int parentsCount = childAndParents1.parents.length>childAndParents2.parents.length?childAndParents1.parents.length:childAndParents2.parents.length;
    bool inOutlineBlock = false;
    var hp1 = parents1.map((e) => e.hashCode.toString()).toSet();
    var hp2 = parents2.map((e) => e.hashCode.toString()).toSet();
    var p1 = parents1.map((e) => e.qualifiedName).toSet();
    var p2 = parents2.map((e) => e.qualifiedName).toSet();
    final intersection = p1.intersection(p2);
    print("$p1&&$p2");
    print("$hp1&&$hp2");

    if(hp1.first==hp2.first && outlineTags.contains(intersection.first)){

      inOutlineBlock = true;

    }

    return inOutlineBlock;
  }

  static bool isOutlineNode(XmlNode element) {
    // final p = parents(element).where((element) => element.qualifiedName!="section" || element.qualifiedName != "FictionBook" || !inlineTags.contains(element.qualifiedName) );
    return outlineTags.toSet().intersection(parents(element).map((e) => e.qualifiedName).toSet()).isNotEmpty;
  }
  static List<ChildAndParents> groupRelatives( List<ChildAndParents> elements){
    int id = Random().nextInt(10000000);
    ChildAndParents? lastElement = null;
    for (var element in elements) {
      if(lastElement==null){
        lastElement = element;
        lastElement.id = id;
      }else if(isInOutlineBlock(lastElement.parents,element.parents)){
        element.id = lastElement.id;
      }else{
        id = Random().nextInt(10000000);
        element.id = id;
      }
    }
    return elements;
  }
  static List<ChildAndParents> decodeXml(XmlNode xmlElement,{int? ID,bool isEmptyLine=false}){
    final descendants = xmlElement.children ;
    List<ChildAndParents> elements = [];
    // print(descendants);
    int id =ID?? Random().nextInt(10000000);
    XmlNode? lastElement = null;
    if(isEmptyLine){
      elements.add(ChildAndParents(child: xmlElement, parents: parents(xmlElement),id: id));

    }
    for (var element in descendants) {

      if(element.nodeType == XmlNodeType.TEXT){
        elements.add(ChildAndParents(child: element, parents: parents(element),id: id));
      }else if(element.nodeType == XmlNodeType.ELEMENT ){
        if(lastElement?.nodeType==XmlNodeType.TEXT  ){
          // print(lastElement);
          // print("==$id==");
          elements.addAll(decodeXml(element,ID: id,));

        }else{

          if(isOutlineNode(element) ){

            elements.addAll(decodeXml(element,ID: id));
          }else{

            final elem = element as XmlElement;
            elements.addAll(decodeXml(element,isEmptyLine: elem.qualifiedName=="empty-line"));

          }

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