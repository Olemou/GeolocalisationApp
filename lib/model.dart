
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';


class Modelnews{

  late String _title;
  late String _description;
  late String _pub;
  late String _linkpage;
  Modelnews( String description, String title,String pub,String link){
    _description=description;
    _title=title;
    _pub=pub;
    _linkpage=link;
  }


  String get linkpage {
    return _linkpage;
  }

  set linkpage(String value) {
    _linkpage = value;
  }

  String get pub => _pub;

  set pub(String value) {
    _pub = value;
  }

  String get description {
    return _description;
  }

  set description(String value) {
    _description = value;
  }

  String get title {
    return _title;
  }

  set title(String value) {
    _title = value;
  }


  static Future<List<Modelnews>> getRss() async {
    var data = await http.get(
        Uri.parse("https://www.ugb.sn/actualites.feed?type=rss"),
        headers: {
          "Content-Type":"application/json",
          'Charset':'utf-8'
        });

    var rssFeed = RssFeed.parse(data.body.toString());

    List<Modelnews> noticias = [];


    for (int i = 0; i < rssFeed.items.length; i++) {

      noticias.add(Modelnews( rssFeed.items[i].description,rssFeed.items[i].title,rssFeed.items[i].pubDate,rssFeed.items[i].link
      ));
    }

    return noticias;
  }
}