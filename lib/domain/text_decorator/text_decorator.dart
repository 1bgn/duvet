import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/model/child_and_parents.dart';
import 'package:projects/domain/model/decorated_node.dart';
import 'package:xml/xml.dart';

import '../hyphenator/hyphenator.dart';

class TextDecorator {
  static double heightCounter = 0;
  static final Hyphenator _hyphenator = Hyphenator();
  static final  Size _screenSize = Size(411.4, 707.4);

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
      // if(xmlNode.hasParent && xmlNode.parent!.nodeType == XmlNodeType.ELEMENT){
      //   final xmlNodeElement = xmlNode as XmlElement;
      //
      //   switch (xmlNodeElement.qualifiedName){
      //     case "p":{
      //       return TextSpan(text: "${_hyphenator.hyphenate(xmlNode.text)}\n",style: const TextStyle(color: Colors.black,));
      //     }
      //     case "book-title":{
      //       return TextSpan(text: "${_hyphenator.hyphenate(xmlNode.text)}\n",style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold));
      //     }
      //   }
      // }
    // switch (xmlNode.name.qualified) {
    //   case "p":{
    //
    //     if(xmlNode.children.length != 1){
    //       return TextSpan(
    //           children:
    //           xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList());
    //     }else{
    //
    //       return TextSpan(text: "${_hyphenator.hyphenate(xmlNode.text)}\n",style: TextStyle(color: Colors.black));
    //     }
    //   }
    //   case "title":
    //     return WidgetSpan(child: Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Expanded(
    //           child: Text(
    //              "${xmlNode.text}\n",
    //               textAlign: TextAlign.center,
    //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black)),
    //         ),
    //       ],
    //     ));
    //   case "section":
    //     return TextSpan(
    //         text: "",
    //         children:
    //             xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList());
    //   case "body":
    //     return TextSpan(
    //         text: "",
    //         style: TextStyle(color: Colors.black),
    //         children:
    //         xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList());
    //   case "description":
    //     return TextSpan(
    //         text: "",
    //         children:
    //             xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList());
    //   case "emphasis":
    //     return TextSpan(
    //         text: "",
    //         children:
    //             xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList(),
    //         style: TextStyle(fontStyle: FontStyle.italic));
    //     case "epigraph":
    //     return WidgetSpan(child: Row(children: [Expanded(
    //       child: RichText(textAlign: TextAlign.end,text: TextSpan(
    //           text: "",
    //           children:
    //           xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList(),
    //           style: TextStyle(fontStyle: FontStyle.italic,color: Colors.black))),
    //     )],));
    //   case "empty-line":{
    //     return TextSpan(text: "\n");
    //   }
    //   case "strong":{
    //
    //     if(xmlNode.children.length != 1){
    //       return TextSpan(
    //
    //
    //           children:
    //           xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList());
    //     }else{
    //       return TextSpan(
    //         text: xmlNode.text,
    //         style: TextStyle(fontWeight: FontWeight.bold)
    //       );
    //     }
    //   }
    //
    //   default:
    //     {
    //
    //       return TextSpan(text: "${xmlNode.text}", style: TextStyle(fontSize: 14));
    //     }
    // }

    return TextSpan(text: xmlNode.text, style: TextStyle(fontSize: 14));
  }
}

