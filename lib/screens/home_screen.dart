// ignore_for_file: prefer_const_constructors, avoid_init_to_null, prefer_is_empty

import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:elephant_api/components/loader_component.dart';
import 'package:elephant_api/components/utils.dart';
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

  Future<void> _getElephants() async{
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
        message: 'No dispone de conexi??n a internet.',
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
          ? 'No hay elefantes con ese criterio de b??squeda.'
          : 'No hay elefantes para listar.',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getElephants,
      child: SafeArea(
        // Wrapper before Scroll view!
        child: AnimateIfVisibleWrapper(
          showItemInterval: Duration(milliseconds: 100),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                for (int i = 0; i < _elephants.length; i++)
                  AnimateIfVisible(
                    key: Key(_elephants[i].sId),
                    builder: animationBuilder(
                      InkWell(
                        onTap: () => _showInfo(_elephants[i]),
                        child: Container(
                          color: Colors.grey[400],
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: CachedNetworkImage(
                                  imageUrl: _elephants[i].image,
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
                                            _elephants[i].name, 
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
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
                      xOffset: i.isEven ? 0.15 : -0.15,
                      padding: EdgeInsets.all(10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFilter() async {
    
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'No dispone de conexi??n a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

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
    for (var elephant in _elephants) {
      if (elephant.name.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(elephant);
      }
    }

    setState(() {
      _elephants = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  Widget buildAnimatedItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) =>
    FadeTransition(
      opacity: Tween<double>(
        begin: 0,
        end: 1,
      ).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, -0.1),
          end: Offset.zero,
        ).animate(animation),
      ),
  );

  Future<void> _showInfo(Elephant elephant) async {

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'No dispone de conexi??n a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(elephant.name),
            ),
            body: Container(
              padding: const EdgeInsets.all(1.0),
              alignment: Alignment.topLeft,
              child: Hero(
                tag: 'flippers',
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(150),
                              child: FadeInImage(
                                placeholder: AssetImage('assets/noimage.png'), 
                                image: NetworkImage(elephant.image),
                                height: 300,
                                width: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 350,
                        color: Color(0xFF1640d3)
                      ),
                      Container(
                        width: double.infinity,
                        color: Color(0xFF7c9bdf),
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Name:', 
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001fce)
                                )
                              ),
                              Text(
                                elephant.name, 
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70
                                ),
                              ),
                              SizedBox(height: 7,),
                              Text(
                                'Affiliation:', 
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001fce)
                                )
                              ),
                              Text(
                                elephant.affiliation, 
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70
                                ),
                              ),
                              SizedBox(height: 7,),
                              Text(
                                'Species:', 
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001fce)
                                )
                              ),
                              Text(
                                elephant.species, 
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70
                                ),
                              ),
                              SizedBox(height: 7,),
                              Text(
                                'Sex:', 
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001fce)
                                )
                              ),
                              Text(
                                elephant.sex, 
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70
                                ),
                              ),
                              SizedBox(height: 7,),
                              Text(
                                'Fictional:', 
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001fce)
                                )
                              ),
                              Text(
                                elephant.fictional, 
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70
                                ),
                              ),
                              SizedBox(height: 7,),
                              Text(
                                'Date of birth:', 
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001fce)
                                )
                              ),
                              Text(
                                elephant.dob, 
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70
                                ),
                              ),
                              SizedBox(height: 7,),
                              Text(
                                'Date of dead:', 
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001fce)
                                )
                              ),
                              Text(
                                elephant.dod, 
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70
                                ),
                              ),
                              SizedBox(height: 7,),
                              Text(
                                'link:', 
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001fce)
                                )
                              ),
                              Text(
                                elephant.wikilink, 
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 16,
                                  color: Colors.white70
                                )
                              ),
                              SizedBox(height: 7,),
                              Text(
                                'Note:', 
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001fce)
                                )
                              ),
                              Container(
                                width: 300,
                                child: Text(
                                  elephant.note, 
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}