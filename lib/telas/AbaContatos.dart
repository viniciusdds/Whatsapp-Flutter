import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';

class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {

  List<Conversa> listaConversas = [
    Conversa(
        "Vinicius Damasceno",
        "Olá tudo bem",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-4d83e.appspot.com/o/perfil%2Fperfil6.jpg?alt=media&token=5de51d22-5aa7-429f-b491-53a9b5c4958d"
    ),
    Conversa(
        "Jaciara Damasceno",
        "Mais ou menos",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-4d83e.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=fb473cf0-d946-4cc4-b224-9aac4a24b46f"
    ),
    Conversa(
        "Diego Damasceno",
        "eeeeeeeh não sei",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-4d83e.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=7d4ae95a-b05e-441e-865f-8f9aad464870"
    ),
    Conversa(
        "Erika Damasceno",
        "Me manda o nome daquela serie",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-4d83e.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=9b0f5c9a-a998-43c4-ac0b-b7e67aac8560"
    ),
    Conversa(
        "Caio Damasceno",
        "hhh",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-4d83e.appspot.com/o/perfil%2Fperfil4.jpg?alt=media&token=2e09216d-e998-41c2-a6c5-03c8bcffb8fa"
    ),
    Conversa(
        "Jamilton Damasceno",
        "Sejam bem vindos",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-4d83e.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=222027a5-596b-4e2f-9fb3-36288cb8bb7b"
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: listaConversas.length,
        itemBuilder: (context, index){
          Conversa conversa = listaConversas[index];

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
          );
        }
    );
  }
}
