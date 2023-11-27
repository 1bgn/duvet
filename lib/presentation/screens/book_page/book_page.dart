import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/factories/hyphenated_text_factory.dart';
import '../../../domain/model/book_data.dart';
import '../../../domain/model/decoded_xml.dart';
import '../../../domain/model/styled_element.dart';
import '../../component/pager.dart';

class BookPage extends StatefulWidget {
  const BookPage({
    super.key,
  });

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  bool bookIsLoaded = false;
  late final DecodedXml decodedXml;
  late final int wordsInBook;

  @override
  void initState() {
    rootBundle.load("assets/books/book7.fb2").then((value)async {

      decodedXml = HyphenatedTextFactory.elementsFromXml(
          xmlText: utf8.decode(value.buffer.asUint8List()).replaceAll("\n", ""));
      decodedXml.elements.take(50).forEach((element) {
        print("FIRST TEXT $element");
      });
      int index = 0;
      for (var element in decodedXml.elements) {
        element.index = index;
        index += element.text.isEmpty?1: element.text.length;
      }

      wordsInBook = (decodedXml.elements
          .map((e) => e.text.split(" ").length)
          .fold(0, (previousValue, element) => previousValue + element));
      setState(() {
        bookIsLoaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
            child: LayoutBuilder(builder: (context, size) {
              if (bookIsLoaded) {
                return Row(
                  children: [
                    Expanded(
                        child: Pager(
                      bookData: BookData(
                        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                        countWordsInBook: wordsInBook,
                        decodedXml: decodedXml,
                        size: size,
                      ),
                    ))
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            }),
          );
        },
      )),
    );
  }
}
