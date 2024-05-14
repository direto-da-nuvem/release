import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:dduff/controllers/login_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dduff/ui/views/queue_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dduff/controllers/dashboard_controller.dart';
import 'package:dduff/controllers/login_controller.dart';
import 'package:dduff/routes/app_pages.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() {return _LoginPageState();}
}


class _LoginPageState extends State<LoginPage> {


  bool deviceConfigured = Get.arguments;
  bool isLoading = false;
  final storage = FirebaseStorage.instance;

  void playQueue() async{
    startedTimer = false;
    String currentQueue = await getDeviceQueue();
    Get.offAndToNamed(Routes.SHOWCASE, arguments: [currentQueue,false,false]);
  }

  Future<String> getDeviceQueue() async{
    dynamic requests = await storage.ref().child("queue_devices.txt").getData();
    var selectedQueue = 'default'; //queueDeviceFromString("MeuDispositivo",utf8.decode(requests));
    return selectedQueue;
  }

  String queueDeviceFromString(deviceName, savedData){
    List<String> allQueues = savedData.split('*');
    String ans = '';
    bool gotAnswer = false;
    allQueues.forEach((element) {
      if(element.removeAllWhitespace != ''){
        print(element);
        List<String> splitQueueData = element.split(';');
        if(splitQueueData[0]==deviceName && !gotAnswer){
          print('GOT');
          ans =  splitQueueData[1]; gotAnswer = true;
        }
      }
    });
    print('ANSWER:');
    print(ans);
    return ans;
  }

  Widget possibleButton(bool loggedIn, Widget w){
    if(!loggedIn){return Text("Log in", style: TextStyle(fontSize: 25));}
    return w;
  }

  bool startedTimer = false;
  void countDown(){
    Future.delayed(Duration(seconds: 45), () async {
      if(startedTimer == true && !Get.arguments[0]){
      startedTimer = false;
      String queue = await getDeviceQueue();
      Get.offAndToNamed(Routes.SHOWCASE, arguments: [queue,false]);}
    });
  }

  bool purposeful = false;
  void loginbutton(){
    startedTimer = false;
    purposeful = true;
  } //TO-DO: Set purposeful to false when leaving state

  @override
  Widget build(BuildContext context) {
    if(startedTimer == false &&  purposeful == false){
      countDown();
      startedTimer = true;
    }
    return isLoading? Center(child: CircularProgressIndicator()): GetBuilder<LoginController>(
        init: Get.put(LoginController()),
        builder: (loginController) {
          print(deviceConfigured);
          print(Get.arguments);
          loginController.setDeviceConfigured(deviceConfigured);
          return Scaffold(
              appBar: AppBar(toolbarHeight: 10,),
              body: Center(
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Color.fromARGB(100, 199, 209, 241), // Cor da borda vermelha
                            width: 16.0, // Largura da borda
                          ),

                          borderRadius: BorderRadius.circular(20.0)

                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Container(
                                  padding:const EdgeInsets.fromLTRB(25,25,25,25) ,
                                  child: SvgPicture.asset(
                                      "assets/logo.svg",
                                      ),
                                ),
                              ),
                              possibleButton(deviceConfigured, Padding(
                                padding: const EdgeInsets.fromLTRB(2,0,2,0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0), // Define o raio das bordas
                                    ),
                                  ),

                                  onPressed: playQueue,
                                  child: const SizedBox(
                                      height: 30,
                                      width: 450,
                                      child: SizedBox(
                                        //width:0,
                                        //height: 10,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(width: 100),
                                            Icon(Icons.play_arrow_outlined),
                                            Text("Tocar fila atual",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500
                                                )
                                            ),
                                            SizedBox(width: 100),
                                          ],
                                        ),)
                                  ),
                                ),
                              )),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(2,5,2,0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0), // Define o raio das bordas
                                    ),
                                  ),

                                  onPressed: (){loginbutton();loginController.signInWithGoogle();},
                                  child: const SizedBox(
                                      height: 40,
                                      width: 450,
                                      child: SizedBox(
                                        //width:0,
                                        //height: 10,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(width: 100),
                                            Icon(FontAwesomeIcons.google),
                                            Text("Sign in with Google",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500
                                                )
                                            ),
                                            SizedBox(width: 100),
                                          ],
                                        ),)
                                  ),
                                ),
                              ),
                            ]
                        ),
                      )
                  )
              )
          );
        }
    );
  }
}

