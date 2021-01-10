import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/Home.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {

  //Controladores
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mengagemErro = "";
  Usuario usuario = Usuario();

  _validarCampos(){

    //Recupera dados dos campos
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(nome.isNotEmpty){

        if(email.isNotEmpty && email.contains("@")){

          if(senha.isNotEmpty && senha.length > 6){

            setState(() {
              _mengagemErro = "";
            });

            usuario.nome = nome;
            usuario.email = email;
            usuario.senha = senha;
            _cadastrar(usuario);

          }else{
            setState(() {
              _mengagemErro = "Preencha uma senha! digite mais de 6 caracteres";
            });
          }

        }else{
            setState(() {
              _mengagemErro = "Preencha o E-mail utilizando @";
            });
        }

    }else{
      setState(() {
        _mengagemErro = "Preencha o Nome";
      });
    }
  }

  _cadastrar(Usuario usuario){

      FirebaseAuth auth = FirebaseAuth.instance;

      auth.createUserWithEmailAndPassword(
          email: usuario.email,
          password: usuario.senha
      ).then((firebaseUser){

        //Salvar dados do usuário
        FirebaseFirestore db = FirebaseFirestore.instance;
        db.collection("usuarios")
        .doc(firebaseUser.user.uid)
        .set(usuario.toMap());

        Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.ROTA_HOME, (_) => false);

      }).catchError((error){
          print("erro: "+ error.toString());
          setState(() {
            _mengagemErro = "Erro ao cadastrar usuário, verifique os campos e cadastre novamente";
          });
      });

    //Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
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
                    "imagens/usuario.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
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
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
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
                  obscureText: true,
                  keyboardType: TextInputType.text,
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
                        "Cadastrar",
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
                          _validarCampos();
                      }
                  ),
                ),
                Center(
                  child: Text(
                    _mengagemErro,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20
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
