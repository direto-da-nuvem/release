import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:dduff/controllers/login_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '../../routes/app_pages.dart';
import 'package:flutter/material.dart';
import '../../controllers/firestore_helper.dart';

Future<void> goBack() async {
  //go back
  queueLoaded = false;
  Get.offAndToNamed(Routes.DASHBOARD);
}

final storage = FirebaseStorage.instance;
bool queueLoaded = false;

class Queue {
  String name;
  String id;
  String adminEmail;
  bool monitored;
  Queue(
      {required this.name,
      required this.id,
      required this.adminEmail,
      required this.monitored});
}

class QueueListPage extends StatefulWidget {
  const QueueListPage({Key? key}) : super(key: key);

  @override
  _QueueListPageState createState() => _QueueListPageState();
}

class _QueueListPageState extends State<QueueListPage> {
  List<Queue> queues = <Queue>[];
  List<String> deviceIds = <String>[];
  List<String> deviceNames = <String>[];
  List<String> devices = <String>[];
  bool isAdmin = false;

  void getQueueData() async {
    //dynamic requests = await storage.ref().child("queue_data.txt").getData();;//queuesFromString(utf8.decode(requests));
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var c = await firestore.collection('queue').get();
    bool universalAdmin = Get.arguments[0];
    isAdmin = universalAdmin;
    String userEmail = Get.arguments[1];
    for (int i = 0; i < c.docs.length; i++) {
      Queue q = Queue(
          name: c.docs[i].data()['name'],
          id: c.docs[i].data()['name'].toString().removeAllWhitespace,
          adminEmail: c.docs[i].data()['admin'],
          monitored: c.docs[i].data()['monitored']);
      print(userEmail == c.docs[i].data()['email']);
      var v = await c.docs[i].reference
          .collection('admins')
          .where('email', isEqualTo: userEmail)
          .get();

      if (universalAdmin || v.docs.length > 0) {
        queues.add(q);
      }
      print(q.toString());
    }

    var d = await firestore.collection('devices').get();
    for (int i = 0; i < d.docs.length; i++) {
      String dId = d.docs[i].data()['serial'];
      devices.add(dId);
      deviceIds.add(dId);
      deviceNames.add(d.docs[i].data()['name']);
    }

    queueLoaded = true;
    queueLoading = false;
    if (triedOnce && queues.length > 0) {
      triedOnce = false;
    }
    setState(() {});
  }

  bool queueLoading = false;
  bool triedOnce = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String getDevString(Queue q) {
    return "TBD";
    // var c = await firestore.collection('queue').get();
    // for(int i =0; i<c.docs.length;i++){
    //   var newQueueDocRef = c.docs[i].reference;
    //   var c2 = await newQueueDocRef.collection('images').where('imagePath',isEqualTo: "a").get();
    //   if(c2.docs.length>0){return "a";}
    // }
  }

  @override
  Widget build(BuildContext context) {
    print('m ' + queueLoaded.toString());
    print(queues.length);
    if (!queueLoaded && !queueLoading) {
      queueLoading = true;
      getQueueData();
    } else if (!triedOnce && queues.length == 0 && Get.arguments[0]) {
      getQueueData();
    }
    return queueLoaded
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              toolbarHeight: 50,
              title: Text("Gerenciar Filas"),
              centerTitle: false,
              leading: IconButton(
                  onPressed: () => goBack(), icon: Icon(Icons.arrow_back)),
            ),
            body: ListView.builder(
              itemCount: queues.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 4.0), // Add margin for spacing
                      child: ListTile(
                        title: Text(queues[index].name),
                        //subtitle: Text('Dispositivos: ${getDevString(queues[index])}\nAdmins: ${queues[index].adminEmail}'),
                        onTap: () {
                          // Navigate to a page where the user can edit the selected queue
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QueueEditPage(
                                queue: queues[index],
                                deviceIds: deviceIds,
                                deviceNames: deviceNames,
                                isAdmin: isAdmin,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13.5),
                      child: Container(
                          width: 400,
                          child: Divider(height: 1.0, thickness: 1.0)),
                    ), // Add a line between tiles
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Navigate to a page where the user can create a new queue
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QueueCreatePage(),
                  ),
                );
              },
              child: Icon(Icons.add),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              title: Text("Gerenciar Filas"),
              centerTitle: false,
              leading: IconButton(
                  onPressed: () => goBack(), icon: Icon(Icons.arrow_back)),
            ),
            body: Center(child: CircularProgressIndicator()));
  }
}

class QueueEditPage extends StatefulWidget {
  final Queue queue;
  final List<String> deviceNames;
  final List<String> deviceIds;
  final bool isAdmin;

