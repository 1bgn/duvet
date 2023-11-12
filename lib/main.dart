import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projects/domain/factories/hyphenated_text_factory.dart';
import 'package:projects/domain/model/book_data.dart';
import 'package:projects/domain/text_decorator/text_decorator.dart';
import 'package:projects/presentation/component/hyphenated_text_component.dart';
import 'package:projects/presentation/component/pager.dart';
import 'package:projects/presentation/screens/book_page/book_page.dart';
import 'package:projects/presentation/screens/select_book/select_book.dart';

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
      home:  BookPage(),
    );
  }
}


