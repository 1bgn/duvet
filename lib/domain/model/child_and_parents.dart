import 'package:xml/xml.dart';

class ChildAndParents{
  final XmlNode child;
  final List<XmlElement> parents;

  ChildAndParents({required this.child, required this.parents});

  @override
  String toString() {
    return "${child.text} ${parents.map((e) => e.name.qualified).join(" ")}";
  }
}