  QueueEditPage(
      {required this.queue,
      required this.deviceNames,
      required this.deviceIds,
      required this.isAdmin});

  @override
  _QueueEditPageState createState() => _QueueEditPageState();
}

class _QueueEditPageState extends State<QueueEditPage> {
  late TextEditingController nameController;
  late TextEditingController deviceController;
  late TextEditingController adminEmailController;

  List<DropdownMenuItem<String>> deviceOptionItems =
      <DropdownMenuItem<String>>[];
  String _dropdownValue = "";

  void getStartingValues() async {
    _dropdownValue = "none";
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.queue.name);
  }

  @override
  Widget build(BuildContext context) {
    if (_dropdownValue == "") {
      getStartingValues();
    }
    deviceOptionItems = <DropdownMenuItem<String>>[];
    deviceOptionItems
        .add(DropdownMenuItem(child: Text("Nenhum "), value: "none"));

    for (int i = 0; i < widget.deviceNames.length; i++) {
      print(widget.deviceNames[i]);
      deviceOptionItems.add(DropdownMenuItem(
          child: Text(widget.deviceNames[i]), value: widget.deviceIds[i]));
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Editar Fila'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            Row(
              children: [
                Text("Adicionar novo dispositivo:  "),
                DropdownButton(
                    items: deviceOptionItems,
                    value: _dropdownValue,
                    onChanged: (String? value) {
                      if (value is String) {
                        print(value);
                        setState(() {
                          _dropdownValue = value;
                        });
                      }
                    }),
              ],
            ),
            Text(
              "Escolha um dos dispositivos acima se você quiser que esta fila passe a tocar nele.",
              style: TextStyle(color: Colors.black45, fontSize: 11),
            ),
            SizedBox(
              height: 0,
            ),
            Row(
              children: [
                Text("Monitorada:"),
                Checkbox(
                    value: widget.queue.monitored,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null) {
                          widget.queue.monitored = value;
                        }
                      });
                    }),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Save the changes and pop the page
                    _dropdownValue;
                    _saveQueueInfo(_dropdownValue, nameController.text,
                        widget.queue.name, widget.queue.monitored);
                  },
                  child: Text('Salvar Mudanças'),
                ),
                SizedBox(
                  width: 12,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Save the changes and pop the page
                    queueLoaded = false;
                    Get.offAndToNamed(Routes.EDIT,
                        arguments: [widget.queue.id, false]);
                  },
                  child: Text('Editar Imagens da Fila'),
                ),
                SizedBox(
                  width: 12,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Save the changes and pop the page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QueueAnimationPage(queue: widget.queue),
                      ),
                    );
                  },
                  child: Text('Editar Animações da Fila'),
                ),
                SizedBox(
                  width: 12,
                ),
                getWidget(
                  widget.isAdmin,
                  ElevatedButton(
                    onPressed: () {
                      // Save the changes and pop the page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QueueAdminsPage(queue: widget.queue),
                        ),
                      );
                    },
                    child: Text('Gerenciar admins da Fila'),
                  ),
                ),
                
              ],
            ),
            getWidget(
                   widget.isAdmin,
                   ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Deletar Fila"),
                              content: Text(
                                  "Tem certeza que deseja deletar essa fila? Filas deletedas não podem ser recuperadas"),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      deleteData_deleteDocs(); // firestore_helper.dart
                                    },
                                    child: Text("Deletar Fila"))
                              ],
                            );
                          });
                    },
                    child: Text('Deletar Fila'),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget getWidget(bool b, Widget w) {
    if (b) {
      return w;
    }
    return SizedBox();
  }

  void _saveQueueInfo(String? deviceIdChosen, String qname, String oldName,
      bool monitored) async {
    if (qname.isNotEmpty) {
      // Access Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      if (deviceIdChosen == null || deviceIdChosen.removeAllWhitespace == "") {
        deviceIdChosen = "none";
      }
      // Add device information to Firestore

      var c = await firestore
          .collection('queue')
          .where('name', isEqualTo: oldName)
          .get();
      var newQueueDocRef = c.docs[0].reference;
      newQueueDocRef.update({'name': qname, 'monitored': monitored});
      String qId = c.docs[0].id;
      //code here that will update admins of queue

      if (deviceIdChosen.toLowerCase() != "none") {
        String deviceId = deviceIdFromName(deviceIdChosen);
        await firestore.collection('devices').doc(deviceId).update({
          'queue': qId,
        });
      }

      // Show a snackbar indicating successful save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dados da fila atualizada com sucesso!'),
        ),
      );

      Navigator.pop(context);
      Get.offAndToNamed(Routes.QUEUE, arguments: 1);
    } else {
      // Show an error snackbar if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String deviceIdFromName(String name) {
    return name;
  }
}

