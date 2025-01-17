import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:projects/domain/model/child_and_parents.dart';
import 'package:projects/domain/model/medium_metrics.dart';
import 'package:projects/domain/model/page_bundle.dart';
import 'package:projects/domain/model/styled_element.dart';
import 'dart:ui' as ui;
import 'package:projects/domain/model/styled_node.dart';

import 'package:xml/xml.dart';

class TextDecorator {
  static final inlineTags = [
    "a",
    "strong",
    "emphasis",
    "section-separator",
    "image",
    "sup"
  ];

  static final outlineTags = [
    "p",
  ];

  static InlineSpan fb2Decorate(
    ChildAndParents childAndParents,
  ) {
    final xmlNode = childAndParents.child;

    TextStyle textStyle = const TextStyle(inherit: true);
    for (var element in childAndParents.parents.reversed) {
      switch (element.qualifiedName) {
        case "book-title":
          {
            textStyle.merge(TextStyle(fontWeight: FontWeight.bold));
          }
        case "title":
          {
            textStyle = textStyle.merge(TextStyle(fontWeight: FontWeight.bold));
          }
        case "epigraph":
          {
            textStyle = textStyle.merge(TextStyle(fontStyle: FontStyle.italic));
          }
        case "p":
          {
            textStyle = textStyle.merge(TextStyle(fontSize: 14));
          }
        case "a":
          {
            textStyle = textStyle.merge(TextStyle(color: Colors.blueAccent));
          }
      }
    }

    return TextSpan(text: "${xmlNode.text}\n", style: textStyle);
  }

  static StyledNode createStyledNode(
    ChildAndParents childAndParents,
  ) {
    TextStyle textStyle = const TextStyle(inherit: true, color: Colors.black);
    TextAlign textAlign = TextAlign.justify;
    for (var element in childAndParents.parents.reversed) {
      switch (element.qualifiedName) {
        case "book-title":
          {
            textAlign = TextAlign.center;
            textStyle = textStyle
                .merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
          }
        case "text-author":
          {
            textStyle = textStyle.merge(TextStyle(fontSize: 14));
          }
        case "title":
          {
            textAlign = TextAlign.center;
            textStyle = textStyle
                .merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
          }
        case "subtitle":
          {
            textAlign = TextAlign.center;
          }
        case "epigraph":
          {
            textAlign = TextAlign.end;

            textStyle = textStyle.merge(TextStyle(fontStyle: FontStyle.italic));
          }
        case "emphasis":
          {
            textStyle = textStyle.merge(TextStyle(fontStyle: FontStyle.italic));
          }
        case "annotation":
          {
            textStyle = textStyle.merge(TextStyle(fontStyle: FontStyle.italic));
          }
        case "p":
          {
            textAlign =
                textAlign != TextAlign.justify ? textAlign : TextAlign.justify;
            textStyle = textStyle.merge(TextStyle());
          }
        case "a":
          {
            textStyle = textStyle.merge(TextStyle(color: Colors.blueAccent));
          }
        case "strong":
          {
            textStyle = textStyle.merge(TextStyle(fontWeight: FontWeight.bold));
          }
      }
    }

    return StyledNode(
      childAndParents: childAndParents,
      textStyle: textStyle,
      textAlign: textAlign,
    );
  }

  static List<StyledElement> layoutElements(
      double maxWidth, List<StyledElement> elements) {
    for (var element in elements) {
      TextPainter textPainter = TextPainter(
          text: element.inlineSpan,
          textDirection: TextDirection.ltr,
          textAlign: element.styledNode.textAlign);
      textPainter.layout(maxWidth: maxWidth);
      element.styleAttributes.height += textPainter.height;
      element.styleAttributes.width += textPainter.width;
    }
    return elements;
  }

  static bool isInOutlineBlock(
    List<XmlElement> parents1,
    List<XmlElement> parents2,
  ) {
    // int parentsCount = childAndParents1.parents.length>childAndParents2.parents.length?childAndParents1.parents.length:childAndParents2.parents.length;
    bool inOutlineBlock = false;
    var hp1 = parents1.map((e) => e.hashCode.toString()).toSet();
    var hp2 = parents2.map((e) => e.hashCode.toString()).toSet();
    var p1 = parents1.map((e) => e.qualifiedName).toSet();
    var p2 = parents2.map((e) => e.qualifiedName).toSet();
    final intersection = p1.intersection(p2);
    // print("$p1&&$p2");

    if (hp1.first == hp2.first && outlineTags.contains(intersection.first)) {
      inOutlineBlock = true;
    }

    return inOutlineBlock;
  }

