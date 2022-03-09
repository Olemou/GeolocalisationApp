import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart' as fl_mp;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:projet_app/homeScreen.dart';
import 'package:projet_app/scale_layer_plugin_option.dart';
import 'package:projet_app/zoombuttons_plugin_option.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';


class LocalisationPage extends StatefulWidget {
  const LocalisationPage({Key? key}) : super(key: key);

  @override
  _LocalisationPageState createState() => _LocalisationPageState();
}

class _LocalisationPageState extends State<LocalisationPage> /*with OSMMixinObserver*/{
	String layer1 = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
	String layer2 = 'http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';
	bool layerToggle = true;
  LocationData? _currentLocation;
  late final fl_mp.MapController _mapController;
  final bool _liveUpdate = false;
  bool _permission = false;
  String? _serviceError = '';
  var interActiveFlags = InteractiveFlag.all;
  final Location _locationService = Location();
  late GlobalKey<ScaffoldState> scaffoldKey;
  Key mapGlobalkey = UniqueKey();
  ValueNotifier<bool> zoomNotifierActivation = ValueNotifier(false);
  ValueNotifier<bool> visibilityZoomNotifierActivation = ValueNotifier(false);
  ValueNotifier<bool> advPickerNotifierActivation = ValueNotifier(false);
  ValueNotifier<bool> trackingNotifier = ValueNotifier(false);
  ValueNotifier<bool> showFab = ValueNotifier(true);
  Timer? timer;
  int x = 0;

	static LatLng ugb = LatLng(16.061851,-16.422973);
	/*static LatLng Bibliotheque_Universitaire = LatLng(16.061371,-16.422888);
	static LatLng Rectorat = LatLng(16.062684,-16.420974);
	static LatLng Scolarite = LatLng(16.061643,-16.420515);//(48.8566, 2.3522),Scolarite
	static LatLng Incubateur = LatLng(16.062381,-16.419078);//(48.8566, 2.3522),Incubateur
	static LatLng UFR_2S = LatLng(16.060047,-16.425168);//(48.8566, 2.3522),UGB2
	static LatLng Restaurant_2 = LatLng(16.067587,-16.422046);//(48.8566, 2.3522),Resto2
	static LatLng Restaurant_1 = LatLng(16.065635,-16.426189);//(48.8566, 2.3522),resto1
	static LatLng Centre_Medical = LatLng(16.066680,-16.426366);//(48.8566, 2.3522),Centre Medical
	static LatLng Tour_De_L_oeuf = LatLng(16.065637,-16.422865);//(48.8566, 2.3522),Tour de l'oeuf
	static LatLng Amphi_A = LatLng(16.061461,-16.423046);//(48.8566, 2.3522),Amphi A
	static LatLng Amphi_B = LatLng(16.061906,-16.422784);//(48.8566, 2.3522),Amphi B
	static LatLng Amphi_C = LatLng(16.061190,-16.423627);//(48.8566, 2.3522),Amphi C
	static LatLng CCOS = LatLng(16.061247,-16.424133);//(48.8566, 2.3522),Ccos
	static LatLng Piscine_Olympique = LatLng(16.064288,-16.420681);//(48.8566, 2.3522),piscine
	static LatLng UFR_SEFS = LatLng(16.063595,-16.419968);//(48.8566, 2.3522),sefs
	static LatLng CEA_MITIC = LatLng(16.060426,-16.425268);//(48.8566, 2.3522),cea mitic
	static LatLng Amphi_Crac  = LatLng(16.060865,-16.423448);//(48.8566, 2.3522),Amphi CRAC
	*/
	late  LatLng selectedMarker;

  @override
  void initState() {
    super.initState();
		selectedMarker = ugb;
    _mapController = fl_mp.MapController();
    initLocationService();
  }

  void initLocationService() async {
    await _locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
    );

    LocationData? location;
    bool serviceEnabled;
    bool serviceRequestResult;

