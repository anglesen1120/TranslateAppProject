import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
TextEditingController text = TextEditingController();
class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: ListView(
        children: <Widget>[
          TextFormField(
            controller: text,
          ),
          RaisedButton(onPressed: (){},
          child: Text('Read'))
        ]
      ),
    );
  }
}