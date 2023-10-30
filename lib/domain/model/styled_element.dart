import 'package:flutter/cupertino.dart';
import 'package:projects/domain/model/style_attributes.dart';
import 'package:projects/domain/model/styled_node.dart';

class StyledElement{
  final bool isInline;
  final StyledNode styledNode;
  final styleAttributes =StyleAttributes();
  InlineSpan? _inlineSpan;

  StyledElement({required this.isInline, required this.styledNode});
  InlineSpan get inlineSpan {
   _inlineSpan ??= isInline?TextSpan(text: styledNode.childAndParents.child.text,style: styledNode.textStyle):TextSpan(text: "${styledNode.childAndParents.child.text}\n",style: styledNode.textStyle);
   return _inlineSpan!;
  }
}