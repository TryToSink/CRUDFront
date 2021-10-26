import 'dart:convert';
import 'dart:io';

import 'package:crud1310/appbar_widget.dart';
import 'package:crud1310/home.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class UpdateBoat extends StatefulWidget {
  String idbarco;
  String nomebarco;
  String nomeImagem;
  String tamanhobarco;

  UpdateBoat(
      {Key? key,
      required this.idbarco,
      required this.nomebarco,
      required this.nomeImagem,
      required this.tamanhobarco})
      : super(key: key);

  @override
  State<UpdateBoat> createState() => _UpdateBoatState(
        idbarco: idbarco,
        nomebarco: nomebarco,
        tamanhobarco: tamanhobarco,
        nomeImagem: nomeImagem,
      );
}

class _UpdateBoatState extends State<UpdateBoat> {
  File? image;
  String idbarco;
  String nomebarco;
  String nomeImagem;
  String tamanhobarco;

  _UpdateBoatState({
    Key? key,
    required this.idbarco,
    required this.nomebarco,
    required this.nomeImagem,
    required this.tamanhobarco,
  });

  late TextEditingController _nameController = TextEditingController(text: "");
  late TextEditingController _sizeController = TextEditingController(text: "");
  var _lista = [];
  var lista = [];

  late String url = 'http://3.144.90.4:3333/barcos/find';
  late String urlImagem = 'http://3.144.90.4:3333/files/' + nomeImagem;
  late String urlPut = 'http://3.144.90.4:3333/barcos';
  late String urlAttFoto = 'http://3.144.90.4:3333/barcos/foto';

  Future getBoat(String id) async {
    var barco = {
      "IDBarco": "",
      "nome": "",
      "tamanho": "",
      "foto": "",
    };
    print('entrou no getBoat');
    print(id);
    try {
      final response = await http.get(
        Uri.parse(url + "?IDBarco=" + id),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print(response.body[0]);
      final jsonData = jsonDecode(response.body) as List;
      print(barco);
      setState(() {
        lista = jsonData;
        _lista = response as List;
        print(_lista);
      });
    } catch (error) {
      print('Deu erro no getBoat');
    }

    idbarco = (_lista[0]["IDBarco"]);
    nomebarco = (_lista[0]["nome"]);
    nomeImagem = (_lista[0]["foto"]);
    tamanhobarco = (_lista[0]["tamanho"].toString());

    setState(() {
      urlImagem = 'http://3.144.90.4:3333/files/' + nomeImagem;
      imageCache!.clear();
      imageCache!.clearLiveImages();
    });

    return;
  }

  void updateBoat(String name, String size, String id) async {
    getBoat(id);

    try {
      final response = await http.put(
        Uri.parse(urlPut),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({
          'IDBarco': id,
          'nome': name,
          'tamanho': size,
        }),
      );
      print(response.body);
    } catch (error) {
      print('$id, $name, $size, $urlPut');
      print('Deu erro no updateBoat');
    }
  }

  final linhasColunas = 5;
  List _campo = [];
  bool _valid = true;
  late int _count = int.parse(tamanhobarco);

  Widget buildField(BuildContext context, int index) {
    double tamanho = 5;
    return GestureDetector(
        onTap: () {
          setState(() {
            _count++;
            _campo[index]["status"] = true;
          });
        },
        onDoubleTap: () {
          setState(() {
            _campo[index]["status"] = false;
            _count--;
          });
        },
        child: Container(
          width: 10,
          height: 10,
          color: _campo[index]["status"] ? Colors.blueAccent : Colors.black26,
          child: null,
        ));
  }

  void _addPosition(int x, int y, int _cc) {
    setState(() {
      Map<String, dynamic> newPos = {};
      newPos["linha"] = x;
      newPos["coluna"] = y;
      if (_cc>0){
        newPos["status"] = true;
      } else newPos["status"] = false;
      newPos["ataque"] = false;


      _campo.add(newPos);
    });
  }

  void _laco(int x, int y, var func) {
    int _cc = _count;
    for (int i = 0; i < x; i++) {
      for (int j = 0; j < y; j++) {
        func(i, j, _cc);
        _cc--;
      }
    }
  }

  selecionarImagemGaleria() async {
    try {
      final imagemBarcoGaleria =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (imagemBarcoGaleria == null) return;

      final imageTemporary = File(imagemBarcoGaleria.path);
      setState(() => this.image = imageTemporary);
    } catch (e) {
      print(e);
    }
  }

  uploadFile() async {
    final imagemBarcoGaleria =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imagemBarcoGaleria == null) return;
    final imageTemporary = File(imagemBarcoGaleria.path);

    var stream =
        new http.ByteStream(DelegatingStream.typed(imageTemporary.openRead()));
    // get file length
    var length = await imageTemporary.length();

    // string to uri
    var uri = Uri.parse(urlAttFoto);

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('foto', stream, length,
        filename: basename(imageTemporary.path));

    // add file to multipart
    request.fields['IDBarco'] = idbarco;
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }


  @override
  void initState() {
    super.initState();
    //getBoat(idbarco);
    _laco(linhasColunas, linhasColunas, _addPosition);
  }

  @override
  Widget build(BuildContext context) {
    _nameController = TextEditingController(text: nomebarco);
    _sizeController = TextEditingController(text: tamanhobarco);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (_, constraints) {
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (nomeImagem == '1234')
                      Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/768px-No_image_available.svg.png",
                        height: constraints.maxHeight * .2,
                        fit: BoxFit.cover,
                      )
                    else
                      Image.network(
                        urlImagem,
                        height: constraints.maxHeight * .2,
                        fit: BoxFit.cover,
                        key: UniqueKey(),
                      ),
                    IconButton(
                        onPressed: uploadFile,
                        icon: Icon(Icons.upload_file, color: Colors.red))
                  ],
                ),
                Container(
                    height: constraints.maxHeight * .3,
                    width: constraints.maxWidth * .8,
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
                                height: constraints3.maxHeight * .3,
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
                                    updateBoat(_nameController.text,
                                        _count.toString(), idbarco);
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
                  height: constraints.maxHeight * .3,
                  width: constraints.maxWidth * .8,
                  child: LayoutBuilder(
                    builder: (_, constraints2) {
                      return GridView.builder(
                          itemCount: _campo.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  mainAxisExtent: constraints2.maxHeight * .2,
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
