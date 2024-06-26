import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:toast/toast.dart';

void UpdateClassRoomStrength(String classRoomDocumentID,BuildContext context) {
  int strength;
  int present;
  int absent;
  print(classRoomDocumentID);
  FirebaseFirestore.instance.runTransaction((transaction) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('BabyData')
          .where('class_', isEqualTo: classRoomDocumentID)
          .get();
      strength = querySnapshot.size;

    querySnapshot = await FirebaseFirestore.instance
        .collection('BabyData')
        .where('class_', isEqualTo: classRoomDocumentID)
        .where('checkin', isEqualTo: "Checked In")
        .get();
      present = querySnapshot.size;
     querySnapshot = await FirebaseFirestore.instance
        .collection('BabyData')
        .where('class_', isEqualTo: classRoomDocumentID)
        .where('checkin', whereIn: ["Checked Out", "Absent"])
        .get();
      absent = querySnapshot.size;


    DocumentReference classRoomRef =
    FirebaseFirestore.instance.collection('ClassRoom').doc(classRoomDocumentID);
    transaction.update(classRoomRef, {
      'strength_': strength,
      'present_': present,
      'absent_': absent,
    });
  }).then((value) {
ToastContext().init(context);
    Toast.show('Strength Updated.',backgroundRadius: 3);
  }).catchError((error) {
// ToastContext().init(context);
    print('Error updating strength: $error');
  });
}