import 'dart:async';


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
  double lastIndex = 0;
  int initialPage = 0;
  late PageController pageController = PageController(initialPage: initialPage);
  int currentDirection = 0;
  PageBundle? currentPage;
  PageBundle? prevPage;
  PageBundle? nextPage;
  static int globalIndex = 0;
  Completer _completer = Completer();
  final Map<int, PageBundle> pages = {};
  Orientation? lastOrientation = Orientation.portrait;

  @override
  void initState() {
    double lastIndexPos = 0;
    initCurrentPage(initialPage, true);
    // Future.delayed(Duration(seconds: 1)).then((value) {
    //   Stream.periodic(Duration(milliseconds: 50)).listen((event) {
    //     if(pageController.page != 1156){
    //       pageController.nextPage(duration: Duration(milliseconds: 1), curve: Curves.easeInSine);
    //     }
    //   });
    // });

    pageController.addListener(() {
      if (pageController.page! - pageController.page!.truncate() == 0) {
        currentDirection = 0;
      } else if (lastIndexPos < pageController.page!) {
        currentDirection = 1;
      } else if (lastIndexPos > pageController.page!) {
        currentDirection = -1;
      }

      if (pageController.page! - pageController.page!.truncate() == 0) {}
      lastIndexPos = pageController.page!;
    });
    super.initState();
  }

  Future<void> initCurrentPage(int indexPage, bool indexContains,
      {bool fromBefore = false}) async {
    // print("initCurrentPage() $indexPage");
    final currentElements = fromBefore
        ? TextDecorator.skipElementTo(0, bookData.decodedXml.elements,
        indexContains: indexContains)
        : TextDecorator.skipElementTo(
        currentPage?.topElement.index ?? 0, bookData.decodedXml.elements,
        indexContains: indexContains);

    currentPage =await TextDecorator.getNextPageBundle(bookData.devicePixelRatio,
        bookData.size.maxWidth, bookData.size.maxHeight, currentElements,bookData.decodedXml.binaries);
    if (currentPage?.rightPartOfElement != null) {
      TextDecorator.insertFragment(currentPage!.leftPartOfElement!,
          currentPage!.rightPartOfElement!, bookData.decodedXml.elements);
    }
    pages.putIfAbsent(indexPage, () => currentPage!);
    await initNextPage(indexPage + 1);

    initPrevPage(indexPage - 1);
    print("initCurrentPage");
  }

  Future<void> initNextPage(int nextIndex) async {
    if (nextPage?.rightPartOfElement != null) {
      TextDecorator.insertFragment(nextPage!.leftPartOfElement!,
          nextPage!.rightPartOfElement!, bookData.decodedXml.elements);
    }
    final globalIndex = currentPage!.bottomElement.index;
    final nextElements =
    TextDecorator.skipElementTo(globalIndex, bookData.decodedXml.elements);

    nextPage =await TextDecorator.getNextPageBundle(bookData.devicePixelRatio,
        bookData.size.maxWidth, bookData.size.maxHeight, nextElements, bookData.decodedXml.binaries);
    pages.putIfAbsent(nextIndex, () => nextPage!);
    // print("$globalIndex");
  }

  void initPrevPage(int prevIndex,) {
    // int prevIndex = 0;
    // if(pageController.positions.isNotEmpty){
    //   prevIndex =  pageController.page!.truncate()-1;
    //
    // }else{
    //   prevIndex = initialPage-1;
    // }
    if (pages.containsKey(prevIndex) || prevIndex < 0) {
      return;
    }

    if (prevPage?.leftPartOfElement != null) {
      TextDecorator.insertFragment(prevPage!.leftPartOfElement!,
          prevPage!.rightPartOfElement!, bookData.decodedXml.elements);
    }
    final globalIndex = currentPage!.topElement.index;
    final prevElements =
    TextDecorator.takeElementTo(globalIndex, bookData.decodedXml.elements);

    prevPage = TextDecorator.getPreviousPageBundle(
        bookData.size.maxWidth, bookData.size.maxHeight, prevElements);
    pages.putIfAbsent(prevIndex, () => prevPage!);
    // print(
    //     "GLOBAL INDEX $prevIndex ${prevElements.isNotEmpty ? prevPage!
    //         .topElement : 0}");
    //
    // print("initPrevPage $globalIndex");
  }

  @override
  Widget build(BuildContext context) {


    final metrics = TextDecorator.mediumMetrics(bookData.devicePixelRatio,bookData.countWordsInBook,
        bookData.size.maxWidth, bookData.size.maxHeight, bookData.decodedXml.elements, bookData.decodedXml.binaries);
    print("${metrics}");

    return FutureBuilder(
      future: metrics,
      builder: (context,snapshot) {
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        }

        return OrientationBuilder(builder: (context, orientation) {
          return NotificationListener(
            child: PageView.builder(
              physics: BouncingScrollPhysics(),
              pageSnapping: true,
              onPageChanged: (index) {
                // lastIndex =index;
                // if(lastIndex<index){
                //   print("it was next page");
                //   afterDirection = 1;
                //   initNextPage();

                // }else if(lastIndex>index){
                //   print("it was prev page");
                //   afterDirection = -1;
                //   initPrevPage();
                // }else{
                //   afterDirection = 0;
                // }
              },
              itemBuilder: (BuildContext context, int index) {
                if (orientation != lastOrientation) {
                  // pages.clear();
                  // bookData.resetElements();
                  initCurrentPage(index, true);
                  lastOrientation = orientation;
                  // print(
                  //     "pages before ${TextDecorator.pagesBefore(
                  //         currentPage!.topElement.index, bookData.elements,
                  //         metrics)}");
                } else if (currentDirection == -1 && index == 0) {
                  // pages.clear();
                  initCurrentPage(index, true, fromBefore: true);
                }
                PageBundle? page;
                print("direction $currentDirection $globalIndex");

                if (currentDirection == 1) {
                  page = pages[index];
                  currentPage = page;
                  // print("BUILD NEXT PAGE ${pages[index]}");
                } else if (currentDirection == -1) {
                  page = pages[index];
                  currentPage = page;
                  // print("BUILD PREV PAGE $index");
                } else {
                  // print("INITPAGE");
                  page = pages[index];
                }

                // for (var element in page!.groupByLines()) {
                //   print("TEXTE: ${element}");
                // }


                return SizedBox(width: bookData.size.maxWidth,
                    child: SingleChildScrollView(
                      child: Column(children: page!.groupByLines().map((e) =>
                          Row(
                            children: [
                              Expanded(child: RichText(textAlign:e.last.styledNode.textAlign, text: TextSpan(
                                children: e.map((e) => e.textSpan).toList(),),)),
                            ],
                          )).toList(),),
                    ));

                return RichText(

                  text: TextSpan(
                      children: page!.currentElements
                          .map((e) => e.inlineSpan)
                          .toList(),
                      style: TextStyle(color: Colors.black)),
                );
              },
              controller: pageController,
              itemCount: snapshot.data!.pages,
            ),
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                // afterDirection = pageController.page!.truncate()>lastIndex?1:-1;
                // print("on ScrollEndNotification");
                if (lastIndex < pageController.page!) {
                  initNextPage(pageController.page!.round() + 1);
                } else if (lastIndex > pageController.page!) {
                  initPrevPage(pageController.page!.truncate() - 1);
                }

                // print("PAGE ${pageController.page} LAST INDEX: $lastIndex");
                lastIndex = pageController.page!;
                currentPage = pages[pageController.page!.truncate()];

                //   globalIndex = currentPage!.bottomElement.index;
              }
              return true;
            },
          );
        });
      }
    );
  }
}
