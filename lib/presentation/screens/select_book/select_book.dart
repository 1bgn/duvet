import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/presentation/screens/book_page/book_page.dart';

class SelectBook extends StatefulWidget{
  @override
  State<SelectBook> createState() => _SelectBookState();
}

class _SelectBookState extends State<SelectBook> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Center(child: MaterialButton(onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>const BookPage()));
    },child: Text("Open book"),),)),);
  }
}