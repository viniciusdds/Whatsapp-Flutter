import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Mensagem.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Mensagens extends StatefulWidget {

  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {

  File _imagem;
  bool _subindoImagem = false;
  String idUsuarioLogado;
  String idUsuarioDestinatario;
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController _controllerMensagem = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  Widget _result;

  _enviarMensagem(){
    String textoMensagem = _controllerMensagem.text;
    if(textoMensagem.isNotEmpty){
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario  = idUsuarioLogado;
      mensagem.mensagem   = textoMensagem;
      mensagem.urlImagem  = "";
      mensagem.data       = Timestamp.now().toString();
      mensagem.tipo       = "texto";


      //Salvar mensagem para remetente
      _salvarMensagem(idUsuarioLogado, idUsuarioDestinatario, mensagem);

      //Salvar mensagem para destinatário
      _salvarMensagem(idUsuarioDestinatario, idUsuarioLogado, mensagem);

      //Salvar conversa
      _salvarConversa(mensagem);

    }
  }


  _salvarMensagem(String idRemetente, String idDestinatario, Mensagem msg) async {
    await db.collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    //Limpa texto
    _controllerMensagem.clear();
  }

  _enviarFoto()  {

    PickedFile imagemSelecionada;

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.image),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text("Imagens"),
                )
              ],
            ),
            content: Text("Escolha uma imagens"),
            actions: [
              FlatButton(
                child: Text("Câmera"),
                onPressed: () async {
                  ImagePicker _picker = ImagePicker();
                  imagemSelecionada = await _picker.getImage(source: ImageSource.camera);

                  _subindoImagem = true;

                  _uploadImagem(imagemSelecionada);

                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Galeria"),
                onPressed: () async {

                  ImagePicker _picker = ImagePicker();
                  imagemSelecionada = await _picker.getImage(source: ImageSource.gallery);

                  _subindoImagem = true;

                  _uploadImagem(imagemSelecionada);

                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }

  Future _uploadImagem(PickedFile imagemSelecionada) async {

    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
    firebase_storage.Reference pastaRaiz = firebase_storage.FirebaseStorage.instance.ref();
    firebase_storage.Reference arquivo = pastaRaiz
        .child("mensagens")
        .child(idUsuarioLogado)
        .child(nomeImagem+".jpg");

    firebase_storage.UploadTask task = arquivo.putFile(File(imagemSelecionada.path));

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

    Mensagem mensagem = Mensagem();
    mensagem.idUsuario  = idUsuarioLogado;
    mensagem.mensagem   = "";
    mensagem.urlImagem  = url;
    mensagem.data       = Timestamp.now().toString();
    mensagem.tipo       = "imagem";

    //Salvar mensagem para remetente
    _salvarMensagem(idUsuarioLogado, idUsuarioDestinatario, mensagem);

    //Salvar mensagem para destinatário
    _salvarMensagem(idUsuarioDestinatario, idUsuarioLogado, mensagem);

    //Salvar conversa
    _salvarConversa(mensagem);

  }

  _salvarConversa(Mensagem msg){

    //Salvar conversa remetente
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = idUsuarioLogado;
    cRemetente.idDestinatario = idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImage;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    //Salvar conversa destinatario
    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = idUsuarioDestinatario;
    cDestinatario.idDestinatario = idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.contato.nome;
    cDestinatario.caminhoFoto = widget.contato.urlImage;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();

  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    setState(() {
      idUsuarioLogado =  usuarioLogado.uid;
      idUsuarioDestinatario =  widget.contato.idUsuario;
    });

    _adicionarListenerMensagens();
  }

  Stream<QuerySnapshot> _adicionarListenerMensagens(){

    final stream = db.collection("mensagens")
        .doc( idUsuarioLogado )
        .collection(idUsuarioDestinatario)
         .orderBy("data", descending:  false)
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              maxRadius: 20,
              backgroundColor: Colors.grey,
              backgroundImage:
              widget.contato.urlImage != null ?
              NetworkImage(widget.contato.urlImage)
                  :
              null,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                widget.contato.nome,
                style: TextStyle(
                    fontSize: 15
                ),
              ),
            )

          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/bg.png"),
                fit: BoxFit.cover
            )
        ),
        child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(8),
              child:  Column(
                children: [

                  // STREAMBUILDER

                  StreamBuilder(
                    //stream: _controller.stream,
                    stream: _controller.stream,
                    builder: (context, snapshot){

                      switch(snapshot.connectionState){
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          _result = Center(
                            child: Column(
                              children: [
                                Text("Carregando contatos"),
                                CircularProgressIndicator()
                              ],
                            ),
                          );
                          break;
                        case ConnectionState.active:
                        case ConnectionState.done:

                          QuerySnapshot querySnapshot = snapshot.data;

                          if(snapshot.hasError){
                            _result = Expanded(
                              child: Text("Erro ao carregar os dados!"),
                            );
                          }else{
                            _result = Expanded(
                              child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: querySnapshot.docs.length,
                                  itemBuilder: (context, index){

                                    //Recupera mensagens
                                    List<DocumentSnapshot> mensagens = querySnapshot.docs.toList();
                                    DocumentSnapshot item = mensagens[index];

                                    double larguraContainer = MediaQuery.of(context).size.width * 0.8;

                                    //Define cores e alinhamentos
                                    Alignment alinhamento = Alignment.centerRight;
                                    Color cor = Color(0xffd2ffa5);

                                    if(idUsuarioLogado != item["idUsuario"]){
                                      alinhamento = Alignment.centerLeft;
                                      cor = Colors.white;
                                    }

                                    //print(item["urlImage"]);

                                    return Align(
                                      alignment: alinhamento,
                                      child: Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Container(
                                          width: larguraContainer,
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                              color: cor,
                                              borderRadius: BorderRadius.all(Radius.circular(8))
                                          ),
                                          child: item['tipo'] == "texto" ?
                                          Text(
                                            item["mensagem"],
                                            style: TextStyle(
                                                fontSize: 18
                                            ),
                                          )
                                              :
                                          Image.network(item["urlImagem"]),
                                        ),
                                      ),
                                    );

                                  }
                              ),
                            );
                          }

                          break;
                      }

                      return _result;
                    },
                  ),

                  // CAMPO DE TEXTO
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: TextField(
                              controller: _controllerMensagem,
                              autofocus: true,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                                  hintText: "Digite uma mensagem...",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32)
                                  ),
                                  prefixIcon: _subindoImagem ? CircularProgressIndicator()
                                  :
                                  IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: _enviarFoto
                                  )
                              ),
                            ),
                          ),
                        ),
                        Platform.isIOS
                            ? CupertinoButton(
                                  child: Text("Enviar"),
                                  onPressed: _enviarMensagem,
                              )
                            :  FloatingActionButton(
                                  backgroundColor: Color(0xff075e54),
                                  child: Icon(Icons.send, color: Colors.white),
                                  mini: true,
                                  onPressed: _enviarMensagem,
                                )
                      ],
                    ),
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}