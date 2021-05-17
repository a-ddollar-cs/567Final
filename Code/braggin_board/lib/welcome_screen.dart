import 'package:flutter/material.dart';
import 'rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amber[50],
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Braggin' Board",
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                new Container(
                  width: 100.0,
                  height: 20.0,
                ),
                new Container(
                  width: 100.0,
                  height: 200.0,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(

                    image: DecorationImage(
                        image: AssetImage('assets/logo.png'),
                        fit: BoxFit.fill
                    ),
                  ),
                ),
                new Container(
                  width: 100.0,
                  height: 20.0,
                ),
                RoundedButton(
                  colour: Colors.lightGreen,
                  title: 'Log In',
                  onPressed: () {
                    Navigator.pushNamed(context, 'login_screen');
                  },
                ),
                RoundedButton(
                    colour: Colors.green[700],
                    title: 'Register',
                    onPressed: () {
                      Navigator.pushNamed(context, 'registration_screen');
                    }),
              ]),
        ));
  }
}