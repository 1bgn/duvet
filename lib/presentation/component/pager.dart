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
        }else if (isNext == 1){
          final nextElements = TextDecorator.skipElement(currentPage!.bottomElement.styledNode.childAndParents.id, bookData.elements);
          if(currentPage!.rightPartOfElement!=null){
            nextElements.insert(0, currentPage!.rightPartOfElement!);
          }
          final prevBundle = currentPage;
          currentPage = TextDecorator.getNextPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, nextElements);
          currentPage!.prevBundle = prevBundle;
        }else if(isNext == -1){
          final previousElements = TextDecorator.takeElement(currentPage!.topElement.styledNode.childAndParents.id, bookData.elements);

          print('firstElement: ${previousElements.first.text}');
          print('lastElement: ${previousElements.last.text}');
          final prevBundle = currentPage!.prevBundle;
          if(prevBundle?.leftPartOfElement!=null){
            previousElements.add(prevBundle!.leftPartOfElement!);
            print('prevBundle!.leftPartOfElement: ${prevBundle?.leftPartOfElement?.text}');
          }

          currentPage = TextDecorator.getPreviousPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, previousElements);
          currentPage!.prevBundle = prevBundle;
          // print('prevBundle!.rightPartOfElement: ${prevBundle?.rightPartOfElement?.text}');

          // if(currentPage!.rightPartOfElement!=null){
          //   previousElements.add( currentPage!.rightPartOfElement!);
          //   print('bottomElement: ${currentPage!.bottomElement.inlineSpan.toPlainText()}');
          //   print('rightPartOfElement: ${ currentPage!.rightPartOfElement!.inlineSpan.toPlainText()}');
          //   print('leftPartOfElement: ${ currentPage!.leftPartOfElement!.inlineSpan.toPlainText()}');
          //
          // }

        }


        return RichText(
          text: TextSpan(
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
