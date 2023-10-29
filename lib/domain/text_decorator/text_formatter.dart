import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/model/decorated_node.dart';
import 'package:xml/xml.dart';

import '../hyphenator/hyphenator.dart';


class TextDecorator {
  static final Hyphenator _hyphenator = Hyphenator();

  static DecoratedNode fb2Decorate(XmlElement xmlNode) {
    switch (xmlNode.name.qualified) {
      case "p":{

        if(xmlNode.children.length != 1){
          return DecoratedNode(children: xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList());
        }else{

          return DecoratedNode(xmlNode: xmlNode);
        }
      }
      case "title":
        return DecoratedNode(xmlNode: xmlNode,textStyle: TextStyle(fontWeight: FontWeight.bold));
      case "section":
        return            DecoratedNode(children: xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList());

      case "body":
        return DecoratedNode(children: xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList());

      case "description":
        return DecoratedNode(children: xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList());

      case "emphasis":
        return DecoratedNode(children: xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList(),textStyle: TextStyle(fontStyle: FontStyle.italic));

      case "empty-line":{
        return DecoratedNode(xmlNode: xmlNode);
      }
      case "strong":{

        if(xmlNode.children.length != 1){
          return DecoratedNode(children: xmlNode.childElements.map((p0) => fb2Decorate(p0)).toList());
        }else{

          return DecoratedNode(xmlNode: xmlNode,textStyle: TextStyle(fontWeight: FontWeight.bold));
        }
      }

      default:
        {

          return DecoratedNode(textStyle: TextStyle(fontSize: 14),xmlNode: xmlNode);
        }
    }


  }
}
