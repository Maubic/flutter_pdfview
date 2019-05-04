import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String pathPDF = "";

  @override
  void initState() {
    super.initState();
    createFileOfPdfUrl().then((f) {
      setState(() {
        pathPDF = f.path;
        print(pathPDF);
      });
    });
  }

  Future<File> createFileOfPdfUrl() async {
    final url =
        "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF View',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Builder(
          builder: (BuildContext context) {
            return RaisedButton(
              child: Text("Open PDF"),
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PDFScreen(pathPDF)),
                  ),
            );
          },
        )),
      ),
    );
  }
}

class PDFScreen extends StatelessWidget {
  final String pathPDF;
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Document"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: PDFView(
                filePath: pathPDF,
                swipeHorizontal: false,
                autoSpacing: true,
                onViewCreated: (PDFViewController pdfViewController) {
                  _controller.complete(pdfViewController);
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: FutureBuilder<PDFViewController>(
                future: _controller.future,
                builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: <Widget>[
                        FutureBuilder<int>(
                          future: snapshot.data.getPageCount(),
                          builder: (context, AsyncSnapshot<int> snapshot) {
                            if (snapshot.hasData)
                              return Text('${snapshot.data}');
                            return Container();
                          },
                        ),
                        RaisedButton(
                          child: Text('Go to 8'),
                          onPressed: () async {
                            await snapshot.data.setPage(16);
                          },
                        )
                      ],
                    );
                  }

                  return Container();
                },
              ),
            )
          ],
        ));
  }
}
