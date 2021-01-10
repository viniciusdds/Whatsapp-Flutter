import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Home.dart';
import 'package:whatsapp/model/Usuario.dart';

class ValidacaoController {

      var verifyName;
      String mengagemErro = "";
      String email = "";
      String senha = "";
      Usuario usuario = Usuario();

      Future<String> validarCampos(String email, String senha, BuildContext context, String acesso, {String nome}) async{

      if(acesso != "Login"){
         verifyName = nome.isNotEmpty;
      }else{
         verifyName = acesso == "Login";
      }

      if(verifyName){

        if(email.isNotEmpty && email.contains("@")){

          if(senha.isNotEmpty && senha.length > 6){


              nome == null ? usuario.nome = "" : usuario.nome = nome;
              usuario.email = email;
              usuario.senha = senha;
              if(acesso == "Login"){
                  return logarUsuario(usuario, context);
              }else{
                  return cadastrar(usuario, context);
              }

          }else{
              return mengagemErro = "Preencha uma senha! digite mais de 6 caracteres";
          }

        }else{
            return mengagemErro = "Preencha o E-mail utilizando @";
        }

      }else{
           return mengagemErro = "Preencha o Nome";
      }
    }

    cadastrar(Usuario usuario, BuildContext context) async {

     FirebaseAuth auth = FirebaseAuth.instance;

     auth.createUserWithEmailAndPassword(
         email: usuario.email,
         password: usuario.senha
     ).then((firebaseUser){


       Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => Home()
           )
       );

     }).catchError((error){
       //print("erro: "+ error.toString());

        mengagemErro = "Erro ao cadastrar usuário, verifique os campos e cadastre novamente";

     });
   }

      Future<String> logarUsuario(Usuario usuario, BuildContext context) async {

      FirebaseAuth auth = FirebaseAuth.instance;

      try{

         auth.signInWithEmailAndPassword(
           email: usuario.email,
           password: usuario.senha
        );

//        Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) => Home()
//            )
//        );

         mengagemErro = "OK";
      }catch(e){
         print("error: "+e);
         mengagemErro = "Erro ao autenticar usuário, verifique e-mail e senha e tente novamente!";
         return mengagemErro;
      }

      return mengagemErro;


//      auth.signInWithEmailAndPassword(
//          email: usuario.email,
//          password: usuario.senha
//      ).then((firebaseUser){
//
//
//        Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) => Home()
//            )
//        );
//
//        mengagemErro = "OK";
//        usuario.mengagemErro = mengagemErro;
//        print("mengagemErro: "+mengagemErro);
//        return mengagemErro;
//
//      }).catchError((error)  {
//           print("erro: "+ error.toString());
//           mengagemErro = "Erro ao autenticar usuário, verifique e-mail e senha e tente novamente!";
//           usuario.mengagemErro = mengagemErro;
//           print("mengagemErro: "+mengagemErro);
//           return mengagemErro;
//      });


        
   }

}