import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebVeiwContainer extends  StatefulWidget {
  const WebVeiwContainer({super.key});

  @override
  State<WebVeiwContainer> createState() => _WebVeiwContainerState();
}

class _WebVeiwContainerState extends State<WebVeiwContainer> {

  //initialize web view controller
  final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..loadRequest(Uri.parse('https://localhost:3306/dashboard/'));
  // ..loadRequest(Uri.parse('https://www.youtube.com/watch?v=wPf-7rrng-8/'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Campus 1'),),
      body: WebViewWidget(controller: controller,),
    );
  }
}