class QueueCreatePage extends StatefulWidget {
  @override
  _QueueCreatePageState createState() => _QueueCreatePageState();
}

class _QueueCreatePageState extends State<QueueCreatePage> {
  late TextEditingController nameController;
  late TextEditingController deviceController;
  late TextEditingController adminEmailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    deviceController = TextEditingController();
    adminEmailController = TextEditingController();
  }

  String deviceIdFromName(String name) {
    return name;
  }

  String queueIdFromName(String name) {
    return '';
  }

  //add a new queue
  void _createNewQueue(String qname, String adminEmail, Queue newQueue) async {
    if (qname.isNotEmpty) {
      // Access Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Add device information to Firestore
      DocumentReference<Map<String, dynamic>> newQueueDocRef =
          await firestore.collection('queue').add({
        'name': qname,
        'admin': adminEmail,
        'entryEffect': "default",
        'screenTime': 10,
        'monitored': false
      });

      var c = await firestore
          .collection('queue')
          .where('name', isEqualTo: qname)
          .get();
      newQueueDocRef = c.docs[0].reference;

      CollectionReference<Map<String, dynamic>> imagesSubcollection =
          await newQueueDocRef.collection('images');
      await imagesSubcollection.doc('STI-Inovação1080p.png').set({
        'imagePath': 'STI-Inovação1080p.png',
        'timestamp': FieldValue.serverTimestamp(),
        'timeOnScreenSeconds': 5,
        'animEntryEffect': 0,
        'animExitEffect': 0,
        'order': 0,
        'present': true
      });

      // Show a snackbar indicating successful save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fila criada com sucesso!'),
        ),
      );

      Navigator.pop(context);
      Get.offAndToNamed(Routes.QUEUE, arguments: 1);
    } else {
      // Show an error snackbar if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void alterQueueDevice(String deviceId, String qId) async {
    await firestore.collection('devices').doc(deviceId).update({
      'queue': qId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Criar Fila'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: adminEmailController,
              decoration: InputDecoration(labelText: 'Emails dos admins'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Create a new queue and add it to the list
                Queue newQueue = Queue(
                    name: nameController.text,
                    id: nameController.text.removeAllWhitespace,
                    adminEmail: adminEmailController.text,
                    monitored: true);
                _createNewQueue(newQueue.name, newQueue.adminEmail, newQueue);
              },
              child: Text('Create Queue'),
            ),
          ],
        ),
      ),
    );
  }
}

class QueueAnimationPage extends StatefulWidget {
  final Queue queue;

  QueueAnimationPage({required this.queue});

  @override
  _QueueAnimationPageState createState() => _QueueAnimationPageState();
}

class _QueueAnimationPageState extends State<QueueAnimationPage> {
  late TextEditingController nameController;
  late TextEditingController deviceController;
  late TextEditingController adminEmailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.queue.name);
    adminEmailController = TextEditingController(text: widget.queue.adminEmail);
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String capitalize(String original) {
    return " ${original[0].toUpperCase()}${original.substring(1).toLowerCase()}";
  }

  List<String> animationOptions = [
    "default",
    "instantaneous",
    "bounce",
    "slide",
    "grow",
    "fast",
    "elastic",
    "slow",
    "preview",
    "vertical",
    "inverted vertical",
    "backwards"
  ];
  List<DropdownMenuItem<String>> animationOptionItems =
      <DropdownMenuItem<String>>[];

  String _dropdownValue = "default";
  Widget _buildTextField(
      String label, String hint, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: 400,
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String timeOnScreen = "5";
  String entryEffect = "";
  String exitEffect = "";

  void updateQueueConfiguration(String entryEffect, int screenTime,
      bool effectUnspecified, bool STUnspecified, String qname) async {
    var c = await firestore
        .collection('queue')
        .where('name', isEqualTo: qname)
        .get();
    var newQueueDocRef = c.docs[0].reference;

    if (effectUnspecified && STUnspecified) {
      return;
    }

    if (effectUnspecified) {
      newQueueDocRef.update({
        'screenTime': screenTime,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Animação atualizada com sucesso!'),
        ),
      );
      return;
    }

    if (STUnspecified) {
      newQueueDocRef.update({'entryEffect': entryEffect});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Animação atualizada com sucesso!'),
        ),
      );
      return;
    }
    newQueueDocRef
        .update({'screenTime': screenTime, 'entryEffect': entryEffect});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Animação atualizada com sucesso!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    animationOptionItems = <DropdownMenuItem<String>>[];
    animationOptions.forEach((element) {
      animationOptionItems.add(
          DropdownMenuItem(child: Text(capitalize(element)), value: element));
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Modificar Animações da Fila'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField("Tempo em que cada imagem fica na tela",
                    "Escreva em segundos:", (value) {
                  timeOnScreen = value;
                }),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Text("Escolha Nova Animação:  "),
                    DropdownButton(
                        items: animationOptionItems,
                        value: _dropdownValue,
                        onChanged: (String? value) {
                          if (value is String) {
                            print(value);
                            entryEffect = value;
                            setState(() {
                              _dropdownValue = value;
                            });
                          }
                        }),
                  ],
                ),
                Text(
                  "Animações determinam a forma como imagens são exibidas durante o playback das filas.",
                  style: TextStyle(color: Colors.black45, fontSize: 11),
                )
              ],
            ),

            ElevatedButton(
              onPressed: () {
                bool effectUnspecified = (entryEffect == null ||
                    entryEffect.removeAllWhitespace == "");
                bool STUnspecified =
                    (timeOnScreen == null || int.parse(timeOnScreen) < 1);

                print(effectUnspecified);
                print(STUnspecified);

                // Perform any logic with the entered data
                print("Time On Screen: $timeOnScreen");
                print("Entry Effect: $entryEffect");

                updateQueueConfiguration(entryEffect, int.parse(timeOnScreen),
                    effectUnspecified, STUnspecified, widget.queue.name);
              },
              child: Text('Salvar Mudanças'),
            ),
            //_buildTextField("Entry Effect", "Enter entry effect", (value) {
            //  entryEffect = value;
            //}),
          ],
        ),
      ),
    );
  }
}

