import 'package:flutter/material.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:projet_app/localisation.dart';
import 'ModelNews.dart';
import 'model.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen() : super();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;
//permet au widget de changer de parent n'importe ou dans l'app sans perdre leur etat
  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /*bottomNavigationBar*/
        bottomNavigationBar: FancyBottomNavigation(
          activeIconColor: HexColor("#ffffff"),
          circleColor: HexColor("#b35c35"),
          inactiveIconColor: HexColor("#b35c35"),
          barBackgroundColor: HexColor("#ffffff"),
          textColor: HexColor("#b35c35"),
          tabs: [
            TabData(
                iconData: Icons.home,
                title: "Accueil",
                onclick: () {
                  final FancyBottomNavigationState fState = bottomNavigationKey
                      .currentState as FancyBottomNavigationState;
                  fState.setPage(2);
                }
			),
            TabData(
                iconData: IconData(62770, fontFamily: 'MaterialIcons'),
                title: "Se localiser",
                onclick: () =>
					        Navigator.push(
                        context, MaterialPageRoute(builder: (context) =>
                      LocalisationPage())),
                    /*Navigator.of(context)
                        .push(
                        MaterialPageRoute(builder: (context) => LocalisationPage()),
                    )*/
            ),
          ],
          initialSelection: 0,
          key: bottomNavigationKey,
          onTabChangedListener: (position) {
            setState(() {
              currentPage = position;
            });
          },
        ),

        /*Menu*/
        drawer: Drawer(
          child: ListView( //liste ou plusieurs rangees
              children: <Widget>[
                new DrawerHeader( //l'entete du menu
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('images/logoUGB.jpg'),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: HexColor("#ffffff"),
                      /*gradient: LinearGradient(
                          colors: [Colors.white, HexColor("#ffffff")]
                      )*/
                  ),
                ),
                ListTile( //menu
                    hoverColor: HexColor("#ffffff"),
                    //au moment du survol
                    leading: IconButton(
                      onPressed: () =>
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                              builder: (context) => HomeScreen())),
                      icon: Icon(
                        IconData(0xe318, fontFamily: 'MaterialIcons'),
                      ),
                    ),
                    title: Text(
                      'Accueil',
                      style: TextStyle(
                          fontSize: 18,
                          color: HexColor("#b35c35")
                      ),
                    ),
                    trailing: Icon(Icons.arrow_right),
                    //flechette permettant de retourner a la page d'accueil
                  onTap: () { //au clic
                    //Navigator.of(context).pop(); //au clic, le menu se ferme
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) =>
                        HomeScreen())); //le menu se ferme et la carte de géolocalisation s'affiche
                  }
                ),
				ListTile( //menu
                    hoverColor: HexColor("#ffffff"),
                    //au moment du survol
                    leading: IconButton(
                      onPressed: () =>
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                              builder: (context) => LocalisationPage())),
                      icon: Icon(
                        IconData(62770, fontFamily: 'MaterialIcons'),
                      ),
                    ),
                    title: Text(
                      'Se repérer',
                      style: TextStyle(
                          fontSize: 18,
                          color: HexColor("#b35c35")
                      ),
                    ),
                    trailing: Icon(Icons.arrow_right),
                    //flechette permettant de retourner a la page d'accueil
                    onTap: () { //au clic
                      Navigator.of(context).pop(); //au clic, le menu se ferme
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) =>
                          LocalisationPage())); //le menu se ferme et la carte de géolocalisation s'affiche
                    }
                ),
                
              ]
          ),
        ),
        appBar: AppBar(
          title: Text('Université Gaston Berger',
					style: TextStyle(
					  fontSize: 20.0,
					  color: HexColor("#ffffff"),
					),
					),
          backgroundColor: HexColor("#b35c35"),
          iconTheme: IconThemeData(
            color: HexColor("#ffffff"),
          ),
        ),
        body:

        FutureBuilder(
          future: Modelnews.getRss(),
          builder: (BuildContext context, AsyncSnapshot  snap) {
            if (snap.hasData) {
              //final List _news = snap.data;

              return ListView.separated(
                itemBuilder: (BuildContext context, int index ) {
                  //final _item = _news[index];


                  return ListTile(

                    title: Text(snap.data[index].title),

                    subtitle: Text(
                      snap.data[index].pub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>
                            NewsDetails(
                              title: ("Notification"),
                              url: snap.data[index].linkpage,
                              key: null,
                            ),
                        ),
                      );
                    },

                  );
                },
                separatorBuilder: (context, i) => const Divider(),
                itemCount: snap.data.length,
              );
            } else if (snap.hasError) {
              return Center(
                child: Text(snap.error.toString()),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
    );
  }
}
