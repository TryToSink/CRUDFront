import 'dart:convert';
import 'package:crud1310/create_boat.dart';
import 'package:crud1310/update_boat.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _Homepagestate createState() => _Homepagestate();
}

class _Homepagestate extends State<Homepage> {
  var _lista = [];
  var lista2 = [];

  late String url = 'http://3.144.90.4:3333/barcos/lista';
  late String urlDelete = 'http://3.144.90.4:3333/barcos';

  void getTest() async {
    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = jsonDecode(response.body) as List;
      setState(() {
        _lista = jsonData;
      });
    } catch (error) {}
  }

  Future deleteTest(String i, int index) async {
    Object barcoDelete = {
      "IDBarco": i,
    };

    try {
      if (i != "") {
        print("antes do envio " + i);
        final response = await http.delete(
          Uri.parse(urlDelete + "?IDBarco=" + i),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        print(i);
        print(response.body);
        print(_lista);
        return response;
      }
    } catch (error) {
      print("deu erro no response");
    }
  }

  @override
  void initState() {
    super.initState();
    getTest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("MODERADOR")),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: _lista.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return GestureDetector(
            onTap: () {
              print("tamanho da lista " + _lista.length.toString());
            },
            child: Dismissible(
                key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                onDismissed: (direction) {
                  setState(() {
                    print(_lista.toString());
                    print(index.toString() +
                        " " +
                        _lista[index]["nome"].toString());
                    deleteTest(_lista[index]["IDBarco"], index);
                    _lista.removeAt(index);
                  });
                },
                child: ListTile(
                  leading: Text((index + 1).toString()),
                  title: Text(_lista[index]["nome"]),
                  subtitle: Text(_lista[index]["tamanho"].toString()),
                  key: Key((_lista[index]["IDBarco"]).toString()),
                  trailing: Container(
                    width: 50,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.orange,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateBoat(
                                          idbarco: (_lista[index]["IDBarco"]),
                                          nomebarco: (_lista[index]["nome"]),
                                          nomeImagem: (_lista[index]["foto"]),
                                          tamanhobarco: (_lista[index]
                                                  ["tamanho"]
                                              .toString()),
                                        )));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                background: Container(
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment(-0.9, 0.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
                direction: DismissDirection.startToEnd),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateBoat(),
              ));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}
