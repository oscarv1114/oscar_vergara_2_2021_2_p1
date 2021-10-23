// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Elephants',
          style: TextStyle( fontSize: 22)
        ),
      ),
      body: _getDody(),
    );
  }

  Widget _getDody() {
    return Container(
      child: (
        Center(
            child: Text(
              'Bienvenid@',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800
              ),
            ),
          )
      ),
    );
  }

}