    try {
      serviceEnabled = await _locationService.serviceEnabled();

      if (serviceEnabled) {
        var permission = await _locationService.requestPermission();
        _permission = permission == PermissionStatus.granted;

        if (_permission) {
          location = await _locationService.getLocation();
          _currentLocation = location;
          _locationService.onLocationChanged
              .listen((LocationData result) async {
            if (mounted) {
              setState(() {
                _currentLocation = result;

                // If Live Update is enabled, move map center
                if (_liveUpdate) {
                  _mapController.move(
                      LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      _mapController.zoom);
                }
              });
            }
          });
        }
      } else {
        serviceRequestResult = await _locationService.requestService();
        if (serviceRequestResult) {
          initLocationService();
          return;
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_NON_ACCORDEE') {
        _serviceError = e.message;
      } else if (e.code == 'ERREUR_D_ETAT_DU_SERVICE') {
        _serviceError = e.message;
      }
      location = null;
    }
  }

  @override
  Widget build(BuildContext context) {
	LatLng currentLatLng;

    // Until currentLocation is initially updated, Widget can locate to 0, 0
    // by default or store previous location value to show.
    if (_currentLocation != null) {
      currentLatLng =
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    } else {
      currentLatLng = LatLng(0, 0);
    }
	
    var markers = <Marker>[
	  Marker(
        width: 120.0,
        height: 120.0,
        point: currentLatLng,
        builder: (ctx) => Container(
		  child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
              content: Text('Voici votre position actuelle'),
            ));
          },
          child: const Icon(
		  Icons.my_location_sharp,
		  color: Colors.blueAccent,
		  ),
        ),
      ),
	  ),
      Marker(
        width: 100.0,
        height: 100.0,
        point: LatLng(16.061851,-16.422973),
		builder: (ctx) => new Container(
          child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
					children: [
						ListTile(
							title: Text('Université Gaston Berger',
							textAlign: TextAlign.center,
							style: TextStyle(
								fontSize: 20.0,
								color: HexColor("#b35c35"),
							),
							),

						),
						ListTile(
							leading: IconButton(
								onPressed: () {},
								icon: Icon(Icons.location_on),
							),
							title: Text('BP: 234 - Saint-Louis - SENEGAL'),
						),
						ListTile(
							leading: IconButton(
								onPressed: () {},
								icon: Icon(Icons.language),
							),
							title: Text('https://www.ugb.sn'),
						),
						ListTile(
							leading: Icon(Icons.phone),
							title: Text('+221 33 961 19 06'),
						),
					]
				);
				}
			);
		  },
          ),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(16.061371,-16.422888),
        builder: (ctx) => Container(
			child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
				  showModalBottomSheet(
					context: context,
					builder: (builder){
						return new Wrap(
							children: [
								ListTile(
									title: Text('Bibliothèque universitaire',
									textAlign: TextAlign.center,
									style: TextStyle(
										fontSize: 20.0,
										color: HexColor("#b35c35"),
									),
									),
								),
								ListTile(
									leading: IconButton(
									onPressed: () {},
									icon: Icon(Icons.location_on),
								),
									title: Text('BP: 234 - Saint-Louis'),
								),
								ListTile(
									leading: IconButton(
									onPressed: () {},
									icon: Icon(Icons.email),
									),
									title: Text('bu@ugb.edu.sn'),
								),
								ListTile(
									leading: IconButton(
										onPressed: () {},
										icon: Icon(Icons.watch),
									),
									title: Text('Lundi - Vendredi 08H - 17H'),
								),
								ListTile(
									leading: Icon(Icons.phone),//call
									title: Text('+221 33 961 23 23'),
								),
							]
					);
					}
				);
			},
          ),
        ),
      ),

      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(16.062684,-16.420974),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.location_on),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
					return new Wrap(
						children: [
							ListTile(
								title: Text('Rectorat',
								textAlign: TextAlign.center,
								style: TextStyle(
									fontSize: 20.0,
									color: HexColor("#b35c35"),
								),
								),
							),
						ListTile(
							leading: IconButton(
								onPressed: () {},
								icon: Icon(Icons.location_on),
							),
							title: Text('Rectorat'),
						),
						ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.language),
						),
						title: Text('https://www.ugb.sn'),
						),
						]
					);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(16.061643,-16.420515),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.money),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
					return new Wrap(
						children: [
							ListTile(
								title: Text('Scolarité',
									textAlign: TextAlign.center,
									style: TextStyle(
										fontSize: 20.0,
										color: HexColor("#b35c35"),
									),
								),
							),
							ListTile(
								leading: IconButton(
									onPressed: () {},
									icon: Icon(Icons.location_on),
								),
								title: Text('BP: 234 Saint-Louis'),
							),
							ListTile(
								leading: IconButton(
									onPressed: () {},
									icon: Icon(Icons.language),
								),
								title: Text('https://www.ugb.sn'),
							),
						]
					);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(16.062381,-16.419078),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.location_on),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('Incubateur',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),

					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
					),
					title: Text('BP: 234 Saint-Louis'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.email),
						),
						title: Text('contact@concree.com'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.language),
						),
						title: Text('https://www.ugb.sn'),
					),
					ListTile(
						leading: Icon(Icons.phone),//call
						title: Text('+221 33 999 99 99'),
					),
				]
				);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(16.061493,-16.422920),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.location_on),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('IFOAD',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),

					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
					),
					title: Text('BP: 234 Saint-Louis'),
					),
				]
				);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(16.067155,-16.418523),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.location_on),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text("Maison de l'Université",
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),

					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
					),
					title: Text('BP: 234 Saint-Louis'),
					),
				]
				);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(16.056879,-16.429143),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.location_on),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('Ferme agricole',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),

					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
					),
					title: Text('BP: 234 Saint-Louis'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.language),
						),
						title: Text('https://www.ugb.sn'),
					),
				]
				);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(16.060047,-16.425168),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('UFR des Sciences de la Santé',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP : 234 Saint-Louis'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.email),
						),
						title: Text('2s@ugb.edu.sn'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.language),
						),
						title: Text('https://www.ugb.sn'),
					),
					ListTile(
						leading: Icon(Icons.phone),//call
						title: Text('+221 33 961 19 06'),
					),
				]
				);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.067587,-16.422046),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.restaurant),
              color: Colors.deepOrange,
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
					return new Wrap(
						children: [
							ListTile(
								title: Text('Restaurant N°2',
								textAlign: TextAlign.center,
								style: TextStyle(
									fontSize: 20.0,
									color: HexColor("#b35c35"),
								),
								),
							),
							ListTile(
								leading: IconButton(
									onPressed: () {},
									icon: Icon(Icons.location_on),
								),
								title: Text('BP : 234 Saint-Louis'),
							),
							ListTile(
								leading: IconButton(
									onPressed: () {},
									icon: Icon(Icons.language),
								),
								title: Text('https://www.ugb.sn'),
							),
						]
					);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.065635,-16.426189),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.location_on),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
					return new Wrap(
						children: [
						ListTile(
							title: Text('Restaurant N°1',
								textAlign: TextAlign.center,
								style: TextStyle(
								fontSize: 20.0,
								color: HexColor("#b35c35"),
								),
							),
						),
						ListTile(
								leading: IconButton(
									onPressed: () {},
									icon: Icon(Icons.location_on),
								),
								title: Text('BP : 234 Saint-Louis'),
							),
						ListTile(
							leading: IconButton(
								onPressed: () {},
								icon: Icon(Icons.language),
							),
							title: Text('https://www.ugb.sn'),
						),
						]
					);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.066680,-16.426366),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.local_hospital),
              color: Colors.red,
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
								context: context,
								builder: (builder){
									return new Wrap(
										children: [
											ListTile(
												title: Text('Centre Medical',
													textAlign: TextAlign.center,
													style: TextStyle(
														fontSize: 20.0,
														color: HexColor("#b35c35"),
													),
												),
										),
										ListTile(
											leading: IconButton(
												onPressed: () {},
												icon: Icon(Icons.location_on),
											),
											title: Text('BP : 234 Saint-Louis'),
										),
										ListTile(
											leading: IconButton(
												onPressed: () {},
												icon: Icon(Icons.language),
											),
											title: Text('https://www.ugb.sn'),
										),
										ListTile(
											leading: Icon(Icons.phone),//call
											title: Text('77 326 57 02 / 77 169 12 00 / 77 169 11 74'),
										),
						]
					);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.065637,-16.422865),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text("Tour de l'oeuf",
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP : 234 Saint-Louis'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.language),
						),
						title: Text('https://www.ugb.sn'),
					),
				]
				);
				}
			);
			},
          ),
      ),
	  ),
		
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.061461,-16.423046),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('Amphi A',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP : 234 Saint-Louis'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.language),
						),
						title: Text('https://www.ugb.sn'),
					),
				]
				);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.061906,-16.422784),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('Amphi B',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP : 234 Saint-Louis'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.language),
						),
						title: Text('https://www.ugb.sn'),
					),
				]
				);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.061190,-16.423627),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('Amphi C',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP : 234 Saint-Louis'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.language),
						),
						title: Text('https://www.ugb.sn'),
					),
				]
				);
				}
			);
			},
          ),
      ),
	  ),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.061247,-16.424133),
        builder: (ctx) => Container(
          child: IconButton(
            icon: Icon(Icons.location_on),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('Centre de Calcul Ousmane Seck (CCOS)',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('Centre de Calcul Ousmane Seck (CCOS)'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.email),
						),
						title: Text('ccos@ugb.edu.sn'),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.watch),
						),
						title: Text('Lundi - Vendredi 08H - 17H'),
					),
					ListTile(
						leading: Icon(Icons.phone),//call
						title: Text('+221 33 961 00 00 '),
					),
				]
				);
				}
			);
			},
          ),
        ),
	  ),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.064288,-16.420681),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.location_on),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('Piscine Olympique',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP : 234 Saint-Louis'),
					),
				]
				);
				}
			);
			},
          ),
      ),),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.063595,-16.419968),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('UFR SEFS',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP 234 Saint-Louis'),
					),
				ListTile(
					leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.email),
					),
					title: Text('ufrsefs@ugb.edu.sn'),
				),
				ListTile(
					leading: IconButton(
					onPressed: () {},
					icon: Icon(Icons.language),
					),
					title: Text('https://www.ugb.sn'),
				),
				ListTile(
					leading: Icon(Icons.phone),//call
					title: Text('+221 33 824 98 37'),
				),
				]
				);
				}
			);
			},
          ),
      ),),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.0607955,-16.4245231),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('UFR CRAC',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP 234 Saint-Louis'),
					),
				ListTile(
					leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.email),
					),
					title: Text('ufrcrac@ugb.edu.sn'),
				),
				ListTile(
					leading: IconButton(
					onPressed: () {},
					icon: Icon(Icons.language),
					),
					title: Text('https://www.ugb.sn'),
				),
				ListTile(
					leading: Icon(Icons.phone),//call
					title: Text('+221 33 961 23 60'),
				),
				]
				);
				}
			);
			},
          ),
      ),),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.0614784,-16.4237212),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('UFR SAT',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP 234 Saint-Louis'),
					),
				ListTile(
					leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.email),
					),
					title: Text('sat@ugb.edu.sn'),
				),
				ListTile(
					leading: IconButton(
					onPressed: () {},
					icon: Icon(Icons.language),
					),
					title: Text('https://www.ugb.sn'),
				),
				ListTile(
					leading: Icon(Icons.phone),//call
					title: Text('+221 33 961 23 60'),
				),
				]
				);
				}
			);
			},
          ),
      ),),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.0614724,-16.423657),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('UFR SEG',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP 234 Saint-Louis'),
					),
				ListTile(
					leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.email),
					),
					title: Text('ufrseg@ugb.edu.sn'),
				),
				ListTile(
					leading: IconButton(
					onPressed: () {},
					icon: Icon(Icons.language),
					),
					title: Text('https://www.ugb.sn'),
				),
				]
				);
				}
			);
			},
          ),
      ),),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.0604724,-16.4246053),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('UGB2',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP 234 Saint-Louis'),
					),
				ListTile(
					leading: IconButton(
					onPressed: () {},
					icon: Icon(Icons.language),
					),
					title: Text('https://www.ugb.sn'),
				),
				]
				);
				}
			);
			},
          ),
      ),),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.0621831,-16.4226691),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('UFR SJP',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP 234 Saint-Louis'),
					),
				ListTile(
					leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.email),
					),
					title: Text('sjp@ugb.edu.sn'),
				),
				ListTile(
					leading: IconButton(
					onPressed: () {},
					icon: Icon(Icons.language),
					),
					title: Text('https://www.ugb.sn'),
				),
				ListTile(
					leading: Icon(Icons.phone),
					title: Text('+221 33 961 67 07'),
				),
				]
				);
				}
			);
			},
          ),
      ),),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.0611965,-16.44237037),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
				return new Wrap(
				children: [
					ListTile(
						title: Text('IPSL',
						textAlign: TextAlign.center,
						style: TextStyle(
						fontSize: 20.0,
						color: HexColor("#b35c35"),
						),
						),
					),
					ListTile(
						leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.location_on),
						),
						title: Text('BP 234 Saint-Louis'),
					),
				ListTile(
					leading: IconButton(
						onPressed: () {},
						icon: Icon(Icons.email),
					),
					title: Text('ipsl@ugb.edu.sn'),
				),
				ListTile(
					leading: IconButton(
					onPressed: () {},
					icon: Icon(Icons.language),
					),
					title: Text('https://www.ugb.sn'),
				),
				ListTile(
					leading: Icon(Icons.phone),//call
					title: Text('+221 33 824 98 37'),
				),
				]
				);
				}
			);
			},
          ),
      ),),
	  Marker(
        width: 60.0,
        height: 60.0,
        point: LatLng(16.0444493,-16.4371913 ),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.location_on),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
				  showModalBottomSheet(
					context: context,
					builder: (builder){
						return new Wrap(
							children: [
							ListTile(
								title: Text('CEA MITIC',
									textAlign: TextAlign.center,
									style: TextStyle(
										fontSize: 20.0,
										color: HexColor("#b35c35"),
									),
								),

							),
							ListTile(
								leading: IconButton(
									onPressed: () {},
									icon: Icon(Icons.location_on),
								),
								title: Text('Sanar, Université Gaston Berger, RN 2'),
							),
							ListTile(
								leading: IconButton(
									onPressed: () {},
									icon: Icon(Icons.email),
								),
								title: Text('ceamitic@ugb.edu.sn'),
							),
							ListTile(
								leading: IconButton(
									onPressed: () {},
									icon: Icon(Icons.language),
								),
								title: Text('Lundi - Vendredi 9H - 17H'),
							),
							ListTile(
								leading: Icon(Icons.phone),//call
								title: Text('+221 33 961 91 00'),
							),
							]
						);
					}
				  );
			},
          ),
      ),),
	  Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(16.060865,-16.423448),
        builder: (ctx) => Container(
		  child: IconButton(
            icon: Icon(Icons.school),
              color: HexColor("#b35c35"),
              iconSize: 45.0,
              onPressed: () {
              showModalBottomSheet(
				context: context,
				builder: (builder){
					return new Wrap(
						children: [
						ListTile(
							leading: IconButton(
								icon: Icon(Icons.school),

								color: HexColor("#b35c35"),
								iconSize: 40.0,
								onPressed: () {}
							),
							title: Text('Amphi CRAC',
							textAlign: TextAlign.center,
							style: TextStyle(
								fontSize: 20.0,
								color: HexColor("#b35c35"),
							),
							),
						),
						ListTile(
							leading: IconButton(
							onPressed: () {},
							icon: Icon(Icons.location_on),
							),
							title: Text('BP 234 Saint-Louis'),
						),
						
						]
					);
				}
			);
			},
          ),
      ),),
    ];

    return Scaffold(
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
                    Navigator.of(context).pop(); //au clic, le menu se ferme
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
                      //Navigator.of(context).pop(); //au clic, le menu se ferme
                       //le menu se ferme et la carte de géolocalisation s'affiche
					   Navigator.push(
                          context, MaterialPageRoute(builder: (context) =>
                          LocalisationPage()));
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
		  actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () async {
              await Navigator.push(
									context, MaterialPageRoute(builder: (context) =>
									HomeScreen()));
            },
          ),
          Builder(builder: (ctx) {
            return IconButton(
              onPressed: () {},//=> roadActionBt(ctx),
              icon: Icon(Icons.map),
            );
          }),

        ],
         ),

	    body:
        Padding(
          padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [



                    DropDown(
                      items: [ugb, "Bibliothèque Universitaire", "Rectorat", "Scolarité", "Incubateur", "Restaurant_1", "Restaurant_2",  "Centre Médical",
															"CEA MITIC", "CCOS","Tour De L'oeuf", "Amphi A", "Amphi B", "Amphi C", "Amphi Crac", "Piscine Olympique",
															"Maison de l'université", "IFOAD", "CPU", "Antenne de DAKAR", "CRDS", "UFR CRAC", "UFR SAT", "UFR 2S", "UFR LSH",
																"UFR SJP", "UFR SEG", "UFR SEFS", "IPSL",  "UFR S2ATA", "Ferme agricole"],
                      hint: Text("Trouver un lieu..."),
                      icon: Icon(
                        Icons.expand_more,
                        color: HexColor("#b35c35"),
                      ),
											onChanged: (dynamic newValue) {
												setState(() {
													selectedMarker = newValue;
													_mapController.move(selectedMarker, 19.0);
													new Marker(
															point: selectedMarker,
															builder: (ctx) => Container(
																	child: IconButton(
																		icon: const Icon(Icons.location_on),
																		color: Colors.red,
																		iconSize: 30.0,
																		onPressed: () {},
																	),
															),
													);
												}
												);
											}
										),
					Flexible(
					  child: FlutterMap(
						options: MapOptions(
							center: LatLng(16.061851,-16.422973),
							zoom: 19.0,
							interactiveFlags: interActiveFlags,
							plugins: [
								ScaleLayerPlugin(),
								ZoomButtonsPlugin(),
							],
					    ),
						nonRotatedLayers: [
						  ScaleLayerPluginOption(
							lineColor: Colors.blue,
							lineWidth: 2,
							textStyle: TextStyle(color: Colors.blue, fontSize: 12),
							padding: EdgeInsets.all(10),
						  ),
						  ZoomButtonsPluginOption(
							minZoom: 4,
							maxZoom: 19,
							mini: true,
							padding: 10,
							alignment: Alignment.bottomRight,
						  ),
					  ],
					  layers: [
						TileLayerOptions(
							urlTemplate: layerToggle ? layer1 : layer2,
							subdomains: ['a', 'b', 'c'],
							tileProvider: NonCachingNetworkTileProvider(),
						),
						MarkerLayerOptions(markers: markers),
					  ],

					 ),
					),
                    Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: _serviceError!.isEmpty
                          ? Text("Vous êtes à l'Université Gaston Berger de Saint-Louis actuellement à la position: "
                          '(${currentLatLng.latitude}, ${currentLatLng.longitude}).')
                          : Text(
                          "Une erreur s'est produite lors de l'acquisition de la position. Message d'erreur "
                              '$_serviceError'),
                    )
				  ],
				),
		),
    );
  }
}