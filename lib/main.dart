
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password/password.dart';

import 'newsfeed.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comhrá',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'Comhrá'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

var userMap = new Map();


bool login = false;
bool register = false;
String currentUser;
var currentUserID;


class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title,
          style: TextStyle(
              color: Colors.deepPurpleAccent,
            fontSize: 30
          ),
        ),
      ),
      body: register == true? _register() : login == true? _login() :
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'btn6',
              tooltip: 'login',
              backgroundColor: Colors.deepOrangeAccent,
              onPressed: () {
                setState(() {
                  login = true;
                });
              },
              child: Icon(Icons.person)
            ),
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 70),
              child: Text(
                'Login',
                style: TextStyle(
                    fontSize: 20
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: 'btn7',
              tooltip: 'register',
              backgroundColor: Colors.deepOrangeAccent,
              onPressed: () {
                setState(() {
                  register = true;
                });
              },
              child: Icon(Icons.assignment),
            ),
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 70),
              child: Text(
                'Register',
                style: TextStyle(
                    fontSize: 20
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _register() {

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final _scaffoldKey =  GlobalKey<ScaffoldState>();

    String email;
    String password;

    void addUser() {

      final algorithm = PBKDF2();
      final hash = Password.hash(password, algorithm);

      userMap[email] = hash;
      print(userMap);
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 40, right: 40),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (String value){
                        if(value.isEmpty){
                          return 'Email is required';
                        } else if (userMap.containsKey(value)) {
                          return 'This email is already registered';
                        }
                        return null;
                      },
                      onSaved:(String value) {
                        email = value;
                        currentUser = email;
                      }
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 60),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (String value){
                      if(value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      password = value;
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if(_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        addUser();
                      }
                    },
                    child: Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _login() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final _scaffoldKey =  GlobalKey<ScaffoldState>();

    String email;
    String password;

    bool validateUser(){

      if(userMap.containsKey(email) && Password.verify(password, userMap[email])) {
        return true;
      }
      return false;
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Column(

        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 220, left: 40, right: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (String value){
                        if(value.isEmpty){
                          return 'Email is required';
                        } else if (!userMap.containsKey(value)) {
                          return 'This email is not registered';
                        }
                        return null;
                      },
                      onSaved:(String value) {
                        email = value;
                      }
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (String value){
                      if(value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      password = value;
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    height: 50
                  ),
                  RaisedButton(
                      onPressed: () {
                          if(_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            bool loggedIn = validateUser();
                            currentUser = email;
                            print("Validated user?" + loggedIn.toString());
                            mapToList();
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => Newsfeed()));
                          }
                        },
                    child: Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




