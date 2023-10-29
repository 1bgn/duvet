
import 'package:projects/domain/model/child_and_parents.dart';
import 'package:xml/xml.dart';

void xmlSplitter(
    {String xmlText = '''<?xml version="1.0"?>
    <bookshelf>
      <book>
        <p lang="en">Книга1</p>
        <a>29.99</a>
      </book>
      <book>
        <title lang="en">Книга2</title>
        <price>39.95</price>
      </book>
      <price>132.00</price>
    </bookshelf>'''}){
  final document = XmlDocument.parse(xmlText);
  final result = split(document.rootElement);


}
List<ChildAndParents> split(XmlNode xmlElement){
  // if(xmlElement.nodeType == XmlNodeType.ELEMENT){
  //   xmlElement = xmlElement as XmlElement;
  //   final nodes = xmlElement.children.map((p0) => split(p0)).toList();
  // }else if(xmlElement.nodeType == XmlNodeType.TEXT){
  //   final parent = xmlElement.parentElement!;
  //
  //   switch(parent.name.qualified){
  //     case "bookshelf":{
  //       if(xmlElement.firstChild!=null){
  //         print(xmlElement.firstChild!.nodeType);
  //       }
  //     }
  //   }
  //
  // }
  final descendants =  xmlElement.descendantElements;
  List<ChildAndParents> elements = [];
  for (var element in descendants) {
    if(element.firstChild!=null && element.firstChild!.nodeType == XmlNodeType.TEXT && element.firstChild!.text.trim().isNotEmpty){
      elements.add(ChildAndParents(child: element.firstChild!, parents: parents(element.firstChild!)));
 

    }
  }
 // print(combine(elements));
 // print( xmlElement.descendantElements);
 // print( xmlElement.descendants.length);

  return combine(elements);
}
List<ChildAndParents> combine(List<ChildAndParents> elements){
  List<ChildAndParents> combinedElements = [];
  for(int i =0;i<elements.length-1;i++){
    final element1 =elements[i];
    final element2 =elements[i+1];
    // print(element1.toString() +" "+ element2.toString());
    if(isNeedCombine(element1, element2) && isRelatives(element1, element2)){
      combinedElements.add(mergeChild(element1, element2));
    }else{
      combinedElements.add(element2);
    }
  }
  return combinedElements;
}
bool isNeedCombine(ChildAndParents  element1,ChildAndParents element2){
  final inlineTags = ["a"];
  if(inlineTags.contains(element1.parents.first.name.qualified) || inlineTags.contains(element2.parents.first.name.qualified)){
    return true;
  }
  return false;
}

bool isRelatives(ChildAndParents element1,ChildAndParents element2, ){
  return element1.parents.skip(1).map((e) => e.qualifiedName).toString() == element2.parents.skip(1).map((e) => e.qualifiedName).toString();
}
ChildAndParents mergeChild(ChildAndParents element1,ChildAndParents element2){
  return ChildAndParents(child: XmlText("${element1.child.text} ${element2.child.text}"), parents: element1.parents.skip(1).toList());
}

List<XmlElement> parents(XmlNode xmlNode){
  List<XmlElement> p = [];
  if(xmlNode.parentElement!=null){
   p.add( xmlNode.parentElement!);
   p.addAll(parents(xmlNode.parent!));
   return p;
  }
  return p;
}
void main(){
  xmlSplitter();
}