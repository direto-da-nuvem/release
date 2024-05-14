import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dduff/routes/app_pages.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoginController extends GetxController {
  bool _ButtonPressed = false;
  bool deviceConfigured = true;

  bool get ButtonPressed => _ButtonPressed;

  void setDeviceConfigured(bool d){
    deviceConfigured = d;
  }

  set ButtonPressed(bool value) {
    _ButtonPressed = value;
  } //changed this. if code breaks, try reverting back

  final admin = false;
  final auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserCredential? userCredential;

  void pressButton(){ButtonPressed = true;}
  void backToLogin(){ButtonPressed = false;}


  @override
  void onReady() {
    if (auth.currentUser != null && ButtonPressed) {
      debugPrint("${auth.currentUser!.displayName}");
      print(deviceConfigured);
      if(deviceConfigured){
      Get.offAndToNamed(Routes.DASHBOARD);}
      else{
        Get.offAndToNamed(Routes.DEVICES);
      }
    }

    super.onReady();
  }

  Future<void> signInWithGoogle() async {
    pressButton();
    if (auth.currentUser != null) {
      try {
        await auth.signOut();
        Get.snackbar(
          "Desconectado",
          "",
          backgroundColor: Colors.white,
        );
        update();
        Get.offAndToNamed(Routes.LOGIN, arguments: deviceConfigured);
        await googleSignIn.signOut();
      } catch(e) {
        debugPrint("ERRO deslogando:\n$e");
      }
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      debugPrint('googleUser: $googleUser');
      debugPrint('googleAuth: $googleAuth');
      userCredential = await auth.signInWithCredential(credential);
      update();
      if(deviceConfigured){
        Get.offAndToNamed(Routes.DASHBOARD);}
      else{
        Get.offAndToNamed(Routes.DEVICES);
      }
    }
    debugPrint('userCredential: $userCredential');
    debugPrint('auth: $auth');
    //debugPrint('email: ${userCredential!.user!.email}');//

    update();
  }


}