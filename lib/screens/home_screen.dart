// ignore_for_file: prefer_const_constructors, avoid_init_to_null

import 'dart:convert';

import 'package:elephant_api/components/loader_component.dart';
import 'package:elephant_api/helpers/constans.dart';
import 'package:elephant_api/models/elephant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Elephant> _elephants = [];
  bool _showLoader = false;
  
  @override
  void initState() {
    super.initState();
    _getElephants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Elephants',
          style: TextStyle( fontSize: 22)
        ),
      ),
      body: _showLoader ? LoaderComponent(text: 'Espere un momento...',) : _getDody(),
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

  void _getElephants() async{

    setState(() {
      _showLoader = true;
    });


    var url = Uri.parse('${Constans.apiUrl}elephants');
    var response = await http.get(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
      },
    );

    setState(() {
      _showLoader = false;
    });

    var body = response.body;
    var decodedJson = jsonDecode(body);
    if (decodedJson != null)
    {
      // var contain = null;
      var myListFiltered = null;
      for (var item in decodedJson) {
        if (item.length == 12) {
          _elephants.add(Elephant.fromJson(item));
        }
      }
    }

    print(_elephants); 


    // if(response.statusCode >= 400)
    // {
    //   setState(() {
    //     //_passwordShowError = true;
    //     //_passwordError = 'email y/o contraseña incorrectos...';
    //     print('No se pudo cargar el listado de elefantes');
    //   });
    //   return;
    // }
  }

}