import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projects/domain/factories/hyphenated_text_factory.dart';
import 'package:projects/domain/text_decorator/text_decorator.dart';
import 'package:projects/presentation/component/hyphenated_text_component.dart';

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: LayoutBuilder(
        builder: (context,size) {
          return ListView(children: [
            FutureBuilder<ByteData>(future: rootBundle.load("assets/books/book5.fb2"), builder: (BuildContext context, AsyncSnapshot<ByteData> snapshot) {
              if(snapshot.hasData){
                return HyphenatedTextComponent(hyphenatedText: HyphenatedTextFactory.fromXml(maxWidth: size.maxWidth,xmlText: utf8.decode(snapshot.data!.buffer.asUint8List())),);
              }

              return CircularProgressIndicator();
            }, )
          ],);
        }
      )),
    );
  }
}
