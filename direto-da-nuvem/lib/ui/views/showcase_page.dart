import 'dart:convert';
import 'dart:io';
import 'package:io/io.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dduff/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


class ShowcasePage extends StatefulWidget {
  const ShowcasePage({Key? key}) : super(key: key);


  @override
  State<ShowcasePage> createState(){
    return _ShowcasePageState();}
}

class AnimationData{
  String name;
  Curve curve;
  int durationMilliseconds;
  int getDuration(){return durationMilliseconds;}
  AnimationData({required this.name, required this.curve, required this.durationMilliseconds});
}

class _ShowcasePageState extends State<ShowcasePage> {
  var currentQueueFile = (Get.arguments[0])+"_Requests.txt";
  bool signedIn = Get.arguments[1];

  String selectedItem = "ShowcasePage";
  bool isLoading = true;

  final List<Image> imageAssets = <Image>[];
  List<String> RequestedImages = <String>[];

  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  bool instQueue = false;

  Future<void> getImageData() async { //get the data from all the images
    if(currentQueueFile=="InstallationQueue_Requests.txt"){instQueue = true;
      if(Get.arguments[2]){RequestedImages = ["5.png"];}else{ //In this case, when the argument passed is 1, then the queue is the tutorial queue (images 5.png)
    RequestedImages = ["1.png","2.png","3.png","4.png"];} //In this case, when the argument passed is 1, then the queue is the installation queue (images 1.png - 4.png). TO-DO: Make this not hardcoded
    //TO-DO: Edit above structures
}
    else{
      await loadCacheMetadata();
    await getRequestedImages();}
    for(String imagePath in RequestedImages){
     await getImage(imagePath);
      developer.log("FINISHED LOADING IMAGE $imagePath");}
    finishedLoading();
    return;
  }

  List<String> defaultImages = <String>['cat.jpg','rocket.jpg','lake.jpg']; //backup in case regular default queue does not work and a device ends up w/o queue
  FirebaseFirestore firestore = FirebaseFirestore.instance; //TO-DO: Update the backup system shown above

  List<String>? cachedElements = [];
  SharedPreferences? prefs;

  Future<void> loadCacheMetadata() async{ //called once when page is about to get built, to see if a image of the queue is already stored locally
    prefs = await SharedPreferences.getInstance();
    cachedElements = await prefs?.getStringList('Downloaded_Images');
    if(cachedElements == null){cachedElements = [];}
  }

  Future<void> getImage(String element) async{ //gets the data from a specific image
    if (!cachedElements!.contains(element)) {
      dynamic i = await storage.ref().child(element).getData();
      await downloadImage(i, element);
      await insertDataIntoCache(element, i);

      print('DID NOT FOUND IMAGE IN CACHE ' + element );
    }

      //then gets data normally. this could prob be done more efficiently. TO-DO
      dynamic imgData = await getImageFromCache(element);

      //TEMP
      // imgData = await storage.ref().child(element).getData();
      //TEMP
      Image im = Image.memory(imgData, fit: BoxFit.cover); //adds a image i to the image.memory instead of from
                                                      //can i get i from gallery instead? and always?
      imageAssets.add(im);
  }



