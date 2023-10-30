import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/model/child_and_parents.dart';
import 'package:projects/domain/model/decorated_node.dart';
import 'package:projects/domain/model/styled_node.dart';
import 'package:projects/test_xml/xml_tester.dart';
import 'package:xml/xml.dart';

import '../hyphenator/hyphenator.dart';

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

  static List<InlineSpan> combine(List<ChildAndParents> elements){
    // return elements.map(createStyledNode).map((e) => TextSpan(text: "${e.childAndParents.child.text}\n",style: e.textStyle)).toList();
    List<InlineSpan> combinedElements = [];
    List<ChildAndParents> childCombinedElements = [];

    int lastId = -1;
    InlineSpan? lastSpan;
    StyledNode? lastNode;
    ChildAndParents? lastElement;

    for(int i =0;i<elements.length;i++){
      var currentElement =elements[i];
      if(lastElement==null){
        combinedElements.add(isInlineNode(currentElement)?createInlineSpan(createStyledNode(currentElement)):createBlockSpan(createStyledNode(currentElement)));
      }else{
        //lastElement != null
        if(isInlineNode(lastElement)&&isInlineNode(currentElement)){
         combinedElements.add(createInlineSpan(createStyledNode(currentElement)));
        }else if(isInlineNode(lastElement)&& !isInlineNode(currentElement)){


          if(lastElement.id==currentElement.id){
            combinedElements.add(createInlineSpan(createStyledNode(currentElement)));
          }else{
            combinedElements.removeLast();
            combinedElements.add(createBlockSpan(createStyledNode(lastElement)));
            combinedElements.add(createBlockSpan(createStyledNode(currentElement)));

          }
        }else if(!isInlineNode(lastElement)&& isInlineNode(currentElement)){

          if(lastElement.id==currentElement.id){
            combinedElements.removeLast();
            combinedElements.add(createInlineSpan(createStyledNode(lastElement)));
            combinedElements.add(createInlineSpan(createStyledNode(currentElement)));
          }else{
            combinedElements.add(createBlockSpan(createStyledNode(currentElement)));

          }

        }else if(!isInlineNode(lastElement)&& !isInlineNode(currentElement)){

            combinedElements.add(createBlockSpan(createStyledNode(currentElement)));



        }
      }
      lastElement = currentElement;
      // if(lastNode==null ){
      //   lastNode = createStyledNode(currentElement);
      //   lastSpan = createInlineSpan(lastNode);
      // }else if(lastNode !=null){
      //   if(!isInlineNode(lastNode.childAndParents)&&!isInlineNode(currentElement)){
      //     combinedElements.add(createBlockSpan(lastNode));
      //     combinedElements.add(createBlockSpan(createStyledNode(currentElement)));
      //     lastNode = null;
      //     lastSpan = null;
      //   }else if(isInlineNode(lastNode.childAndParents)&&!isInlineNode(currentElement)){
      //     final elem = mergeChild3(createInlineSpan(lastNode), createBlockSpan(createStyledNode(currentElement)));
      //     combinedElements.add(elem);
      //     lastSpan = null;
      //     lastNode = null;
      //   }else if(!isInlineNode(lastNode.childAndParents)&&isInlineNode(currentElement)){
      //     final elem = mergeChild3(createBlockSpan(lastNode), createInlineSpan(createStyledNode(currentElement)));
      //     combinedElements.add(elem);
      //     lastSpan = null;
      //     lastNode = null;
      //   }else if(isInlineNode(lastNode.childAndParents)&&isInlineNode(currentElement)){
      //     final elem = mergeChild3(createInlineSpan(lastNode), createInlineSpan(createStyledNode(currentElement)));
      //     combinedElements.add(elem);
      //     lastSpan = null;
      //     lastNode = null;
      //   }
      // }
      // final styledNode = createStyledNode(currentElement);
      
      // if(isInlineNode(currentElement)){
      //   lastSpan = TextSpan(text: styledNode.childAndParents.child.text,style:styledNode.textStyle);
      // }else{
      //  
      // }
      
      
      lastId = currentElement.id;
    }
    return combinedElements;
  }
  static InlineSpan createInlineSpan(StyledNode styledNode){
   return TextSpan(text: styledNode.childAndParents.child.text,style: styledNode.textStyle);
  }
  static InlineSpan createBlockSpan(StyledNode styledNode){
    return TextSpan(text: "${styledNode.childAndParents.child.text}\n",style: styledNode.textStyle);
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

