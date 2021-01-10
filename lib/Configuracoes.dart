import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {

  TextEditingController _controllerNome = TextEditingController();
  File _imagem;
  String _idUsuarioLogado;
  bool _subindoImagem = false;
  String _urlImagemRecuperada;

  Future _recuperarImagem(String origemImagem) async {

    PickedFile imagemSelecionada;
    ImagePicker _picker = ImagePicker();
    switch(origemImagem){
      case "camera":
          imagemSelecionada = await _picker.getImage(source: ImageSource.camera);
      break;
      case "galeria":
          imagemSelecionada = await _picker.getImage(source: ImageSource.gallery);
      break;
    }

    setState(() {
      _imagem = File(imagemSelecionada.path);
      if(_imagem != null){
          _subindoImagem = true;
          _uploadImagem();
      }
    });

  }

  Future _uploadImagem() async {

      firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
      firebase_storage.Reference pastaRaiz = firebase_storage.FirebaseStorage.instance.ref();
      firebase_storage.Reference arquivo = pastaRaiz
          .child("perfil")
          .child(_idUsuarioLogado+".jpg");

      firebase_storage.UploadTask task = arquivo.putFile(_imagem);

      //Controlar o progresso do upload
      task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshotEvents){

        if(snapshotEvents.state == firebase_storage.TaskState.running){
           setState(() {
              _subindoImagem = true;
           });
        }else if(snapshotEvents.state == firebase_storage.TaskState.success){
             setState(() {
               _subindoImagem = false;
             });
        }
      });

      //Recuperar url da imagem
      String snapshot = await (await task).ref.getDownloadURL();

      _recuperarUrlImagem(snapshot);

  }

  Future _recuperarUrlImagem(String snapshot) async {

    String url = await snapshot;
    _atualizarUrlImagemFirestore(url);

    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  _atualizarNomeFirestore(){

    String nome = _controllerNome.text;
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "nome": nome
    };

    db.collection("usuarios")
        .doc(_idUsuarioLogado)
        .update(dadosAtualizar);

  }

  _atualizarUrlImagemFirestore(String url){

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "urlImage": url
    };

    db.collection("usuarios")
        .doc(_idUsuarioLogado)
        .update(dadosAtualizar);

  }

  _recuperarDadosUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    _idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios").doc(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data();
    _controllerNome.text = dados["nome"];

    if(dados["urlImage"] != null){
      setState(() {
        _urlImagemRecuperada = dados["urlImage"];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configutações"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: _subindoImagem ?
                          CircularProgressIndicator()
                        :
                          Container(),
                 ),
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                    _urlImagemRecuperada != null ?
                      NetworkImage(_urlImagemRecuperada)
                  :
                      null
                  ,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: (){
                          _recuperarImagem("camera");
                        },
                        child: Text("Câmera")
                    ),
                    FlatButton(
                        onPressed: (){
                          _recuperarImagem("galeria");
                        },
                        child: Text("Galeria")
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
//                    onChanged: (text){
//                      _atualizarNomeFirestore(text);
//                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 31, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32)
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Salvar",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                        ),
                      ),
                      color: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)
                      ),
                      onPressed: (){
                          _atualizarNomeFirestore();
                      }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