  Future<dynamic> getImageFromCache(String imageName) async{
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$imageName');
      if (await file.exists()) {
        print('Got File From Cache');
      return await file.readAsBytes();

      }
      else {
        print('Image not found: $imageName');
        print('Getting it from firebase instead.');
        return await storage.ref().child(imageName).getData();
      }
    } catch (e) {
    print('Error retrieving image: $imageName ";  " $e');
    print('Getting it from firebase instead.');
    return await storage.ref().child(imageName).getData();
    }
  }

  Future<void> downloadImage(var imageData, String imageName) async{
    final directory = await getApplicationDocumentsDirectory();
    var file = File('${directory.path}/$imageName');
    await file.writeAsBytes(imageData);
  }

  Future<void> insertDataIntoCache(String element, var imageData) async{ //inserts a new image which is being downloaded into the cache
    cachedElements!.add(element);
    prefs = await SharedPreferences.getInstance();

    //Adds the new element to the Cache, and then salves that updated Cache to local storage
    await prefs?.setStringList('Downloaded_Images', cachedElements!);
  }

  Future<void> getRequestedImages() async{
    String qname = Get.arguments[0];
    var c = await firestore.collection('queue').where('name',isEqualTo: qname).get();
    var newQueueDocRef = c.docs[0].reference;
    queueScreenTime = c.docs[0].data()['screenTime'];
    animEffectByName(c.docs[0].data()['entryEffect']);

    //newQueueDocRef, at this point, is a reference to the Queue that is being played in this page.
    //after getting nqdr as well as its metadata, we then get all its images, which are stored in the 'images' sub-collection (check firebase)

    var c2 = await newQueueDocRef.collection('images').get(); //change c2 name eventually TO-DO
    RequestedImages = [];
    for(int i =0; i<c2.docs.length;i++){
      if(c2.docs[i].data()['present']){
      RequestedImages.add(c2.docs[i].data()['imagePath']);}
    }
    //RequestedImages is a list of paths to the image in firebase Storage (not firestore!)

    if(RequestedImages.length<1){RequestedImages = defaultImages;print('No requests found, selected default images to play.');}
    return;
  }

  void goBack(){
    if(!instQueue){
      if(!signedIn){Get.offAndToNamed(Routes.LOGIN, arguments: true);}
      else{Get.offAndToNamed(Routes.DASHBOARD, arguments: currentQueueFile);}
    }
    else{
      if(!Get.arguments[2]){
        Get.offAndToNamed(Routes.SHOWCASE, arguments: ["InstallationQueue",false, true]);
      }else{
      Get.offAndToNamed(Routes.LOGIN, arguments: false);}
    }
  }

  void finishedLoading(){setState(() {
    isLoading = false;
  });}

  bool gotImages = false;
  int gindex = 0;

  void animEffectByName(String effect){ //TO-DO: criar um map pra essas animações para fazer as consultas de maneira mais rapido
    if(effect == "instantaneous"){animationCurve = Curves.linear;  durationMilliseconds = 500;enlargeStrategy = CenterPageEnlargeStrategy.height; return;} //TO-DO: change this for a switch case eventually
    if(effect == "bounce"){animationCurve = Curves.bounceOut;  enlargeStrategy = CenterPageEnlargeStrategy.height; durationMilliseconds = 1600; return;}
    if(effect == "slide"){animationCurve = Curves.easeOutExpo; enlargeCenter = false; durationMilliseconds = 3200; return;}
    if(effect == "grow"){animationCurve = Curves.easeInOutCubicEmphasized;  durationMilliseconds = 2800; enlargeFactor = 0.8; return;}
    if(effect == "fast"){animationCurve = Curves.easeInOutCubicEmphasized; enlargeCenter = false;  durationMilliseconds = 3200; return;}
    if(effect == "elastic"){animationCurve = Curves.elasticInOut;  enlargeStrategy = CenterPageEnlargeStrategy.zoom;durationMilliseconds = 2400; return;}
    if(effect == "slow"){animationCurve = Curves.easeInOutSine;  durationMilliseconds = 1600; return;}
    if(effect == "preview"){animationCurve = Curves.slowMiddle;  durationMilliseconds = 1000;  enlargeFactor = 0.6;enlargeStrategy = CenterPageEnlargeStrategy.zoom; enlargeCenter = true;return;}//linearToEaseOut
    if(effect == "vertical"){animationCurve = Curves.linearToEaseOut; enlargeStrategy = CenterPageEnlargeStrategy.zoom; enlargeCenter = true; enlargeFactor = 0.5; durationMilliseconds = 1100;scrollDirection = Axis.vertical;}//linearToEaseOut
    if(effect == "inverted vertical"){animationCurve = Curves.linearToEaseOut; enlargeStrategy = CenterPageEnlargeStrategy.zoom;reverse = true; enlargeCenter = true; enlargeFactor = 0.5; durationMilliseconds = 1100;scrollDirection = Axis.vertical;}//linearToEaseOut
    if(effect == "backwards"){animationCurve = Curves.linearToEaseOut;  durationMilliseconds = 900; reverse = true; return;}//linearToEaseOut
    if(effect == "default"){animationCurve = Curves.linearToEaseOut;  durationMilliseconds = 900; return;}//linearToEaseOut
    animationCurve = Curves.linear;  durationMilliseconds = 800; //default
  }

  Curve animationCurve = Curves.linear;
  int durationMilliseconds = 100;
  CenterPageEnlargeStrategy enlargeStrategy = CenterPageEnlargeStrategy.scale;
  bool enlargeCenter = true;
  bool reverse = false;
  double enlargeFactor = 0.4;
  Axis scrollDirection = Axis.horizontal;

  dynamic tempImages;
  int queueScreenTime = 15;
  int getTimeForImage(int index){return queueScreenTime;}

  @override

  Widget build(BuildContext context) {
   print('building');
    if(!gotImages){
    getImageData();
    gotImages = true;
    print(imageAssets.length);
    }

    return Scaffold(
      backgroundColor: Colors.black38,
      body: isLoading ? const Center(child: CircularProgressIndicator()) : GestureDetector(
        onDoubleTap: ()=>goBack(),
        child: CarouselSlider.builder(
          options: CarouselOptions(
            height: 2500,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: getTimeForImage(gindex)),
            enlargeCenterPage: enlargeCenter,
            reverse: reverse,
            enlargeStrategy: enlargeStrategy,
            enlargeFactor: enlargeFactor,
            viewportFraction: 1,
            autoPlayCurve:  animationCurve,
            scrollDirection: scrollDirection,
            autoPlayAnimationDuration: Duration(milliseconds: durationMilliseconds),),
          itemCount: imageAssets.length,
          itemBuilder: (context,index,realIndex){
            gindex = index;
            return imageAssets[index];
            },
        ),
      ),
    );
  }
}