  static List<StyledElement> combine(List<ChildAndParents> elements) {
    List<StyledElement> combinedElements = [];

    ChildAndParents? lastElement;

    for (int i = 0; i < elements.length; i++) {
      var currentElement = elements[i];
      if (lastElement == null) {
        combinedElements.add(isInlineNode(currentElement)
            ? createInlineElement(createStyledNode(currentElement))
            : createBlockElement(createStyledNode(currentElement)));
      } else {
        //lastElement != null
        if (isInlineNode(lastElement) && isInlineNode(currentElement)) {
          if (lastElement.id == currentElement.id) {
            combinedElements.removeLast();
            combinedElements
                .add(createInlineElement(createStyledNode(lastElement)));
            combinedElements
                .add(createInlineElement(createStyledNode(currentElement)));
          } else {
            combinedElements.removeLast();
            combinedElements
                .add(createBlockElement(createStyledNode(lastElement)));
            combinedElements
                .add(createBlockElement(createStyledNode(currentElement)));
          }
        } else if (isInlineNode(lastElement) && !isInlineNode(currentElement)) {
          //упростить
          if (lastElement.id == currentElement.id) {
            combinedElements.removeLast();
            combinedElements
                .add(createInlineElement(createStyledNode(lastElement)));
            combinedElements
                .add(createBlockElement(createStyledNode(currentElement)));
          } else {
            // print("RVSEVSV ${lastElement} ${currentElement}");

            combinedElements.removeLast();
            combinedElements
                .add(createBlockElement(createStyledNode(lastElement)));
            combinedElements
                .add(createBlockElement(createStyledNode(currentElement)));
          }
        } else if (!isInlineNode(lastElement) && isInlineNode(currentElement)) {
          if (lastElement.id == currentElement.id) {
            combinedElements.removeLast();
            combinedElements
                .add(createInlineElement(createStyledNode(lastElement)));
            combinedElements
                .add(createInlineElement(createStyledNode(currentElement)));
          } else {
            combinedElements
                .add(createBlockElement(createStyledNode(currentElement)));
          }
        } else if (!isInlineNode(lastElement) &&
            !isInlineNode(currentElement)) {
          combinedElements
              .add(createBlockElement(createStyledNode(currentElement)));
        }
      }
      lastElement = currentElement;
    }
    return combinedElements;
  }

  static MediumMetrics mediumMetrics(
      double devicePixelRatio,
      int countWordsInBook,
      double maxWidth,
      double maxHeight,
      List<StyledElement> elements,
      Map<String, XmlNode> binaries) {
    int testPages = 5;
    PageBundle? pageBundle;
    int lines = 0;
    int words = 0;
    for (int i = 0; i < testPages; i++) {
      pageBundle = getNextPageBundle(
          devicePixelRatio, maxWidth, maxHeight, elements, binaries);
      lines += pageBundle.lines;
      words += pageBundle.currentElements
          .map((e) => e.text.split(" ").length)
          .fold(0, (previousValue, element) => previousValue + element);
      elements = skipElement(
          pageBundle.rightPartOfElement?.styledNode.childAndParents.id ??
              pageBundle.currentElements.last.styledNode.childAndParents.id,
          elements);
    }
    words = (words / testPages).truncate();

    return MediumMetrics(
        words: words,
        linesOnPage: (lines / testPages).truncate(),
        pages: (countWordsInBook / words).truncate());
  }

