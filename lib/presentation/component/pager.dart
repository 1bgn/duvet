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
  double lastIndexPos = 0;
  late PageController pageController = PageController(initialPage: lastIndex.truncate());
  int currentDirection = 0;
  int afterDirection = 0;
  PageBundle? currentPage;
  PageBundle? prevPage;
  PageBundle? nextPage;
  static int globalIndex = 0;
  Completer _completer = Completer();

  @override
  void initState() {
    currentPage =  TextDecorator.getNextPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, bookData.elements);
    if(currentPage?.rightPartOfElement!=null){
          TextDecorator.insertFragment(currentPage!.leftPartOfElement!,currentPage!.rightPartOfElement!, bookData.elements);
        }
    final nextElements = TextDecorator.skipElementTo(currentPage!.bottomElement.index, bookData.elements);
    nextPage = TextDecorator.getNextPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, nextElements);
    if(currentPage!.topElement.index!=0){
       final previousElements = TextDecorator.takeElementTo(currentPage!.topElement.index, bookData.elements);
       prevPage = TextDecorator.getPreviousPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, previousElements);
    }
    pageController.addListener(() {

      // print("index ${lastIndexPos.truncate()} ${pageController.page}");
      if(pageController.page!-pageController.page!.truncate()==0){
      // print("Current ${lastIndex} ${pageController.page!.truncate()}");
      // if(currentDirection==1 &&pageController.page!>lastIndex ){
      //   afterDirection = 1;
      // }else if (currentDirection==-1 && pageController.page!<lastIndex){
      //   afterDirection = -1;
      // }else {
      //   afterDirection = 0;
      // }
      currentDirection = 0;
      }
      else if(lastIndexPos<pageController.page! ){
        //next page
        // print("NEXT");


        currentDirection = 1;
      }else if(lastIndexPos>pageController.page! ) {
        //preview page
        // print("PREV");


        currentDirection = -1;

      }

      if(pageController.page! - pageController.page!.truncate()==0){


        // globalIndex = currentPage!.bottomElement.index;


      }
    lastIndexPos = pageController.page!;
      // lastIndex = pageController.page!.truncate();
      // print("pageListener ${pageController.page}");
      // if(pageController.page!.truncate() == lastIndex){
      //   // print("GERGER $globalIndex");
      //   globalIndex = currentPage!.bottomElement.index;
      // }
    });
    super.initState();
  }

  void initNextPage(){
    // if(pageController.page!.truncate() == lastIndexPos.truncate()){
    //   print("CURR");
    //   return;
    // }

    if(nextPage?.rightPartOfElement!=null) {
      // print("GREGER 2222 ${nextPage!.leftPartOfElement}}");
      // print("GREGER 2222 ${nextPage!.rightPartOfElement}}");
      TextDecorator.insertFragment(nextPage!.leftPartOfElement!,
          nextPage!.rightPartOfElement!, bookData.elements);
    }
    globalIndex = currentPage!.bottomElement.index;
    final nextElements = TextDecorator.skipElementTo(globalIndex, bookData.elements);

    nextPage = TextDecorator.getNextPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, nextElements);
    print("initNextPage $globalIndex");

  }
  void initPrevPage(){

    // if(pageController.page!.truncate() == 0){
    //   print("FIRST PAGE");
    //   return;
    // }

    if(prevPage?.leftPartOfElement!=null) {
      TextDecorator.insertFragment(prevPage!.leftPartOfElement!,
          prevPage!.rightPartOfElement!, bookData.elements);
    }
    globalIndex = currentPage!.topElement.index;
    final prevElements = TextDecorator.takeElementTo(globalIndex, bookData.elements);

    prevPage = TextDecorator.getPreviousPageBundle(bookData.size.maxWidth,bookData.size. maxHeight, prevElements);
    print("initPrevPage $globalIndex");
  }

  @override
  Widget build(BuildContext context) {
    final metrics = TextDecorator.mediumMetrics(bookData.countWordsInBook,
        bookData.size.maxWidth, bookData.size.maxHeight, bookData.elements);
    print("${metrics}");

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

        PageBundle? page;
        print("direction $currentDirection $globalIndex");

        if(currentDirection == 1){

          prevPage = currentPage;
          page = nextPage;
          currentPage = page;
          print("BUILD NEXT PAGE");



        }else if(currentDirection == -1){

          nextPage = currentPage;
          page = prevPage;

          currentPage = page;
          print("BUILD PREV PAGE");


        }else{
          print("INITPAGE");
          page = currentPage;
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
          afterDirection  =1;
        }else if(lastIndex>pageController.page!) {
          afterDirection = -1;
        }
        print("notification $notification $afterDirection");

          if(afterDirection == 1){
            initNextPage();
          }else if(afterDirection == -1){
            initPrevPage();

          }
          print("PAGE ${pageController.page} LAST INDEX: $lastIndex");
          lastIndex = pageController.page!;

        //   globalIndex = currentPage!.bottomElement.index;


      }
      return true;

    },);
  }
}
