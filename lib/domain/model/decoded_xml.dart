import 'package:projects/domain/model/styled_element.dart';
import 'package:xml/xml.dart';

class DecodedXml{
  final List<StyledElement> elements;
  final Map<String,XmlNode> binaries;

  DecodedXml({required this.elements,required this.binaries});
}