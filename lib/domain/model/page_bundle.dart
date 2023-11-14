import 'package:projects/domain/model/styled_element.dart';
import "package:collection/collection.dart";
class PageBundle{
  final List<StyledElement> currentElements;
   StyledElement get topElement => currentElements.first;
   StyledElement get bottomElement=> currentElements.last;
   final StyledElement? leftPartOfElement;
   final StyledElement? rightPartOfElement;
   final int lines;
  List< List<StyledElement>> groupByLines(){
    // currentElements.group;
    List< List<StyledElement>> lines = [];
    List<StyledElement> line = [];
    for (var element in currentElements) {
     line.add(element);
     if(element.isInline){

     }else{
       lines.add(line);
       line = [];
     }
    }
    return lines;
  }


  @override
  String toString() {
    return 'PageBundle{bottomElement: ${bottomElement.inlineSpan.toPlainText()}}';
  }

  PageBundle({required this.currentElements, required this.leftPartOfElement,required this.rightPartOfElement,required this.lines});



}