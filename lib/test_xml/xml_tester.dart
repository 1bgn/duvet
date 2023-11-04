import 'dart:math';

import 'package:collection/collection.dart';
import 'package:projects/domain/model/child_and_parents.dart';
import 'package:xml/xml.dart';

void main() {
  xmlSplitter();
}

void xmlSplitter(
    {String xmlText = '''<?xml version="1.0"?>
    <bookshelf>
<p>До сих пор не могу решить, понимал ли Паг на самом деле, что бормочет. Может <a type="note" l:href="#n_4">[4]</a> , что те начали ему мерещиться в реале? Может быть…<a type="note" l:href="#n_4">[5]</a></p>
<p>Lorem is ipsum</p>
    </bookshelf>'''}) {
  final document = XmlDocument.parse(xmlText);
  final result = combine(split(document.rootElement));
  print(result);
}

final inlineTags = [
  "a",
];

List<ChildAndParents> split(XmlNode xmlElement, {int? ID}) {
  final descendants =
      xmlElement.children.where((element) => element.text.trim().isNotEmpty);
  List<ChildAndParents> elements = [];
  // print(descendants);
  int id = ID ?? Random().nextInt(1000);
  XmlNode? lastElement = null;
  for (var element in descendants) {
    if (element.nodeType == XmlNodeType.TEXT &&
        element.text.trim().isNotEmpty) {
      elements.add(
          ChildAndParents(child: element, parents: parents(element), id: id));
    } else if (element.nodeType == XmlNodeType.ELEMENT) {
      if (lastElement?.nodeType == XmlNodeType.TEXT) {
        elements.addAll(split(element, ID: id));
      } else {
        elements.addAll(split(
          element,
        ));
      }
    }
    lastElement = element;
  }

  return elements;
}

// List<ChildAndParents> combine2(List<ChildAndParents> elements) {
//   return elements
//       .groupListsBy((e) => e.id)
//       .values
//   .map((e) => e.length>1?e.fold(e.first, mergeChild2):e)
//       .expand((element) => element)
//       .toList();
// }

List<ChildAndParents> combine(List<ChildAndParents> elements) {
  List<ChildAndParents> combinedElements = [];
  int lastId = -1;
  for (int i = 0; i < elements.length; i++) {
    final element1 = elements[i];
    if (combinedElements.isNotEmpty && element1.id == lastId) {
      final deletedElement = combinedElements.removeLast();
      combinedElements.add(mergeChild2(deletedElement, element1));
    } else {
      combinedElements.add(element1);
      lastId = -1;
    }

    lastId = element1.id;
  }

  return combinedElements;
}

bool isInlineNode(ChildAndParents element) {
  return inlineTags.contains(element.parents.first.name.qualified);
}

XmlName getLineNodeName(ChildAndParents element1, ChildAndParents element2) {
  return XmlName(isInlineNode(element1)
      ? element2.parents.first.name.qualified
      : element1.parents.first.name.qualified);
}

bool isNeedCombine(ChildAndParents element1, ChildAndParents element2) {
  return isInlineNode(element1) || isInlineNode(element2);
}

bool isRelatives(
  ChildAndParents element1,
  ChildAndParents element2,
) {
  final parents1 = element1.parents.skip(1).map((e) => e.qualifiedName).join();
  final parents2 = element2.parents.skip(1).map((e) => e.qualifiedName).join();
  return parents1.contains(parents2) || parents2.contains(parents1);
}



ChildAndParents mergeChild2(
    ChildAndParents element1, ChildAndParents element2) {
  return ChildAndParents(
      id: element1.id,
      child: XmlElement(XmlName("type"), [], [
        XmlText(
          "${element1.child.text}${element2.child.text}",
        )
      ]),
      parents: element1.parents.skip(1).toList());
}

List<XmlElement> parents(XmlNode xmlNode) {
  List<XmlElement> p = [];
  if (xmlNode.parentElement != null) {
    p.add(xmlNode.parentElement!);
    p.addAll(parents(xmlNode.parent!));
    return p;
  }
  return p;
}
