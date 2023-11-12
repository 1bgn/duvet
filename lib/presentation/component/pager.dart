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
  final Map<int,PageBundle> pages = {};
  Orientation? lastOrientation= Orientation.portrait;
  @override
  void initState() {
    double lastIndexPos = 0;
    initCurrentPage(initialPage,true);
    // Future.delayed(Duration(seconds: 1)).then((value) {
    //   Stream.periodic(Duration(milliseconds: 200)).listen((event) {
    //     pageController.nextPage(duration: Duration(milliseconds: 100), curve: Curves.easeInSine);
    //   });
    // });

    pageController.addListener(() {


      if(pageController.page!-pageController.page!.truncate()==0){

      currentDirection = 0;
      }
      else if(lastIndexPos<pageController.page! ){

        currentDirection = 1;
      }else if(lastIndexPos>pageController.page! ) {


        currentDirection = -1;

      }

      if(pageController.page! - pageController.page!.truncate()==0){





      }
    lastIndexPos = pageController.page!;


    });
    super.initState();
  }
  void initCurrentPage(int indexPage ,bool indexContains){
    final currentElements = TextDecorator.skipElementTo(currentPage?.topElement.index??0, bookData.elements,indexContains: indexContains);

     currentPage =  TextDecorator.getNextPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, currentElements);
    if(currentPage?.rightPartOfElement!=null){
      TextDecorator.insertFragment(currentPage!.leftPartOfElement!,currentPage!.rightPartOfElement!, bookData.elements);
    }
    pages.putIfAbsent(indexPage, () => currentPage!);
    initNextPage();

    initPrevPage();
    print("initCurrentPage");

  }

  void initNextPage(){

    int nextIndex = 0;
    if(pageController.positions.isNotEmpty){
      nextIndex =  pageController.page!.round()+1;

    }else{
      nextIndex = initialPage+1;
    }
    if(pages.containsKey(nextIndex)){
      return;
    }

    if(nextPage?.rightPartOfElement!=null) {
      TextDecorator.insertFragment(nextPage!.leftPartOfElement!,
          nextPage!.rightPartOfElement!, bookData.elements);
    }
    final globalIndex = currentPage!.bottomElement.index;
    final nextElements = TextDecorator.skipElementTo(globalIndex, bookData.elements);

    nextPage = TextDecorator.getNextPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, nextElements);
    pages.putIfAbsent(nextIndex, () => nextPage!);
    print("$globalIndex");

  }
  void initPrevPage(){

    int prevIndex = 0;
    if(pageController.positions.isNotEmpty){
      prevIndex =  pageController.page!.truncate()-1;

    }else{
      prevIndex = initialPage-1;
    }
    if(pages.containsKey(prevIndex)){

      return;
    }

    if(prevPage?.leftPartOfElement!=null) {
      TextDecorator.insertFragment(prevPage!.leftPartOfElement!,
          prevPage!.rightPartOfElement!, bookData.elements);
    }
   final globalIndex = currentPage!.topElement.index;
    final prevElements = TextDecorator.takeElementTo(globalIndex, bookData.elements);

    prevPage = TextDecorator.getPreviousPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, prevElements);
    pages.putIfAbsent(prevIndex, () => prevPage!);
    print("GLOBAL INDEX $prevIndex ${prevElements.isNotEmpty?prevPage!.topElement:0}");

    print("initPrevPage $globalIndex");
  }

  @override
  Widget build(BuildContext context) {
    final metrics = TextDecorator.mediumMetrics(bookData.countWordsInBook,
        bookData.size.maxWidth, bookData.size.maxHeight, bookData.elements);
    print("${metrics}");

    return OrientationBuilder(
      builder: (context,orientation) {

        return NotificationListener(child: PageView.builder(
          physics: BouncingScrollPhysics(),
          pageSnapping: true,
          onPageChanged: (index){
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

            if(orientation!=lastOrientation){
              pages.clear();
              initCurrentPage(index,true);
              lastOrientation = orientation;

            }
            PageBundle? page;
            print("direction $currentDirection $globalIndex");

            if(currentDirection == 1){


              page = pages[index];
              currentPage = page;
              print("BUILD NEXT PAGE ${pages[index]}");



            }else if(currentDirection == -1){


              page = pages[index];
              currentPage = page;
              print("BUILD PREV PAGE $index");


            }else{
              print("INITPAGE");
              page = pages[index];
            }




            return RichText(
              text:
              TextSpan(
                  children: page!.currentElements
                      .map((e) => e.inlineSpan)
                      .toList(),
                  style: TextStyle(color: Colors.black)),

            );
          },
          controller: pageController,
          itemCount: metrics.pages,
        ),onNotification: (notification){
          if(notification is ScrollEndNotification ){

            // afterDirection = pageController.page!.truncate()>lastIndex?1:-1;
            // print("on ScrollEndNotification");
            if(lastIndex<pageController.page!){
              initNextPage();
            }else if(lastIndex>pageController.page!) {
              initPrevPage();
            }



              print("PAGE ${pageController.page} LAST INDEX: $lastIndex");
              lastIndex = pageController.page!;

            //   globalIndex = currentPage!.bottomElement.index;


          }
          return true;

        },);
      }
    );
  }
}
