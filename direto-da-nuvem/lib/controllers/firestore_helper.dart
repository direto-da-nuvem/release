import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dduff/ui/views/queue_page.dart';

Future delete() async {
  final userCollection = FirebaseFirestore.instance.collection("queue");

  final deleteFunction = userCollection.doc("this.widget.queue").delete();
}