class QueueAdminsPage extends StatefulWidget {
  final Queue queue;

  QueueAdminsPage({required this.queue});

  @override
  _QueueAdminsPageState createState() => _QueueAdminsPageState();
}

class _QueueAdminsPageState extends State<QueueAdminsPage> {
  late TextEditingController nameController;
  late TextEditingController deviceController;
  late TextEditingController adminEmailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.queue.name);
    adminEmailController = TextEditingController(text: widget.queue.adminEmail);
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String capitalize(String original) {
    return " ${original[0].toUpperCase()}${original.substring(1).toLowerCase()}";
  }

  List<String> animationOptions = [
    "default",
    "instantaneous",
    "bounce",
    "slide",
    "grow",
    "fast",
    "elastic",
    "slow",
    "preview",
    "vertical",
    "inverted vertical",
    "backwards"
  ];
  List<DropdownMenuItem<String>> animationOptionItems =
      <DropdownMenuItem<String>>[];

  String _dropdownValue = "default";
  Widget _buildTextField(
      String label, String hint, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: 400,
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String timeOnScreen = "5";
  String entryEffect = "";
  String exitEffect = "";

  void addAdminToQueue(
      bool emailUnspecified, String qname, String email) async {
    var c = await firestore
        .collection('queue')
        .where('name', isEqualTo: qname)
        .get();
    var newQueueDocRef = c.docs[0].reference;

    if (emailUnspecified) {
      print('');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Escolha o email do admin primeiro.'),
        ),
      );
      return;
    }

    c.docs[0].reference.collection('admins').add({'email': email});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Admin adicionado com sucesso!'),
      ),
    );
  }

  void removeAdminFromQueue(
      bool emailUnspecified, String qname, String email) async {
    var c = await firestore
        .collection('queue')
        .where('name', isEqualTo: qname)
        .get();
    var newQueueDocRef = c.docs[0].reference;

    if (emailUnspecified) {
      print('');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insira o email do email à ser removido da fila.'),
        ),
      );
      return;
    }

    var d = c.docs[0].reference
        .collection('admins')
        .where('email', isEqualTo: email)
        .get();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro na remoção de admin, tente denovo novamente.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    animationOptionItems = <DropdownMenuItem<String>>[];
    animationOptions.forEach((element) {
      animationOptionItems.add(
          DropdownMenuItem(child: Text(capitalize(element)), value: element));
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Gerenciar Admins da Fila'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                    "Adicionar ou remover admin", "Escreva email do admin:",
                    (value) {
                  timeOnScreen = value;
                }),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Admins tem o poder de modificar o conteúdo e as politicas de playback das filas.\nCaso queira controlar as modificações feitas pelos admins, marque a fila como moderada na tela anterior.",
                  style: TextStyle(color: Colors.black45, fontSize: 11),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 0,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          addAdminToQueue(timeOnScreen == null,
                              widget.queue.name, timeOnScreen);
                        },
                        child: Text("Adicionar")),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(onPressed: () {}, child: Text("Remover")),
                  ],
                ),
              ],
            ),

            //_buildTextField("Entry Effect", "Enter entry effect", (value) {
            //  entryEffect = value;
            //}),
          ],
        ),
      ),
    );
  }
}