  static List<InlineSpan> getPage(
      double maxWidth, double maxHeight, List<StyledElement> elements) {
    List<InlineSpan> spans = [];
    TextAlign textAlign = TextAlign.justify;
    for (var element in elements) {
      TextPainter textPainter = TextPainter(
          text: TextSpan(children: spans.map((e) => e).toList()),
          textDirection: TextDirection.ltr);
      textPainter.layout(
        maxWidth: maxWidth,
      );

      if (textPainter.height > maxHeight) {
        final removedElement = spans.removeLast();
        TextPainter removedTextPainter =
            TextPainter(text: removedElement, textDirection: TextDirection.ltr);
        removedTextPainter.layout(maxWidth: maxWidth);
        final lines = removedTextPainter.computeLineMetrics();

        final freeHeight =
            maxHeight - (textPainter.height - removedTextPainter.height);

        final freeLines =
            (freeHeight / removedTextPainter.preferredLineHeight).truncate();

        final charPos = removedTextPainter
            .getPositionForOffset(
                Offset(maxWidth, lines[freeLines].height * freeLines - 1))
            .offset;
        // print(
        //     "res  $freeLines ${removedElement.toPlainText().substring(0, charPos)}");
        spans.add(TextSpan(
            text: removedElement.toPlainText().substring(0, charPos),
            style: removedElement.style));
        break;
      } else if (textPainter.height == maxHeight) {
        break;
      }
      spans.add(element.inlineSpan);
    }
    return spans;
  }

  static List<StyledElement> skipElement(
      int elementId, List<StyledElement> elements) {
    // print("skipElement()");

    final indexWhere = elements.indexWhere(
            (element) => element.styledNode.childAndParents.id == elementId) +
        1;
    return elements.skip(indexWhere).toList();
  }

  static List<StyledElement> takeElement(
      int elementId, List<StyledElement> elements) {
    final indexWhere = elements.indexWhere(
        (element) => element.styledNode.childAndParents.id == elementId);

    final res = elements.sublist(0, indexWhere);

    return res;
  }

  static List<StyledElement> takeElementTo(
      int index, List<StyledElement> elements) {
    final indexWhere =
        elements.indexWhere((element) => element.index > index) - 1;
    final res = elements.sublist(0, indexWhere);
    return res;
  }

  static List<StyledElement> skipElementTo(
      int index, List<StyledElement> elements,
      {bool indexContains = false}) {
    if (indexContains) {
      return elements.skipWhile((element) => element.index < index).toList();
    } else {
      return elements.skipWhile((element) => element.index <= index).toList();
    }
  }

  static void insertFragment(StyledElement leftFragment,
      StyledElement rightFragment, List<StyledElement> elements) {
    int indWhere =
        elements.indexWhere((element) => element.index == leftFragment.index);
    // print("$leftFragment");
    if (indWhere != -1 && !elements[indWhere].isSplitted) {
      elements.removeAt(indWhere);
      elements.insert(indWhere, rightFragment);
      elements.insert(indWhere, leftFragment);
    }
  }

  static StyledElement buildImage(
      StyledElement styledElement, Uint8List bytes, Size imageSize) {
    final element = styledElement.isInline
        ? createInlineElement(styledElement.styledNode,
            image: bytes, imageSize: imageSize)
        : createBlockElement(styledElement.styledNode,
            image: bytes, imageSize: imageSize);
    element.index = styledElement.index;

    return element;
  }

  // static StyledElement resizeImage(StyledElement styledElement,Size newSize){
  //   assert(styledElement.isImage);
  //   return buildImage(styledElement, styledElement.image!, newSize);
  // }

