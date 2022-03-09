import 'package:flutter/material.dart';
import 'dart:async';
//import 'package:shimmer/shimmer.dart';

import 'homeScreen.dart';
import 'package:hexcolor/hexcolor.dart';

class SplashScreen extends StatefulWidget {
  //widget qui change d'etat
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  void _navigateToHome() {//fonction qui redirige le navigateur vers la page d'accueil une fois
                          // la duree du splash screen termine
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => new HomeScreen()));
  }
//permet d'autres operations a s'executer le temps qu'il se termine
  Future<bool> _nockCheckForSession() async {//fonction d'encochage pour controler la session, qui doit retourner true
                                              //une fois l'animation terminee
    await Future.delayed(const Duration(milliseconds: 3000));//la duree de l'animation

    return true;
  }

  void initState() {//initialisation de chaq etat,, l'implementation doit etre initie avec l'appel
    super.initState();//a la methode heritee

    _nockCheckForSession().then((status) {
      if (status) {
        _navigateToHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
		body: Container(
			width: double.infinity,
			height: double.infinity,
			decoration: BoxDecoration(
                //color: HexColor("#ffffff"),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
				          colors: [HexColor("#b35c35"), Colors.orangeAccent.shade100],//[Colors.white, Colors.orangeAccent.shade100],
                ),
            ),
			child:Column(
				crossAxisAlignment: CrossAxisAlignment.center,
				mainAxisAlignment: MainAxisAlignment.spaceAround,
				children: [
          const Padding(
            padding: EdgeInsets.only(top: 310.0),
          ),
					Column(
						children: const [
              CircleAvatar(//cree un cercle qui contient l'image
                radius: 50,
                backgroundImage: AssetImage('images/logoUGB.jpg'),
              ),
              Text("Université Gaston Berger \n de Saint-Louis",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
						],
					),
					CircularProgressIndicator(
						valueColor: AlwaysStoppedAnimation<Color>(HexColor("#ffffff")),
					),
				],
			),
		),
      );
  }
}