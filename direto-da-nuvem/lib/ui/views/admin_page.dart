import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:dduff/controllers/login_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../routes/app_pages.dart';

class AdminPage extends StatefulWidget {

  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  var storage = FirebaseStorage.instance;


  String newAdmin = '';
  void saveToDatabase() async {
    if (newAdmin == '') {
      return;
    }
    isSaving = true;

    dynamic requests = await storage.ref().child('admin_emails.txt').getData();

    String sRequests = utf8.decode(requests);
    /*
    List<String> admins = <String>[];
    List<String> files = sRequests.toString().split('\n');
    if (files.length < 1) {
      print('No requests found, selected default images to edit.');
    }
    else {
      for (int i = 0; i < files.length; i++) {
        if (files[i].removeAllWhitespace != '' && files[i] != Null &&
            files[i] != ' ' && files[i] != '') {
          admins.add(files[i].replaceAll(" ", "").replaceAll("\n", ""));
        }
      }


    }*/
    sRequests += '\n$newAdmin';
    await storage.ref().child("admin_emails.txt").putString(sRequests);
    showDialog(context: context, builder:
        (context) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(true);
      });
      return AlertDialog(
        title: Text('Email Succesfully Added!'),
      );
    });
    isSaving = false;

  }

  void removeFromDatabase() async {
    if (newAdmin == '') {
      return;
    }
    isSaving = true;

    dynamic requests = await storage.ref().child('admin_emails.txt').getData();

    String sRequests = utf8.decode(requests);
    sRequests.split('\n').remove(newAdmin);
    await storage.ref().child("admin_emails.txt").putString(sRequests);
    showDialog(context: context, builder:
        (context) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(true);
      });
      return AlertDialog(
        title: Text('Email Succesfully Removed.'),
      );
    });
    isSaving = false;

  }

  Future<void> goBack() async{
    //go back
    if(!isSaving){
    Get.offAndToNamed(Routes.DASHBOARD);}
  }

  bool isSaving = false;

  Widget adminlist(){
    return Column();
  }//to implement eventually
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(toolbarHeight: 50, title: Text("Manage Super Admin List"), centerTitle: false,leading: IconButton(onPressed: ()=> goBack(), icon: Icon(Icons.arrow_back)),),
      body: Center(
        child: Column(
                children: [
                  Container(height:30),
                  Container(width: 500,child:
                  TextField(controller: TextEditingController(),
                    onChanged: (String texto) => newAdmin = texto,decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Input the super admin´s email',
                  ),)),
                  Container(height:15),
                  ElevatedButton(onPressed: ()=>saveToDatabase(), child: Container(width:200,child: Center(child: Text("Add to Super Admin List")))),
                  ElevatedButton(onPressed: ()=>removeFromDatabase(), child: Container(width:200, child: Center(child: Text("Remove from Super Admin List"))))
                ],
              ),
      ));
            //adminlist()
  }
}

