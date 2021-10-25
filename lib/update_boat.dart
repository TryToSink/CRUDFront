import 'dart:convert';
import 'dart:io';

import 'package:crud1310/appbar_widget.dart';
import 'package:crud1310/home.page.dart';
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
      nomeImagem: nomeImagem);
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

//  Future getBoat(String i) async {
//    var barco = {
//      "IDBarco": "",
//      "nome": "",
//      "tamanho": "",
//      "foto": "",
//    };
//    print('entrou no getBoat');
//    print(i);
//    try {
//      final response = await http.get(
//        Uri.parse(url + "?IDBarco=" + i),
//        headers: <String, String>{
//          'Content-Type': 'application/json; charset=UTF-8',
//        },
//      );
//      print(response.body[0]);
  //      final jsonData = jsonDecode(response.body) as List;
//      print(barco);
  //   setState(() {
//        lista = jsonData;
//        _lista = response as List;
//      print(_lista);
  //   });
//   } catch (error) {
  //     print('Deu erro no getBoat');
  //   }
  //   return;
  // }

  void createBoat() async {
    try {
      final response = await http.post(Uri.parse(urlPut), body: {
        'IDBarco': _lista[0]['IDBarco'],
        'nome': _nameController.text,
        'tamanho': _count,
      });
      print(response.body);
    } catch (error) {
      print('Deu erro no postBoat');
    }
  }

  void updateBoat(String name, String size, String id) async {
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
  int _count = 12;

  Widget buildField(BuildContext context, int index) {
    double tamanho = 5;
    return GestureDetector(
        onTap: _valid
            ? () {
                setState(() {
                  if (_count > 0) {
                    _count--;
                    _campo[index]["status"] = true;
                    print(_campo);
                  } else
                    _valid = false;
                });
              }
            : null,
        onDoubleTap: () {
          setState(() {
            _campo[index]["status"] = false;
            _count++;
          });
        },
        child: Container(
          width: 10,
          height: 10,
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

    var stream = new http.ByteStream(DelegatingStream.typed(imageTemporary.openRead()));
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

    /*print('1');

    var postUri = Uri.parse(urlAttFoto);
    var request = new http.MultipartRequest("POST", postUri);
    request.fields['IDBarco'] = idbarco;
    print(imageTemporary);
    request.files.add(new http.MultipartFile.fromBytes('file', await imageTemporary));

    print('2');

    request.send().then((response) {
      if (response.statusCode == 200) print("Uploaded!");
    });*/
  }

  void getImagem() async {
    try {
      final response = await http.get(Uri.parse(urlImagem));
      final jsonData = jsonDecode(response.body) as List;
      setState(() {
        _lista = jsonData;
      });
    } catch (error) {}
  }

  @override
  void initState() {
    super.initState();
    print(nomeImagem);
    //getBoat(idbarco);
    _laco(linhasColunas, linhasColunas, _addPosition);
  }

  @override
  Widget build(BuildContext context) {
    _nameController = TextEditingController(text: nomebarco);
    _sizeController = TextEditingController(text: tamanhobarco);
    return Scaffold(
      appBar: buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (nomeImagem == '1234')
                  FlutterLogo()
                else
                  Image.network(
                    urlImagem,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                IconButton(
                    onPressed: uploadFile,
                    icon: Icon(Icons.upload_file, color: Colors.red))
              ],
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Nome',
              ),
            ),
            TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(
                hintText: 'Tamanho',
              ),
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () {
                setState(() {
                  updateBoat(
                      _nameController.text, _sizeController.text, idbarco);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Homepage()));
                  //_count = int.parse(_sizeController.text);
                });
              },
            ),
            Expanded(
              child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _campo.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: 50,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      crossAxisCount: linhasColunas),
                  itemBuilder: buildField),
            ),
          ],
        ),
      ),
    );
  }
}
