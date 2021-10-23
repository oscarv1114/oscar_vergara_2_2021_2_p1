// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_final_fields


import 'package:elephant_api/components/loader_component.dart';
import 'package:elephant_api/models/elephant.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ElephantInfoScreen extends StatefulWidget {

  final Elephant elephant;
  
  ElephantInfoScreen({required this.elephant});

  @override
  _ElephantInfoScreenState createState() => _ElephantInfoScreenState();
}

class _ElephantInfoScreenState extends State<ElephantInfoScreen> {
  
  bool _showLoader = false;
  late Elephant _elephant;
  Future<void>? _launched;

  @override
  void initState() {
    super.initState();
    _elephant = widget.elephant;
    //_getElephant();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_elephant.name),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              _showImage(),
              _showData(),
            ],
          ),
          _showLoader ? LoaderComponent(text: 'Por favor espere...',) : Container(),
        ],
      ),
    );
  }

  Widget _showImage() {
    return Container(
      margin: EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(150),
            child: FadeInImage(
              placeholder: AssetImage('assets/noimage.png'), 
              image: NetworkImage(_elephant.image),
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }

  Widget _showData() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'Name: ', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(
                              _elephant.name,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: <Widget>[
                            Text(
                              'Affiliation: ', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(
                              _elephant.affiliation, 
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: <Widget>[
                            Text(
                              'Species: ', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(
                              _elephant.species, 
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: <Widget>[
                            Text(
                              'Sex: ', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(
                              _elephant.sex, 
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: <Widget>[
                            Text(
                              'Fictional: ', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(
                              _elephant.fictional, 
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: <Widget>[
                            Text(
                              'Date of birth: ', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(
                              _elephant.dob, 
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: <Widget>[
                            Text(
                              'Date of dead: ', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(
                              _elephant.dod, 
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: <Widget>[
                            Text(
                              'link: ', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            GestureDetector(
                              child: Text(
                                _elephant.wikilink, 
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                   color: Colors.blue
                                )
                              ),
                              onTap: () {
                                setState(() {
                                  _launched = _launchInBrowser(_elephant.wikilink);        
                                });
                              }
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: <Widget>[
                            Text(
                              'Note: ', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold,

                              )
                            ),
                            Container(
                              width: 300,
                              child: Text(
                                _elephant.note,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      //print('Could not launch $url');
    }
  }

}