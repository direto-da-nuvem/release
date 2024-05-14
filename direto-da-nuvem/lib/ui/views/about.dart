import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../routes/app_pages.dart';



class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  Future<void> goBack() async{
    Get.offAndToNamed(Routes.DASHBOARD,arguments: Get.arguments[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 50, title: Text("Sobre o Direto Da UFF"), centerTitle: false,leading: IconButton(onPressed: (){goBack();}, icon: Icon(Icons.arrow_back)),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("\nDireto da UFF é um sistema desenvolvido pelo STI e SCS, visando promover a propagação de informativos, images e anúncios nos campus universitários. \nCréditos para:"),
            SizedBox(height: 9,),

            Text("-Desenvolvedores: Guilherme Lacerda"),
            Text("-Coordenador: Cosme Faria Correia"),
            Text("-Suporte: Marcos Fernandes, Rafael Delgado, Ronald Sampaio, Victor Gabriel, Cleuson de Oliveira"),
            Text("-Arte: Joaquim Guedes, Carolina Oliveira"),
          ],
        ),
      ),
    );
  }
}

