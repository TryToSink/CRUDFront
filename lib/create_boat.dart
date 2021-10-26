import 'dart:convert';
import 'dart:io';
import 'package:crud1310/appbar_widget.dart';
import 'package:crud1310/home.page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CreateBoat extends StatefulWidget {
  const CreateBoat({Key? key}) : super(key: key);

  @override
  State<CreateBoat> createState() => _CreateBoatState();
}

class _CreateBoatState extends State<CreateBoat> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  var _lista = [];

  late String url = 'http://3.144.90.4:3333/barcos/lista';
  late String urlPost = 'http://3.144.90.4:3333/barcos';

  void getBoat() async {
    try {
      final response = await http.get(Uri.parse(url));
      print(response.body);

      final jsonData = jsonDecode(response.body) as List;
      setState(() {
        _lista = jsonData;
      });
    } catch (error) {
      print('Deu erro no getBoat');
    }
  }

  void createBoat(String name, String size) async {
    try {
      final response = await http.post(
        Uri.parse(urlPost),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({
          'nome': name,
          'foto': '1234',
          'tamanho': size,
        }),
      );
      print('Chegou no create');
      print(response.body);
    } catch (error) {
      print(error);
      print('Deu erro no createBoat');
    }
  }

  void updateBoat() async {
    try {
      final response = await http.put(
        Uri.parse(urlPost),
        body: {
          'IDBarco': _lista[0]['IDBarco'],
          'nome': _nameController.text,
          'tamanho': _count,
        },
      );
      print(response.body);
    } catch (error) {
      print('Deu erro no updateBoat');
    }
  }

  final linhasColunas = 5;
  List _campo = [];
  bool _valid = true;
  late int _count = 0;

  Widget buildField(BuildContext context, int index) {
    double tamanho = 2;
    return GestureDetector(
        onTap: (){
          setState(() {
            _count++;
            _campo[index]["status"] = true;
          });
        },
        onDoubleTap: () {
          setState(() {
            if (_count == 0) {
              _valid = true;
            }

            _campo[index]["status"] = false;
            _count--;
          });
        },
        child: Container(
          color: _campo[index]["status"] ? Colors.blueAccent : Colors.black26,
          child: null,
        ));
  }

  void _addPosition(int x, int y) {
    setState(() {
      Map<String, dynamic> newPos = {};
      newPos["linha"] = x;
      newPos["coluna"] = y;
      newPos["status"] = false;
      newPos["ataque"] = false;

      _campo.add(newPos);
    });
  }

  void _laco(int x, int y, var func) {
    for (int i = 0; i < x; i++) {
      for (int j = 0; j < y; j++) {
        func(i, j);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    getBoat();
    _laco(linhasColunas, linhasColunas, _addPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (_, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: constraints.maxHeight * .5,
                    width: constraints.maxWidth ,
                    child: LayoutBuilder(
                      builder: (_, constraints3) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Nome',
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Container(
                                height: constraints3.maxHeight * .2,
                                child: Text(
                                  "Selecione na Grid o tamanho do Barco: $_count",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                            Container(
                              width: 100,
                              height: constraints3.maxHeight * .15,
                              child: ElevatedButton(
                                child: const Text('Salvar'),
                                onPressed: () {
                                  setState(() {
                                    createBoat(_nameController.text, _count.toString());
                                    Navigator.pop(context);
                                    //_count = int.parse(_sizeController.text);
                                  });
                                },
                              ),
                            )
                          ],
                        );
                      },
                    )),
                Container(
                  height: constraints.maxHeight * .4,
                  width: constraints.maxWidth * .8,
                  child: LayoutBuilder(
                    builder: (_, constraints2) {
                      return GridView.builder(
                          itemCount: _campo.length,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisExtent: constraints2.maxHeight * .15,
                              mainAxisSpacing: constraints2.maxHeight * .01,
                              crossAxisSpacing: constraints2.maxWidth * .01,
                              crossAxisCount: linhasColunas),
                          itemBuilder: buildField);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
