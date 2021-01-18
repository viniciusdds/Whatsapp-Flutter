import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/model/Usuario.dart';


class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {

  String _idUsuarioLogado;
  String _emailUsuarioLogado;
  Widget result;

  _recuperarDadosUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    _idUsuarioLogado = usuarioLogado.uid;
    _emailUsuarioLogado = usuarioLogado.email;

  }

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection("usuarios").get();

    List<Usuario> listaUsurios = List();

    for (DocumentSnapshot item in querySnapshot.docs) {
      var dados = item.data();
      if(dados["email"] == _emailUsuarioLogado){
        continue;
      }

      Usuario usuario = Usuario();
      usuario.idUsuario = item.id;
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.urlImage = dados["urlImage"];

      listaUsurios.add(usuario);
    }

    return listaUsurios;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
           result = Center(
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
             result = ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {

                  List<Usuario> listaItens = snapshot.data;
                  Usuario usuario = listaItens[index];

                  return ListTile(
                    onTap: (){
                       Navigator.pushNamed(context, RouteGenerator.ROTA_MENSAGENS, arguments: usuario);
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: usuario.urlImage != null ?
                          NetworkImage(usuario.urlImage)
                      :
                          null,
                    ),
                    title: Text(
                      usuario.nome,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                });
            break;
        }

        return result;
      },
    );
  }
}
