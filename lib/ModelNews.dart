
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';


class NewsDetails extends StatefulWidget {
  const NewsDetails({Key? key, required this.title, required this.url})
      : super(key: key);
  final String title;
  final String url;
  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: Expanded(
          child: WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        )));
  }
}
