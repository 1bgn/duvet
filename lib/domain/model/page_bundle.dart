import 'package:projects/domain/model/styled_element.dart';

class PageBundle{
  final List<StyledElement> currentElements;
  // final List<StyledElement> nextElements ;
  // final List<StyledElement> previousElements;
   StyledElement get topElement => currentElements.first;
   StyledElement get bottomElement=> currentElements.last;
   final StyledElement? leftPartOfElement;
   final StyledElement? rightPartOfElement;
   final int lines;
   PageBundle? prevBundle;

  @override
  String toString() {
    return 'PageBundle{bottomElement: ${bottomElement.inlineSpan.toPlainText()}}';
  }

  PageBundle({required this.currentElements, required this.leftPartOfElement,required this.rightPartOfElement,required this.lines});



}