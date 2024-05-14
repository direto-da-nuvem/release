import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:dduff/controllers/login_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_pages.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({Key? key}) : super(key: key);

  @override
  _DeviceInfoPageState createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _deviceLocationController =
  TextEditingController();

  final deviceInfoPlugin = DeviceInfoPlugin();
  dynamic deviceInfo;

  Future<String> loadDeviceInfo() async{
    deviceInfo = await deviceInfoPlugin.androidInfo;
    return deviceInfo.serialNumber.toString();
  }

  //TO-DO: Incluir 5a imagem com o texto "Bem vindo ao Direto da UFF!", "Para finalizar a instalação, é nescessário dar permissão de overlay para este aplicativo. Você pode encontrar esta opção no menu do sistema operacional." ou algo assim sla

  void _saveDeviceInfo() async {
    String deviceName = _deviceNameController.text;
    String deviceLocation = _deviceLocationController.text;
    String deviceSerial = await loadDeviceInfo();
    //print('SERIAL:');
    //print(deviceSerial);

    //Get.offAndToNamed(Routes.DASHBOARD);


    if (deviceName.isNotEmpty && deviceLocation.isNotEmpty) {
      // Access Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var tstamp = FieldValue.serverTimestamp();
      // Add device information to Firestore
      DocumentReference newQueueDocRef = await firestore.collection('devices').add({
        'name': deviceName,
        'queue': '8AKvDCetBMYBxKPcKJCb', //fila default
        'timestamp': tstamp,
        'location': deviceLocation,
        'serial': deviceSerial //fix this later
      });
      await firestore.collection('devices').doc(newQueueDocRef.id).set({
        'name': deviceName,
        'queue': '8AKvDCetBMYBxKPcKJCb',
        'timestamp': tstamp,
        'location': deviceLocation,
        'serial': newQueueDocRef.id //fix this later
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceId', newQueueDocRef.id);




      // Show a snackbar indicating successful save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Device information saved successfully!'),
        ),
      );

      Get.offAndToNamed(Routes.DASHBOARD);

      // Clear input fields
      _deviceNameController.clear();
      _deviceLocationController.clear();
    }
    else {

      // Show an error snackbar if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void goBack(){
    Get.offAndToNamed(Routes.SHOWCASE, arguments: "InstallationQueue");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text('Register New Device'),
          leading: IconButton(onPressed: ()=> goBack(), icon: Icon(Icons.arrow_back))
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _deviceNameController,
              decoration: InputDecoration(labelText: 'Device Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _deviceLocationController,
              decoration: InputDecoration(labelText: 'Device Location'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveDeviceInfo,
              child: Text('Register Device'),
            ),
          ],
        ),
      ),
    );
  }
}