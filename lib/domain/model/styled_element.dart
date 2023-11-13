import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/hyphenator/hyphenator.dart';
import 'package:projects/domain/model/style_attributes.dart';
import 'package:projects/domain/model/styled_node.dart';

class StyledElement {
  final bool isInline;
  final StyledNode styledNode;
  final styleAttributes = StyleAttributes();
  InlineSpan? _inlineSpan;

  // static final _hyphenator =  Hyphenator();
  int index = 0;
  final bool isSplitted;

  String? _text;

  @override
  String toString() {
    return 'StyledElement{id: ${styledNode.childAndParents.id},isSplitted: $isSplitted ,index: $index, parents: ${styledNode.childAndParents.parents.map((e) => e.qualifiedName).join(" ")},isInline: $isInline, text: ${text.length>100?text.substring(0,100):text}}';
  }

  StyledElement(
      {required this.isInline,
      required this.styledNode,
      this.isSplitted = false});

  String get text {
    // _text ??=  _hyphenator.hyphenate(styledNode.childAndParents.child.text);
    _text ??= styledNode.childAndParents.child.text;
    return _text!;
  }

  InlineSpan get inlineSpan {
    _inlineSpan ??= isInline
        ? TextSpan(
            text: text,
            style: styledNode.textStyle,
          )
        : TextSpan(text: "$text\n", style: styledNode.textStyle);
    return _inlineSpan!;
  }
  InlineSpan get textSpan {
    return TextSpan(
      text: text,
      style: styledNode.textStyle,
    );

  }

  InlineSpan get widgetInlineSpan {
    if(isInline ){
      return  WidgetSpan(
          child: RichText(
              text: TextSpan(
                text: text,
                style: styledNode.textStyle,
              )));
    }else{
      return  WidgetSpan(

          child: RichText(
            text: TextSpan(text: "$text\n", style: styledNode.textStyle,children: []),
          ));
      return  WidgetSpan(
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(text: "$text", style: styledNode.textStyle,children: []),
                ),
              ),
            ],
          ));
    }


  }
}
