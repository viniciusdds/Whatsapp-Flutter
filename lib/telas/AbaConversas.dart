import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {

  List<Conversa> _listaConversas = List();

  @override
  void initState() {
    super.initState();

    Conversa conversa = Conversa();
    conversa.nome = "Ana Julia";
    conversa.mensagem = "Olá tudo bem";
    conversa.caminhoFoto = "https://firebasestorage.googleapis.com/v0/b/whatsapp-4d83e.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=9b0f5c9a-a998-43c4-ac0b-b7e67aac8560";

    _listaConversas.add(conversa);

  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _listaConversas.length,
        itemBuilder: (context, index){
            Conversa conversa = _listaConversas[index];

            return ListTile(
              contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              leading: CircleAvatar(
                maxRadius: 30,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(conversa.caminhoFoto),
              ),
              title: Text(
                conversa.nome,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
              subtitle: Text(
                conversa.mensagem,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14
                ),
              ),
            );
        }
    );
  }
}