  static PageBundle getNextPageBundle(
      double devicePixelRatio,
      double maxWidth,
      double maxHeight,
      List<StyledElement> elements,
      Map<String, XmlNode> binaries) {
    List<StyledElement> spans = [];
    // elements = elements.skip(40).toList();
    int removedLines = 0;
    List<StyledElement>? leftAndRightParts;
    TextPainter? textPainter;
    double lastCurrentFreeHeight = 0;
    for (var element in elements) {
      if (element.styledNode.childAndParents.parents.first.qualifiedName ==
          "section-separator") {
        maxHeight = 0;
        spans.add(element);
        break;
      }
      if (element.styledNode.childAndParents.parents.first.qualifiedName ==
          "image") {
        final imageId = element.styledNode.childAndParents.child
            .getAttribute("l:href")!
            .replaceFirst("#", "");
        final bytes = base64Decode(binaries[imageId]!.text);
        final decodedImage = decodeImage(bytes)!;
        final imageWidth = decodedImage.width / devicePixelRatio;
        final imageHeight = decodedImage.height / devicePixelRatio;

        // if(height>maxHeight){
        //   height = maxHeight;
        // }

        element = buildImage(element, bytes, Size(imageWidth, imageHeight));

        // print(
        //     "deviceRatio($devicePixelRatio),imageHeight($imageHeight),buildImage(${Size(width, height).height}, maxHeight:${maxHeight})");
      }
      textPainter = TextPainter(
          text: TextSpan(
            children: spans.map((e) => e.inlineSpan).toList(),
          ),
          textDirection: TextDirection.ltr);

      final List<PlaceholderDimensions> placeholderDimensions = [];
      for (var element in spans) {
        if (element.isImage) {
          // final freeHeight =
          //      maxHeight - ((textPainter.height) );
          var size = element.imageSize!;
          var width = size.width;
          var height = size.height;
          // final scaleHeight =
          // // if(height>lastCurrentFreeHeight){
          // //
          // //  break;
          // // }
          size = Size(width, height);
          element.imageSize = size;
          placeholderDimensions.add(PlaceholderDimensions(
            size: size,
            alignment: PlaceholderAlignment.middle,
          ));
        }
      }

      textPainter.setPlaceholderDimensions(
        placeholderDimensions,
      );
      textPainter.layout(
        maxWidth: maxWidth,

      );
      print(
          "next cycle ${textPainter.height} maxHeight: $maxHeight len:${spans.map((e) => e.inlineSpan)} element: $element");

      if (textPainter.height > maxHeight) {
        final removedElement = spans.removeLast();

        if (removedElement.isImage) {
          print("removedElement ${textPainter.height} $maxHeight");
          break;
          // continue;
        }
        TextPainter removedTextPainter = TextPainter(
            text: removedElement.inlineSpan,
            textAlign: removedElement.styledNode.textAlign,
            textDirection: TextDirection.ltr);

        removedTextPainter.layout(maxWidth: maxWidth);
        // print("removedElement1 textPainter.height: ${textPainter.height} maxHeight:$maxHeight removedTextPainter.height: ${removedTextPainter.height} ${removedElement}");
        // print("removedElement2  ${spans}");
        final lines = removedTextPainter.computeLineMetrics();
        final freeHeight =
            maxHeight - ((textPainter.height) - removedTextPainter.height);

        double lineHeight = -1;
        for (var element in lines) {
          if (element.height > lineHeight) {
            lineHeight = element.height;
          }
        }
        final freeLines = (freeHeight / lineHeight).truncate();
        removedLines = lines.length - freeLines;

        final charPos = removedTextPainter
            .getPositionForOffset(Offset(maxWidth, lineHeight * freeLines - 1))
            .offset;
        // print("res ${lines.length} $freeLines  ${removedElement.text.substring(charPos)}");
        // print("FREE LINES: $freeLines ${removedElement.isInline} ${removedElement.text}");
        // if(charPos!=removedElement.text.length){
        //   leftAndRightParts = splitToLeftAndRight(charPos,removedElement);
        //   spans.add(leftAndRightParts[0]);
        // }else{
        //   spans.add(removedElement);
        // }

        leftAndRightParts = splitToLeftAndRight(charPos, removedElement);
        spans.add(leftAndRightParts[0]);
        // print("res  $freeLines ${removedElement.text.substring(0, charPos)}");

        break;
      } else if (textPainter.height == maxHeight) {
        break;
      }
      lastCurrentFreeHeight = textPainter.height;

      spans.add(element);
    }
    final bundle = PageBundle(
        currentElements: spans,
        leftPartOfElement: leftAndRightParts?[0],
        rightPartOfElement: leftAndRightParts?[1],
        lines: textPainter!.computeLineMetrics().length - removedLines);
    return bundle;
  }

