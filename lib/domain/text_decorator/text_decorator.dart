import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/model/child_and_parents.dart';
import 'package:projects/domain/model/styled_element.dart';

import 'package:projects/domain/model/styled_node.dart';

import 'package:xml/xml.dart';



class TextDecorator {

  static final inlineTags = ["a",];


  static InlineSpan fb2Decorate(ChildAndParents childAndParents,) {
      final xmlNode = childAndParents.child;

      TextStyle textStyle = const TextStyle(inherit: true);
      for (var element in childAndParents.parents.reversed) {

       switch(element.qualifiedName){
         case "book-title":{

           textStyle.merge(TextStyle(fontWeight: FontWeight.bold));
         }
         case "title":{
           textStyle = textStyle.merge(TextStyle(fontWeight: FontWeight.bold));
         }
         case "epigraph":{
           textStyle = textStyle.merge(TextStyle(fontStyle: FontStyle.italic));

         }
         case "p":{
          textStyle = textStyle.merge(TextStyle(fontSize: 14));
         }
         case "a":{
           textStyle = textStyle.merge(TextStyle(color: Colors.blueAccent));
         }
       }
      }

      return TextSpan(text:  "${xmlNode.text}\n",style: textStyle);

  }


  static StyledNode createStyledNode(ChildAndParents childAndParents,) {

    TextStyle textStyle = const TextStyle(inherit: true);
    for (var element in childAndParents.parents.reversed) {

      switch(element.qualifiedName){
        case "book-title":{

          textStyle.merge(TextStyle(fontWeight: FontWeight.bold));
        }
        case "title":{
          textStyle = textStyle.merge(TextStyle(fontWeight: FontWeight.bold));
        }
        case "epigraph":{
          textStyle = textStyle.merge(TextStyle(fontStyle: FontStyle.italic));

        }
        case "p":{
          textStyle = textStyle.merge(TextStyle(fontSize: 14));
        }
        case "a":{
          textStyle = textStyle.merge(TextStyle(color: Colors.blueAccent));
        }
      }
    }

   return StyledNode(childAndParents: childAndParents, textStyle: textStyle);
  }
  static List<StyledElement> layoutElements(double maxWidth,List<StyledElement> elements){
    for (var element in elements) {
      TextPainter textPainter = TextPainter(text: element.inlineSpan,textDirection: TextDirection.ltr);
      textPainter.layout(maxWidth: maxWidth);
      element.styleAttributes.height+=textPainter.height;
      element.styleAttributes.width+=textPainter.width;
    }
    return elements;
  }

  static List<StyledElement> combine(List<ChildAndParents> elements){
    List<StyledElement> combinedElements = [];



    ChildAndParents? lastElement;

    for(int i =0;i<elements.length;i++){
      var currentElement =elements[i];
      if(lastElement==null){
        combinedElements.add(isInlineNode(currentElement)?createInlineElement(createStyledNode(currentElement)):createBlockElement(createStyledNode(currentElement)));
      }else{
        //lastElement != null
        if(isInlineNode(lastElement)&&isInlineNode(currentElement)){
         combinedElements.add(createInlineElement(createStyledNode(currentElement)));
        }else if(isInlineNode(lastElement)&& !isInlineNode(currentElement)){

          if(lastElement.id==currentElement.id){
            combinedElements.add(createInlineElement(createStyledNode(currentElement)));
          }else{
            combinedElements.removeLast();
            combinedElements.add(createBlockElement(createStyledNode(lastElement)));
            combinedElements.add(createBlockElement(createStyledNode(currentElement)));

          }
        }else if(!isInlineNode(lastElement)&& isInlineNode(currentElement)){

          if(lastElement.id==currentElement.id){
            combinedElements.removeLast();
            combinedElements.add(createInlineElement(createStyledNode(lastElement)));
            combinedElements.add(createInlineElement(createStyledNode(currentElement)));
          }else{
            combinedElements.add(createBlockElement(createStyledNode(currentElement)));

          }

        }else if(!isInlineNode(lastElement)&& !isInlineNode(currentElement)){

            combinedElements.add(createBlockElement(createStyledNode(currentElement)));



        }
      }
      lastElement = currentElement;
    }
    return combinedElements;
  }
  static StyledElement createInlineElement(StyledNode styledNode){
   return StyledElement(isInline: true, styledNode: styledNode);
  }
  static StyledElement createBlockElement(StyledNode styledNode){
    return StyledElement(isInline: false, styledNode: styledNode);
  }
  static bool isInlineNode(ChildAndParents element){
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
  static InlineSpan mergeChild(StyledNode element1,StyledNode element2){
    return TextSpan(text: element1.childAndParents.child.text,style: element1.textStyle,children: [TextSpan(text: element2.childAndParents.child.text+"\n",style: element2.textStyle)]);
  }
  static InlineSpan mergeChild3(InlineSpan element1,InlineSpan element2){
    return TextSpan(text: "",children: [element1,element2]);
  }
}

