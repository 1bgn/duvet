import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projects/domain/factories/hyphenated_text_factory.dart';
import 'package:projects/domain/model/book_data.dart';
import 'package:projects/domain/text_decorator/text_decorator.dart';
import 'package:projects/presentation/component/hyphenated_text_component.dart';
import 'package:projects/presentation/component/pager.dart';

import 'domain/model/styled_element.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(),
        textTheme: TextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool bookIsLoaded  = false;
  late final List<StyledElement> _elements;
  late final int wordsInBook;

  @override
  void initState() {
    rootBundle.load("assets/books/book4.fb2").then((value) {
      _elements = HyphenatedTextFactory.elementsFromXml(xmlText: utf8.decode(value.buffer.asUint8List()));
      int index = 0;
      for (var element in _elements) {
        element.index = index;
        index += element.text.length;
      }
      _elements.take(20).forEach((element) {
        print("FIRST TEXT $element");
      });
      wordsInBook =  (_elements.map((e) => e.text.split(" ").length).fold(0, (previousValue, element) => previousValue+element));
      setState(() {
        bookIsLoaded = true;

      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
        return LayoutBuilder(
            builder: (context,size) {

              if(bookIsLoaded){
                return Row(children: [
                  Expanded(child: Pager(bookData: BookData(countWordsInBook: wordsInBook,elements: _elements,size: size,),))
                ],);
              }else{
return CircularProgressIndicator();
              }
            }
        );
      },)),
    );
  }
}
