import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import '../gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;

  int _offset = 0;

  void _searchHandler(String value) {
    setState(() {
      _offset = 0;
      _search = value;
    });
  }

  void _loadNext() {
    setState(() {
      _offset += 19;
    });
  }

  Future<Map> _getGifs() async {
    http.Response response;

    if (isEmptySearch()) {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=YiNmq9WaJDtPDNFT6dyWlBQpT2Jmz7yo&limit=20&rating=G");
    } else {
      print("Procurar por $_search com offset de $_offset");

      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=YiNmq9WaJDtPDNFT6dyWlBQpT2Jmz7yo&q=$_search&limit=19&offset=$_offset&rating=G&lang=en");
    }
    return json.decode(response.body);
  }

  bool isEmptySearch() {
    return _search == null || _search.isEmpty;
  }

  int _getCount(Map data) {
    return isEmptySearch()
        ? data["pagination"]["count"]
        : data["pagination"]["count"] + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            TextField(
              onSubmitted: _searchHandler,
              decoration: InputDecoration(
                  labelText: "Pesquisar Gifs!",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  labelStyle: TextStyle(
                    color: Colors.white,
                  )),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                decorationColor: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: FutureBuilder(
                  future: _getGifs(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          width: 200.0,
                          height: 200.0,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 5.0,
                          ),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Container();
                        } else {
                          return _createGifTable(context, snapshot);
                        }
                    }
                  }),
            ))
          ],
        ),
      ),
    );
  }

  Widget _createGifTable(context, snapshot) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data),
        itemBuilder: (context, index) {
          if (isEmptySearch() || index < snapshot.data["pagination"]["count"]) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                  height: 300.0,
                  fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
            );
          } else {
            return GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  Text(
                    "Carregar mais...",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  )
                ],
              ),
              onTap: () {
                _loadNext();
              },
            );
          }
        });
  }
}
