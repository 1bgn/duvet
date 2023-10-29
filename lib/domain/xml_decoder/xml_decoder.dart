import 'dart:math';

import 'package:xml/xml.dart';

import '../model/child_and_parents.dart';

class XmlDecoder{
  static final inlineTags = ["a",];
  static List<ChildAndParents> decodeXml(XmlNode xmlElement,{int? ID}){
    final descendants = xmlElement.children.where((element) => element.text.trim().isNotEmpty);
    List<ChildAndParents> elements = [];
    // print(descendants);
    int id =ID?? Random().nextInt(1000);
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
  static List<ChildAndParents> combine(List<ChildAndParents> elements){
    List<ChildAndParents> combinedElements = [];

    for(int i =0;i<elements.length-1;i++){
      final element1 =elements[i];
      final element2 =elements[i+1];
      // print(element1.toString() +" "+ element2.toString());

      if(isNeedCombine(element1, element2) && isRelatives(element1, element2)){

        combinedElements.add(mergeChild(element1, element2));
        i=i+1;
      }else{

        combinedElements.add(element1);
      }
    }
    return combinedElements;
  }
  static bool isInlineNode(ChildAndParents element){
    // if(!inlineTags.contains(element.parents.first.name.qualified) && element.child.text.contains("[1")){
    //   print("verve ${element.child.text}");
    // }
    return inlineTags.contains(element.parents.first.name.qualified);
  }
  static XmlName getLineNodeName(ChildAndParents element1,ChildAndParents element2){
    return XmlName(isInlineNode(element1)?element2.parents.first.name.qualified:element1.parents.first.name.qualified);
  }
  static bool isNeedCombine(ChildAndParents  element1,ChildAndParents element2){

    return isInlineNode(element1) || isInlineNode(element2);
  }

  static bool isRelatives(ChildAndParents element1,ChildAndParents element2, ){
    final parents1 = element1.parents.skip(1).map((e) => e.qualifiedName).join();
    final parents2 = element2.parents.skip(1).map((e) => e.qualifiedName).join();
    return parents1.contains(parents2) || parents2.contains(parents1);
  }
  static ChildAndParents mergeChild(ChildAndParents element1,ChildAndParents element2){
    return ChildAndParents(child: XmlElement(getLineNodeName(element1, element2),[],[XmlText("${element1.child.text}${element2.child.text}",)]), parents: element1.parents.skip(1).toList());
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