import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../routes/app_pages.dart';



class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<Map<String, dynamic>> notifications;
  late FirebaseFirestore firestore;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    notifications = [];

    // Fetch notifications from Firestore
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await firestore.collection('messages').get();
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");

    setState(() {
      notifications = querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> doc) {
        return {
          'id': doc.id,
          'message': doc['message'],
          'read': doc['read'] ?? false,
          'queue': doc['queue'],
          'timestamp': dateFormat.format((doc['timestamp'] as Timestamp).toDate())
          //'user': doc['user']
        };
      })
          .toList();
    });
  }

  Future<void> markAsRead(String id) async {
    await firestore.collection('messages').doc(id).update({'read': true});
    fetchNotifications();
  }

  Future<void> goBack() async{
    Get.offAndToNamed(Routes.DASHBOARD,arguments: Get.arguments[0]);
  }

  void revert(String oldName) async{
    //String queueId ="";
    //var c = await firestore.collection('queue').where('name',isEqualTo: oldName).get();
    //queueId = c.docs[0].id;
    Get.offAndToNamed(Routes.EDIT,arguments: [oldName,true]);

  }

  void stopmonitor(String oldName) async{
    var c = await firestore.collection('queue').where('name',isEqualTo: oldName).get();
    c.docs[0].reference.update({'monitored' : false});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fila não é mais monitorada.'),
      ),
    );

  }
  Future<void> showNotificationDialog(String message, String timestamp, String queue) async {
    String user = "gpaes@id.uff.br";
        return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
        return AlertDialog(
        title: Text('Nova atualização em uma Fila que você monitora:'
        ''),
        content: Text(message + "\n\n" + "Mudança acontenceu em " +timestamp+ "." + "\n" + "Mudança feita por " + user + "."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                revert(queue);
              },
              child: Text('Reverter'),
            ),
            TextButton(
              onPressed: () {
                stopmonitor(queue);
                Navigator.of(context).pop();
              },
              child: Text('Parar de monitorar fila'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceitar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 50, title: Text("Atualizações & Mensagens de Filas"), centerTitle: false,leading: IconButton(onPressed: (){goBack();}, icon: Icon(Icons.arrow_back)),),

      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Padding(
             padding: const EdgeInsets.all(6.0),
            child: Container(
              color:CupertinoColors.opaqueSeparator,
              child: ListTile(
                title: Text(
                  notifications[index]['message'],
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: notifications[index]['read']
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                onTap: () {
                  if (!notifications[index]['read']) {
                    markAsRead(notifications[index]['id']);
                  }
                  showNotificationDialog(notifications[index]['message'],notifications[index]['timestamp'],notifications[index]['queue']);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

