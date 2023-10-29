

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class DecoratedNode{
  final XmlElement? xmlNode;
  final List<DecoratedNode> children;
  final TextStyle? textStyle;

  DecoratedNode({ this.xmlNode, this.children =const [],this.textStyle});
}