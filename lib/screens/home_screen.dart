// ignore_for_file: prefer_const_constructors, avoid_init_to_null, prefer_is_empty

import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:elephant_api/components/loader_component.dart';
import 'package:elephant_api/helpers/constans.dart';
import 'package:elephant_api/models/elephant.dart';
import 'package:elephant_api/screens/elephant_info_screen.dart';
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
  bool _isFiltered = false;
  String _search = '';
  
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
        actions: <Widget>[
          _isFiltered
          ? IconButton(
              onPressed: _removeFilter, 
              icon: Icon(Icons.clear)
            )
          : IconButton(
              onPressed: _showFilter, 
              icon: Icon(Icons.filter_alt)
            )
        ],
      ),
      body: _showLoader ? LoaderComponent(text: 'Espere un momento...',) : _getContent(),
    );
  }

  Widget _getContent() {
    return _elephants.length == 0
      ? _noContent()
      : _getListView();
  }

  Future<Null> _getElephants() async{
    _elephants = [];

    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'No dispone de conexión a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }


    var url = Uri.parse('${Constans.apiUrl}/elephants');
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
      for (var item in decodedJson) {
      //some records come empty, size is validated
        if (item.length == 12) {
          _elephants.add(Elephant.fromJson(item));
        }
      }
    }

    if(response.statusCode >= 400)
    {
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'No se pudo cargar el listado de elefantes',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      ); 
      return;
    }

  }

  Widget _noContent() {
    return Center(
      child: Text(
        _isFiltered
          ? 'No hay elefantes con ese criterio de búsqueda.'
          : 'No hay elefantes para listar.',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800
        ),
      ),
    );
  }

  Widget _getListView() {
    // return RefreshIndicator(
    //   onRefresh: _getElephants,
    //   child: ListView(
    //     children: _elephants.map((e) {
    //       return InkWell(
    //         onTap: () {},
    //         child: Container(
    //           margin: EdgeInsets.all(10),
    //           child: Text(
    //             e.name, 
    //             style: TextStyle(
    //               fontSize: 20
    //             ),
    //           ),
    //         ),
    //       );
    //     }).toList(),
    //   ),
    // );
    return RefreshIndicator(
      onRefresh: _getElephants,
      child: ListView(
        children: _elephants.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goInfoElephante(e),
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: CachedNetworkImage(
                        imageUrl: e.image,
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                        height: 80,
                        width: 80,
                        placeholder: (context, url) => Image(
                          image: AssetImage('assets/noimage.png'),
                          fit: BoxFit.cover,
                          height: 80,
                          width: 80,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text(
                                  e.name, 
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_right_outlined, size: 45, color: Colors.orange[300],),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  void _showFilter() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('Filtrar elefantes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Escriba las primeras letras del nombre del elefante'),
              SizedBox(height: 10,),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nombre...',
                  labelText: 'Buscar',
                  suffixIcon: Icon(Icons.search)
                ),
                onChanged: (value) {
                  _search = value;
                },
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: Text('Cancelar')
            ),
            TextButton(
              onPressed: () => _filter(), 
              child: Text('Filtrar')
            ),
          ],
        );
      });
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
      _search = '';
    });
    _getElephants();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<Elephant> filteredList = [];
    for (var elephante in _elephants) {
      if (elephante.name.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(elephante);
      }
    }

    setState(() {
      _elephants = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goInfoElephante(Elephant elephant) async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => ElephantInfoScreen(
          elephant: elephant,
        )
      )
    );
    if (result == 'yes') {
      _getElephants();
    }
  }
}