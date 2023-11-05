import 'package:flutter/cupertino.dart';
import 'package:projects/domain/hyphenator/hyphenator.dart';
import 'package:projects/domain/model/hyphenated_text.dart';

import '../../domain/model/styled_element.dart';

class HyphenatedTextComponent extends StatefulWidget{
  final HyphenatedText hyphenatedText;

  const HyphenatedTextComponent({super.key, required this.hyphenatedText});

  @override
  State<HyphenatedTextComponent> createState() => _HyphenatedTextComponentState();
}

class _HyphenatedTextComponentState extends State<HyphenatedTextComponent> {


  @override
  Widget build(BuildContext context) {
    return RichText(text: widget.hyphenatedText.text,);
  }
}