import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/hyphenator/hyphenator.dart';
import 'package:projects/domain/model/style_attributes.dart';
import 'package:projects/domain/model/styled_node.dart';
import 'dart:ui' as ui;
class StyledElement {
  final bool isInline;
  final StyledNode styledNode;
  final styleAttributes = StyleAttributes();
  InlineSpan? _inlineSpan;

  static final _hyphenator =  Hyphenator();
  int index = 0;
  final bool isSplitted;
  Uint8List? image;
  Size? imageSize;

  String? _text;


  @override
  String toString() {
    return 'StyledElement{id: ${styledNode.childAndParents.id},isSplitted: $isSplitted ,index: $index, parents: ${styledNode.childAndParents.parents.map((e) => e.qualifiedName).join(" ")},isInline: $isInline, text: ${text.length>100?text.substring(0,100):text} ${image!=null?",imageSize: $imageSize":""}';
  }

  StyledElement(
      {required this.isInline,
      required this.styledNode,
        this.image,
        this.imageSize,
      this.isSplitted = false});

  String get text {
    // _text ??=  _hyphenator.hyphenate(styledNode.childAndParents.child.text,);
    _text ??= styledNode.childAndParents.child.text;
    return _text!;
  }

  bool get isImage =>image!=null;
  InlineSpan get inlineSpan {
    if(_inlineSpan ==null){
      if(isImage){

      _inlineSpan = WidgetSpan(child: Image.memory(image!.buffer.asUint8List(),width: imageSize!.width,height: imageSize!.height,fit: BoxFit.fill,),           alignment: PlaceholderAlignment.middle,);
      }else{
        _inlineSpan = isInline
            ? TextSpan(
          text: text,
          style: styledNode.textStyle,
        )
            : TextSpan(text: "$text\n", style: styledNode.textStyle);
      }
    }
    return _inlineSpan!;
  }
  InlineSpan get textSpan {
    return isImage?WidgetSpan(child: Image.memory(image!.buffer.asUint8List(),width: imageSize!.width,height: imageSize!.height,fit: BoxFit.fill),alignment: PlaceholderAlignment.middle,):TextSpan(
      text: text,
      style: styledNode.textStyle,
    );

  }


}