  static PageBundle getPreviousPageBundle(
      double devicePixelRatio,
      double maxWidth,
      double maxHeight,
      List<StyledElement> elements,
      Map<String, XmlNode> binaries) {
    if (elements.isEmpty) {
      return PageBundle(
          currentElements: [],
          leftPartOfElement: null,
          rightPartOfElement: null,
          lines: 0);
    }
    List<StyledElement> spans = [];

    List<StyledElement>? leftAndRightParts;
    TextPainter? textPainter;

    for (var element in elements.reversed) {
      if (element.styledNode.childAndParents.parents.first.qualifiedName ==
          "section-separator") {
        maxHeight = 0;
        spans.add(element);
        break;
      }
      if (element.styledNode.childAndParents.parents.first.qualifiedName ==
          "image") {
        final imageId = element.styledNode.childAndParents.child
            .getAttribute("l:href")!
            .replaceFirst("#", "");
        final bytes = base64Decode(binaries[imageId]!.text);
        final decodedImage = decodeImage(bytes)!;
        final width = decodedImage.width.toDouble() / devicePixelRatio;

        final height = decodedImage.height.toDouble() / devicePixelRatio;
        element = buildImage(element, bytes, Size(width, height));

        // spans.add(element);
      }
      textPainter = TextPainter(
          text: TextSpan(
              children: spans.reversed.map((e) => e.inlineSpan).toList()),
          textDirection: TextDirection.ltr);
      final List<PlaceholderDimensions> placeholderDimensions = [];
      for (var element in spans) {
        if (element.isImage) {
          final size = element.imageSize!;
          placeholderDimensions.add(PlaceholderDimensions(
            size: size,
            alignment: PlaceholderAlignment.middle,
          ));
        }
      }

      textPainter.setPlaceholderDimensions(placeholderDimensions);
      textPainter.layout(maxWidth: maxWidth);
      if (textPainter.height > maxHeight) {
        final removedElement = spans.removeLast();

        // print("REMOVED1 ${textPainter.text!.toPlainText()} ${textPainter.height} $maxHeight");
        // print("REMOVED2 ${textPainter.height} $maxHeight");

        if (removedElement.isSplitted && false) {
          spans.add(removedElement);
        } else {
          // print("SPLIT $removedElement");
          TextPainter removedTextPainter = TextPainter(
              text: removedElement.inlineSpan,
              textDirection: TextDirection.ltr);
          // if (removedElement.isImage) {
          //   // final freeHeight =  maxHeight - ((textPainter.height) - removedElement.imageSize!.height);
          //   // final resizedImage = resizeImage(removedElement, Size(removedElement.imageSize!.width, freeHeight));
          //   // spans.add(resizedImage);
          //   // continue;
          //   break;
          // }
          removedTextPainter.layout(maxWidth: maxWidth);
          final lines = removedTextPainter.computeLineMetrics();

          final freeHeight =
              maxHeight - (textPainter.height - removedTextPainter.height);
          print(removedTextPainter.preferredLineHeight);
          double lineHeight = -1;
          for (var element in lines) {
            if (element.height > lineHeight) {
              lineHeight = element.height;
            }
          }
          final freeLines = (freeHeight / lineHeight).truncate();

          // print("free height $freeHeight,free lines $freeLines");

          final charPos = removedTextPainter
              .getPositionForOffset(Offset(
                  0,
                  removedTextPainter.preferredLineHeight *
                          (lines.length - freeLines) -
                      1))
              .offset;
          // print("res ${lines.length} $freeLines  ${removedElement.text.substring(charPos)}");
          // print("res  $freeLines ${spans.last.text} ");

          leftAndRightParts = splitToLeftAndRight(charPos, removedElement);
          spans.add(leftAndRightParts[1]);
        }
        break;
      } else if (textPainter.height == maxHeight) {
        print("=====");
        break;
      }

      spans.add(element);
    }
    // if (textPainter!.height < maxHeight) {
    //
    //   // spans.add(leftAndRightParts[1]);
    //
    //
    //
    // }
    final bundle = PageBundle(
        currentElements: spans.reversed.toList(),
        leftPartOfElement: leftAndRightParts?[1],
        rightPartOfElement: leftAndRightParts?[0],
        lines: textPainter!.computeLineMetrics().length);
    return bundle;
  }

  static int pagesBefore(
      int index, List<StyledElement> elements, MediumMetrics mediumMetrics) {
    final elementsBefore = takeElementTo(index, elements);
    int wordsBefore = 0;
    for (var element in elementsBefore) {
      wordsBefore += element.text.length;
    }
    return (wordsBefore / mediumMetrics.words).floor();
  }

