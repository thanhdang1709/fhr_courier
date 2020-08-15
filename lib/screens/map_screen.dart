import 'dart:async';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import '../config/palette.dart';
import '../widgets/custom_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 8.0.0; RNE-L22 Build/HUAWEIRNE-L22; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/75.0.3770.143 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/266.0.0.56.124;]';

//String selectedUrl = 'https://flutter.io';

class MapScreen extends StatefulWidget {
  String title;
  String url;
  MapScreen({Key key, this.title, this.url}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

// ignore: prefer_collection_literals
  final Set<JavascriptChannel> jsChannels = [
    JavascriptChannel(
        name: 'Print',
        onMessageReceived: (JavascriptMessage message) {
          print(message.message);
        }),
  ].toSet();

  final CookieManager cookieManager = CookieManager();

  bool _isLoadingPage;

  @override
  void initState() {
    this._isLoadingPage = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final key = UniqueKey();
    // clearCookies(webViewController, context);
    return Scaffold(
        backgroundColor: Palette.primaryColor,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: WebView(
          userAgent: kAndroidUserAgent,
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
            webViewController.clearCache();
            final cookieManager = CookieManager();
            cookieManager.clearCookies();
          },
          onPageFinished: (finish) {
            setState(() {
              _isLoadingPage = false;
            });
          },
        )
        // body: WebviewScaffold(
        //   url: selectedUrl,
        //   javascriptChannels: jsChannels,
        //   mediaPlaybackRequiresUserGesture: false,
        //   appBar: AppBar(
        //     title: const Text('Widget WebView'),
        //   ),
        //   withZoom: true,
        //   withLocalStorage: true,
        //   hidden: true,
        //   initialChild: Container(
        //     color: Colors.redAccent,
        //     child: const Center(
        //       child: Text('Waiting.....'),
        //     ),
        //   ),
        // )
        );
  }
}
