import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/Home.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'package:whatsapp/controller/validacao_controller.dart';

import 'model/Usuario.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  //Controladores
  TextEditingController _controllerEmail = TextEditingController(text: "vincyparker@gmail.com");
  TextEditingController _controllerSenha = TextEditingController();
  String _mengagemErro = "";
  ValidacaoController validarCampos = ValidacaoController();
  Usuario usuario = Usuario();

  _validarCampos(){

    //Recupera dados dos campos
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

      if(email.isNotEmpty && email.contains("@")){

        if(senha.isNotEmpty && senha.length > 6){

          setState(() {
            _mengagemErro = "";
          });

          usuario.email = email;
          usuario.senha = senha;
          _logarUsuario(usuario);

        }else{
          setState(() {
            _mengagemErro = "Preencha uma senha!";
          });
        }

      }else{
        setState(() {
          _mengagemErro = "Preencha o E-mail utilizando @";
        });
      }
  }

  _logarUsuario(Usuario usuario){

    FirebaseAuth auth = FirebaseAuth.instance;

    auth.signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then((firebaseUser) {
       Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);
    }).catchError((error){
        setState(() {
           _mengagemErro = "Erro ao autenticar usuário, verifique e-mail e senha e tente novamente!";
        });
    });

  }

  Future _verificaUsuarioLogado() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();

    User usuarioLogado = await auth.currentUser;
    if(usuarioLogado != null){
      Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);
    }

  }

  @override
  void initState() {
    _verificaUsuarioLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xff075E54)
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                      "imagens/logo.png",
                      width: 200,
                      height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 31, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)
                      )
                    ),
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 31, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                          "Entrar",
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
                      onPressed: () async {
                          _validarCampos();
                      }
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text(
                      "Não tem conta? cadastre-se!",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                    onTap: (){
                       Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => Cadastro())
                       );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _mengagemErro,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