  static List<StyledElement> splitToLeftAndRight(
      int offset, StyledElement styledElement) {
    final leftText = styledElement.text.substring(0, offset);
    final rightText = styledElement.text.substring(offset);
    // print("RIGHTTEXT ${rightText.isEmpty}");
    final leftStyledElement = StyledElement(
        isSplitted: true,
        isInline: styledElement.isInline || leftText.trim().isEmpty,
        styledNode: StyledNode(
            textAlign: styledElement.styledNode.textAlign,
            childAndParents: ChildAndParents(
                id: styledElement.styledNode.childAndParents.id,
                child: XmlElement(
                    getLineNodeName(styledElement.styledNode.childAndParents),
                    [],
                    [
                      XmlText(
                        leftText,
                      )
                    ]),
                parents: styledElement.styledNode.childAndParents.parents),
            textStyle: styledElement.styledNode.textStyle));
    leftStyledElement.index = styledElement.index;
    final rightStyledElement = StyledElement(
        isSplitted: true,
        isInline: styledElement.isInline || rightText.trim().isEmpty,
        styledNode: StyledNode(
            textAlign: styledElement.styledNode.textAlign,
            childAndParents: ChildAndParents(
                id: styledElement.styledNode.childAndParents.id,
                child: XmlElement(
                    getLineNodeName(styledElement.styledNode.childAndParents),
                    [],
                    [
                      XmlText(
                        rightText,
                      )
                    ]),
                parents: styledElement.styledNode.childAndParents.parents),
            textStyle: styledElement.styledNode.textStyle));

    rightStyledElement.index = styledElement.index + offset;
    return [leftStyledElement, rightStyledElement];
  }

  static double _lineWidth(List<StyledElement> line) {
    double width = 0;
    for (var element in line) {
      width += element.styleAttributes.width;
    }

    return width;
  }

  static double _lineHeight(List<StyledElement> line) {
    double height = -1;
    for (var element in line) {
      if (height < element.styleAttributes.height) {
        height = element.styleAttributes.height;
      }
    }
    return height;
  }

  static List<List<StyledElement>> linizer(
      double maxWidth, List<StyledElement> elements) {
    List<List<StyledElement>> lines = [];
    List<StyledElement> line = [];
    double lineWidth = 0;
    for (var element in elements) {
      lineWidth += element.styleAttributes.width;

      if (lineWidth > maxWidth) {
        line.add(element);
        lines.add(line);
        line = [];
        lineWidth = 0;
      } else {
        line.add(element);
      }
    }
    return lines;
  }

  static List<List<List<StyledElement>>> paginator(
      double maxWidth, double maxHeight, List<List<StyledElement>> lines) {
    List<List<List<StyledElement>>> pages = [];
    List<List<StyledElement>> page = [];
    double linesHeight = 0;
    for (var element in lines) {
      // print("BBBB ${element.length}");

      linesHeight += _lineHeight(element);

      if (linesHeight < maxHeight - linesHeight) {
        page.add(element);
      } else {
        page.add(element);
        pages.add(page);
        page = [];
        linesHeight = 0;
      }
    }
    return pages;
  }

  static List<List<StyledElement>> normalizer(
      List<List<List<StyledElement>>> elements) {
    return elements.expand((element) => element).toList();
  }

  static StyledElement createInlineElement(StyledNode styledNode,
      {Uint8List? image, Size? imageSize}) {
    return StyledElement(
        isInline: true,
        styledNode: styledNode,
        image: image,
        imageSize: imageSize);
  }

  static StyledElement createBlockElement(StyledNode styledNode,
      {Uint8List? image, Size? imageSize}) {
    return StyledElement(
        isInline: false,
        styledNode: styledNode,
        image: image,
        imageSize: imageSize);
  }

  static bool isInlineNode(ChildAndParents element) {
    return inlineTags.contains(element.parents.first.name.qualified);
  }

  static XmlName getLineNodeName(ChildAndParents element1) {
    return XmlName(element1.parents.first.name.qualified);
  }
}
