import 'package:flutter/cupertino.dart';
import 'package:projects/domain/hyphenator/hyphenator.dart';
import 'package:projects/domain/model/style_attributes.dart';
import 'package:projects/domain/model/styled_node.dart';

class StyledElement{
  final bool isInline;
  final StyledNode styledNode;
  final styleAttributes =StyleAttributes();
  InlineSpan? _inlineSpan;
  static final _hyphenator =  Hyphenator();
  String? _text;
  @override
  String toString() {
    return 'StyledElement{_inlineSpan: $_inlineSpan}';
  }

  StyledElement({required this.isInline, required this.styledNode});

  String get text {
   _text ??=  _hyphenator.hyphenate(styledNode.childAndParents.child.text);
    return _text!;
  }

  InlineSpan get inlineSpan {
   _inlineSpan ??= isInline?TextSpan(text: text,style: styledNode.textStyle,):TextSpan(text:"$text\n",style: styledNode.textStyle);
   return _inlineSpan!;
  }

}