import 'dart:io';
import 'package:share/share.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({Key? key}) : super(key: key);

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List hits = [];

  void fetchImages(String text) async {
    final Response response = await Dio().get(
        'https://pixabay.com/api/?key=31242248-aa026ed2c957cd180dd5d5805&q=$text+flowers&image_type=photo');
    hits = response.data['hits'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchImages('花');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: '花',
          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text) {
            print(text);
            fetchImages(text);
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: hits.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> hit = hits[index];
          return InkWell(
            onTap: () async {
              Response response = await Dio().get(
                hit['webformatURL'],
                options: Options(responseType: ResponseType.bytes),
              );
              Directory dir = await getTemporaryDirectory();
              File file = await File('${dir.path} + /image.png')
                  .writeAsBytes(response.data);
              await Share.shareFiles([file.path]);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  hit['previewURL'],
                  fit: BoxFit.cover,
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.thumb_up_alt_outlined),
                            Text('${hit['likes']}'),
                          ],
                        ))),
              ],
            ),
          );
        },
      ),
    );
  }
}
