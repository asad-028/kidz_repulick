import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:snackbar/snackbar.dart';

import '../../main.dart';
void UpdateAccountsDashboardScreen(String classRoomDocumentID, BuildContext context) {
  int notPaid = 0;
  int paid = 0;
  int verified = 0;
  double amountNotPaid = 0;
  double amountPaid = 0;
  double amountVerified = 0;
  print(classRoomDocumentID);
  FirebaseFirestore.instance.runTransaction((transaction) async {
    // Get Not Paid count and sum
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(accounts)
        .where('studentClass', isEqualTo: classRoomDocumentID)
        .where('status', isEqualTo: 'Not Paid')
        .get();
    notPaid = querySnapshot.size;
    amountNotPaid = querySnapshot.docs.fold(0, (sum, doc) => sum + (doc['amountPayable'])); // Cast to int

    // amountNotPaid = querySnapshot.docs.fold(0, (sum, doc) => sum + doc['amountPayable']); // Sum amountPayable

    // Get Paid count and sum
    querySnapshot = await FirebaseFirestore.instance
        .collection(accounts)
        .where('studentClass', isEqualTo: classRoomDocumentID)
        .where('status', isEqualTo: 'Paid')
        .get();
    paid = querySnapshot.size;
    amountPaid = querySnapshot.docs.fold(0, (sum, doc) => sum + doc['amountPayable'] ); // Sum amountPayable

    // Get Verified count and sum
    querySnapshot = await FirebaseFirestore.instance
        .collection(accounts)
        .where('studentClass', isEqualTo: classRoomDocumentID)
        .where('status', isEqualTo: 'Verified')
        .get();
    verified = querySnapshot.size;
    amountVerified = querySnapshot.docs.fold(0, (sum, doc) => sum + doc['amountPayable']); // Sum amountPayable

    DocumentReference classRoomRef =
    FirebaseFirestore.instance.collection(ClassRoom).doc(classRoomDocumentID);
    transaction.update(classRoomRef, {
      'NotPaid_': notPaid,
      'amountNotPaid': amountNotPaid,
      'Paid_': paid,
      'amountPaid': amountPaid,
      'Verified_': verified,
      'amountVerified': amountVerified,
    });
  }).then((value) {
    // ToastContext().init(context);
    snack('Accounts Updated.', );
  }).catchError((error) {
    // ToastContext().init(context);
    snack('Error updating strength: $error');
    // print('Error updating strength: $error');
  });

}

