import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dduff/controllers/dashboard_controller.dart';
import 'package:dduff/controllers/login_controller.dart';
import 'package:dduff/routes/app_pages.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Itens do popMenuButton
enum MenuItem { itemOne }

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedItem = "Dashboard";
  String selectedQueue = "default";
  bool gotQueue = false;

  void getDeviceQueue() async{
    gotQueue = true;
    String correctQueue = await getFirstQueueMappedToDevice();
    //print(correctQueue);
    //dynamic requests = await storage.ref().child("queue_devices.txt").getData();
    selectedQueue = correctQueue;//queueDeviceFromString("MeuDispositivo",utf8.decode(requests));
    finishedGettingQueue = true;
    //print(deviceName);
    setState(() {});
  }

  final Images = ["assets/photos/cat.jpg","assets/photos/rocket.jpg","assets/photos/lake.jpg"];

  bool admin = false;
  bool isLoading = true;
  final storage = FirebaseStorage.instance;
  String? deviceId = 'MeuDispositivo';
  String? deviceName = 'MeuDispositivo';
  final deviceInfoPlugin = DeviceInfoPlugin();
  dynamic deviceInfo;


  void checkIfAdmin(String userEmail) async{
    //loadDeviceInfo();
    isLoading = true;
    //print('Elements');

    dynamic admins = await storage.ref().child("admin_emails.txt").getData();

    //deviceId = await D.getDeviceId().toString();
    //print('Elements');

    String sAdmins = utf8.decode(admins);
    List<String> files = sAdmins.toString().split('\n');

    List<String> systemAdmins = [];
    for(int i = 0; i<files.length;i++)
    {
      if(files[i].removeAllWhitespace !='' && files[i] != Null && files[i] != ' ' && files[i] != '')
      {
        systemAdmins.add(files[i]);
      }
    }
    userEmailP = userEmail;
    systemAdmins.forEach((element) {print(element);print(element==userEmail);});
    admin = false;
    try{
      admin = systemAdmins.contains(userEmail);}catch(_){}
    gotAdminStatus = true;
    isLoading = false;
    re();
  }
  String userEmailP = "";
  void being_logout(){
    try{
      GoogleSignIn().signOut();
      FirebaseAuth.instance.signOut();
      LoginController().backToLogin();
      Get.offAndToNamed(Routes.LOGIN, arguments: true);
    }catch(error){}
    Get.offAndToNamed(Routes.LOGIN, arguments: true);
  }

  void re(){
    setState(() {

    });
  }

  Future<String> getFirstQueueMappedToDevice() async{
    //dynamic requests = await storage.ref().child("queue_data.txt").getData();;//queuesFromString(utf8.decode(requests));
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String dId = await getDeviceId();
    var c = await firestore.collection('devices').doc(dId);
    var mappedQueueId;
    var mappedQueue;
    await c.get().then(
            (DocumentSnapshot doc) {
          final dataa = doc.data() as Map<String, dynamic>;
          mappedQueueId = dataa['queue']; print(mappedQueueId); print(dataa['queue']);
          deviceName = dataa['name'];
        });
    c = await firestore.collection('queue').doc(mappedQueueId);
    await c.get().then(
            (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          mappedQueue = data['name'];
        });
    return mappedQueue;
  }

  Future<String> getDeviceId() async{
    //dynamic requests = await storage.ref().child("queue_data.txt").getData();;//queuesFromString(utf8.decode(requests));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    deviceId = prefs.getString('deviceId');
    if (deviceId==null){return "MeuDispositivo#1";}
    else {return deviceId!;}
  }

  void edit_images(){

    Get.offAndToNamed(Routes.EDIT,arguments: [selectedQueue,true]);
  }
  void edit_queues(bool admin, String userEmail){
    Get.offAndToNamed(Routes.QUEUE, arguments: [admin,userEmail]);
  }
  void view_images(){
    Get.offAndToNamed(Routes.SHOWCASE,arguments: [selectedQueue,true, false]);
  }
  void manage_admin_list(){
    Get.offAndToNamed(Routes.ADMIN);
  }

  void acessNotifications(){
    Get.offAndToNamed(Routes.NOTIFICATIONS, arguments: [selectedQueue,true]);
  } void accessAbout(){
    Get.offAndToNamed(Routes.ABOUT, arguments: [selectedQueue,true]);
  }

  List<Widget> buttonsFromAdminStatus(bool admin){
    List<Widget> children = <Widget>[];
    children.add(ElevatedButton(onPressed: () => view_images(), child: Text('Tocar fila')));
    Widget queueButton = ElevatedButton(onPressed: () => edit_queues(admin, userEmailP), child: Text('Gerenciar filas'));
    children.add(Container(width: 10,));
    children.add(queueButton);
    if(admin){



      Widget adminButton = ElevatedButton(onPressed: () => manage_admin_list(), child: Text('Gerenciar Super Admins'));
      children.add(Container(width: 10,));
      children.add(adminButton);


    }
    children.add(Container(width: 10,));
    children.add(ElevatedButton(onPressed: () => being_logout(), child: Text('Logout')));
    return children;
  }

  bool gotAdminStatus = false;
  bool gotAuthData = false;
  var currentAuth;

  String adminSuffix(bool admin){
    if(!admin){return '';}
    return '  (Super Admin)';
  }

  Widget loadUserContext() {
    return GetBuilder<DashboardController>(
        init: Get.put(DashboardController()),
        builder: (homeController) {
          return GetBuilder<LoginController>(
              init: Get.put(LoginController()),
              builder: (loginController) {
                currentAuth = loginController.auth;
                if(currentAuth!=null){
                  gotAuthData = true;}
                checkIfAdmin(currentAuth.currentUser!.email!);
                return Scaffold(
                    appBar: AppBar(title: Text('Direto da UFF')),
                    body: (!isLoading)? Column(
                      children: [
                        Text(''),
                        Text('Current User:   ' + currentAuth.currentUser!.displayName!),
                        Text('Current Email:   ' + currentAuth.currentUser!.email! + adminSuffix(admin)),
                        Text(''),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: buttonsFromAdminStatus(currentAuth),
                          ),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ) : Center(child: CircularProgressIndicator())
                );
              }
          );
        }
    );
  } //widget temporario que carrega emquanto busca dados


  bool created = false;
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  bool finishedGettingQueue = false;

  String StringNotNull(String? s){if (s==null){return "";} return s;}

  @override
  Widget build(BuildContext context) {

    if(!gotAuthData) {
      return loadUserContext();
    }
    if(!gotQueue){
      getDeviceQueue();
    }
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title:
          Text("Direto da UFF"),
          centerTitle: false,
        ),
        body: (!isLoading && finishedGettingQueue)?
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 7, 12, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 16,),
                      Text('Usuário atual:  ' + currentAuth.currentUser!.displayName! + adminSuffix(admin)),
                      Text('Dispositivo: ' + StringNotNull(deviceName)),
                       Text("Fila: " + selectedQueue),
                      Text(''),
                      Text(''),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Row(
                          children: buttonsFromAdminStatus(admin),
                        ),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          IconButton(onPressed: (){accessAbout();}, icon: Icon(Icons.info_outline)),
                          Text("Sobre",style: TextStyle(color:Colors.black45, fontSize: 10),),

                        ],
                      ),
                      SizedBox(width:  10,),
                      Column(
                        children: [
                          IconButton(onPressed: (){acessNotifications();}, icon: Icon(Icons.notifications)),
                          Text("Notificações",style: TextStyle(color:Colors.black45, fontSize: 10),),

                        ],
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ) : Center(child: CircularProgressIndicator())
    );
  }
}


