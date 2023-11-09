import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/domain/model/book_data.dart';
import 'package:projects/domain/model/page_bundle.dart';
import 'package:projects/domain/text_decorator/text_decorator.dart';

import '../../domain/model/styled_element.dart';

class Pager extends StatefulWidget {
  final BookData bookData;

  const Pager({super.key, required this.bookData});

  @override
  State<Pager> createState() => _PagerState();
}

class _PagerState extends State<Pager> {
  BookData get bookData => widget.bookData;
  int lastIndex = 0;
  late PageController pageController = PageController(initialPage: lastIndex);
  int isNext = 0;
  PageBundle? currentPage;
  static int globalIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = TextDecorator.mediumMetrics(bookData.countWordsInBook,
        bookData.size.maxWidth, bookData.size.maxHeight, bookData.elements);
    print("${metrics}");

    return PageView.builder(
      onPageChanged: (index){
        lastIndex = index;
      },
      itemBuilder: (BuildContext context, int index) {

        if(lastIndex<index){
          //next page
          isNext = 1;
        }else if(lastIndex == index){
          //update current page
          isNext = 0;
        }else{
          //preview page
          isNext = -1;
        }

        if(isNext == 0 && currentPage == null){
          currentPage =  TextDecorator.getNextPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, bookData.elements);
          if(currentPage?.rightPartOfElement!=null){
            TextDecorator.insertFragment(currentPage!.leftPartOfElement!,currentPage!.rightPartOfElement!, bookData.elements);

          }
          globalIndex = currentPage!.currentElements.last.index;

        }else if (isNext == 1){
          // final nextElements = TextDecorator.skipElement(currentPage!.bottomElement.styledNode.childAndParents.id, bookData.elements);
          // if(currentPage?.rightPartOfElement!=null){
          //   TextDecorator.insertFragment(currentPage!.rightPartOfElement!, bookData.elements);
          //
          // }
          final nextElements = TextDecorator.skipElementTo(globalIndex, bookData.elements);

          // if(currentPage!.rightPartOfElement!=null){
          //   nextElements.insert(0, currentPage!.rightPartOfElement!);
          // }

          currentPage = TextDecorator.getNextPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, nextElements);
          print("currentPage!.currentElements $globalIndex ${currentPage!.currentElements.first} ${currentPage!.currentElements.last}");

          if(currentPage?.rightPartOfElement!=null){
            // print("LAST nnextElements ${currentPage?.rightPartOfElement}");

            TextDecorator.insertFragment(currentPage!.leftPartOfElement!,currentPage!.rightPartOfElement!, bookData.elements);
            print("currentPage!.rightPartOfElement! ${currentPage!.rightPartOfElement!}");

          }

          globalIndex = currentPage!.bottomElement.index;
          // print("globalIndex ${globalIndex} ${currentPage!.bottomElement}");

        }else if(isNext == -1){
          // final previousElements = TextDecorator.takeElement(currentPage!.topElement.styledNode.childAndParents.id, bookData.elements);
          globalIndex = currentPage!.topElement.index;
          final previousElements = TextDecorator.takeElementTo(globalIndex, bookData.elements);
          // print('previousElementst: ${previousElements.first} ${previousElements.last}');
          print("getPreviousPageBundle $globalIndex ${previousElements.first} ${previousElements[previousElements.length-2]}");

          for (var element in  bookData.elements) {
            if(element.index<=5352)
              print("ELEMENT: $element");
          }
          // print('firstElement: ${previousElements.first.text}');
          // print('lastElement: ${previousElements.last.text}');
          // print('currentPage!.topElement: ${currentPage!.topElement.text}');

          // if(prevBundle?.leftPartOfElement!=null){
          //   previousElements.add(prevBundle!.leftPartOfElement!);
          //   print('prevBundle!.leftPartOfElement: ${prevBundle?.leftPartOfElement?.text}');
          // }

          currentPage = TextDecorator.getPreviousPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, previousElements);

          globalIndex = currentPage!.bottomElement.index;

          // print('prevBundle!.rightPartOfElement: ${prevBundle?.rightPartOfElement?.text}');

          // if(currentPage!.rightPartOfElement!=null){
          //   previousElements.add( currentPage!.rightPartOfElement!);
          //   print('bottomElement: ${currentPage!.bottomElement.inlineSpan.toPlainText()}');
          //   print('rightPartOfElement: ${ currentPage!.rightPartOfElement!.inlineSpan.toPlainText()}');
          //   print('leftPartOfElement: ${ currentPage!.leftPartOfElement!.inlineSpan.toPlainText()}');
          //
          // }

        }

        print("globalIndex: $globalIndex");

        return RichText(
text:
          TextSpan(
              children: currentPage!.currentElements
                  .map((e) => e.inlineSpan)
                  .toList(),
              style: TextStyle(color: Colors.black)),

        );
      },
      controller: pageController,
      itemCount: metrics.pages,
    );
  }
}
