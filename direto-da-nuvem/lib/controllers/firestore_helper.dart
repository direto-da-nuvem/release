import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dduff/ui/views/queue_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

 void deleteData_deleteDocs() {
    // [START delete_data_delete_docs]
    FirebaseFirestore.instance.collection("queue").doc("this.queue").delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
    // [END delete_data_delete_docs]
  }
