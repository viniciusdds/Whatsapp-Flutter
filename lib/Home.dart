import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'package:whatsapp/telas/AbaContatos.dart';
import 'package:whatsapp/telas/AbaConversas.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  TabController _tabController;
  List<String> itensMenu = [
    "Configurações",
    "Deslogar"
  ];

  String _emailUsuario = "";

  Future _recuperarDadosUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;

    setState(() {
      _emailUsuario = usuarioLogado.email;
    });

  }

  @override
  void initState() {
    super.initState();

    _recuperarDadosUsuario();
    
    _tabController = TabController(
        length: 2,
        vsync: this
    );
  }

  _escolhaMenuItem(String itemEscolhido){

    //print("Item escolhido: "+ itemEscolhido);

    switch(itemEscolhido){
      case "Configurações":
        Navigator.pushNamed(context, RouteGenerator.ROTA_CONFIGURACOES);
      break;
      case "Deslogar":
        _deslogarUsuario();
      break;
    }

  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WhatsApp"),
        bottom: TabBar(
            indicatorWeight: 4,
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Conversas"),
              Tab(text: "Contatos"),
            ]
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context){
                return itensMenu.map((String item){
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
          children: [
            AbaConversas(),
            AbaContatos()
          ],
      ),
    );
  }
}
