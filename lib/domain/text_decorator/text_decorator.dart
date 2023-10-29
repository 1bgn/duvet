import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/model/child_and_parents.dart';
import 'package:projects/domain/model/decorated_node.dart';
import 'package:projects/domain/model/styled_node.dart';
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
    List<InlineSpan> combinedElements = [];

    for(int i =0;i<elements.length-1;i++){
      final element1 =elements[i];
      final element2 =elements[i+1];
      // print(element1.toString() +" "+ element2.toString());

      if(element1.id==element2.id){

        combinedElements.add(mergeChild(createStyledNode(element1), createStyledNode(element2)));
        i=i+1;
        print("MERGE ${element1} ${element2}");
      }else{
        final elem = createStyledNode(element1);
        combinedElements.add(TextSpan(text: "${elem.childAndParents.child.text}\n",style: elem.textStyle));
      }
    }
    return combinedElements;
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
}

