import 'dart:convert';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:dduff/controllers/login_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_pages.dart';
class StartPage extends StatefulWidget {

  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  bool deviceConfigured = true;
  bool checkingDevice = false;

  Future<bool> isConfigured() async {
    //look into shared preferences, if null then return false
    //TO-DO: Also make sure device Id is associated to a device in firebase
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('deviceId');
    return !(deviceId == null);
  }

  void checkIfDeviceConfigured() async{
    deviceConfigured = await isConfigured();
    if(!deviceConfigured){
      Future.delayed(Duration.zero, () async {
        Get.offAndToNamed(Routes.SHOWCASE, arguments: ["InstallationQueue",false, false]);
      });}
    else{
      Future.delayed(Duration.zero, () async {
        Get.offAndToNamed(Routes.LOGIN, arguments: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!checkingDevice){
      checkingDevice = true;
      checkIfDeviceConfigured();
    }
    return Scaffold();
  }
}

