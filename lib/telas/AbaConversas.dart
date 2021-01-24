import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/model/Usuario.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {

  List<Conversa> _listaConversas = List();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String _idUsuarioLogado;
  Widget _result;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();

    Conversa conversa = Conversa();
    conversa.nome = "Ana Clara";
    conversa.mensagem = "Olá tudo bem?";
    conversa.caminhoFoto = "https://firebasestorage.googleapis.com/v0/b/whatsapp-36cd8.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=97a6dbed-2ede-4d14-909f-9fe95df60e30";

    _listaConversas.add(conversa);

  }

  Stream<QuerySnapshot> _adicionarListenerConversas(){

    final stream = db.collection("conversas")
        .doc( _idUsuarioLogado )
        .collection("ultima_conversa")
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
    });

  }

  _recuperarDadosUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    setState(() {
      _idUsuarioLogado = usuarioLogado.uid;
    });

    _adicionarListenerConversas();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
             return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando conversas"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return  Text("Erro ao carregar os dados!");
            }else{

              QuerySnapshot querySnapshot = snapshot.data;

              if( querySnapshot.docs.length == 0 ){
                return  Center(
                  child: Text(
                    "Você não tem nenhuma mensagem ainda :( ",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return  ListView.builder(
                  itemCount: _listaConversas.length,
                  itemBuilder: (context, indice){

                    List<DocumentSnapshot> conversas = querySnapshot.documents.toList();
                    DocumentSnapshot item = conversas[indice];

                    String urlImagem  = item["caminhoFoto"];
                    String tipo       = item["tipoMensagem"];
                    String mensagem   = item["mensagem"];
                    String nome       = item["nome"];
                    String idDestinatario = item["idDestinatario"];

                    Usuario usuario = Usuario();
                    usuario.nome = nome;
                    usuario.urlImage = urlImagem;
                    usuario.idUsuario = idDestinatario;

                    return ListTile(
                      onTap: (){
                        Navigator.pushNamed(context, RouteGenerator.ROTA_MENSAGENS, arguments: usuario);
                      },
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: urlImagem!=null
                            ? NetworkImage( urlImagem )
                            : null,
                      ),
                      title: Text(
                        nome,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                      subtitle: Text(
                          tipo=="texto"
                              ? mensagem
                              : "Imagem...",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14
                          )
                      ),
                    );

                  }
              );

            }
            break;
        }

        return _result;
      },
    );


  }
}

