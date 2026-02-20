import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/utils/const.dart';

class BankAccountController extends GetxController {
  RxString bankName = ''.obs;
  RxString accountNumber = ''.obs;
  RxString iban = ''.obs;
  RxString creditTo = ''.obs;
  RxString bankImage = ''.obs; // Added bankImage
  Rx<Uint8List?> bankImageBytes = Rx<Uint8List?>(null); // Cache for image bytes
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetails();
  }

  String _getDocId() {
    return table_ == 'tsn_' ? 'tsn' : 'kidz';
  }

  Future<void> fetchDetails() async {
    isLoading.value = true;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(bank_details)
          .doc(_getDocId())
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        bankName.value = data['bankName'] ?? '';
        accountNumber.value = data['accountNumber'] ?? '';
        iban.value = data['iban'] ?? '';
        creditTo.value = data['creditTo'] ?? '';
        bankImage.value = data['bankImage'] ?? ''; // Fetch bankImage
        if (bankImage.value.isNotEmpty) {
            _cacheImageBytes(bankImage.value);
        }
      }
    } catch (e) {
      print("Error fetching bank details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _cacheImageBytes(String url) async {
    try {
      final ByteData data = await NetworkAssetBundle(Uri.parse(url)).load("");
      bankImageBytes.value = data.buffer.asUint8List();
    } catch (e) {
      print("Error caching bank image: $e");
    }
  }
  
  Future<String> uploadBankImage(dynamic pickedFile) async {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('bank_images')
            .child('${_getDocId()}.jpg');
        
        // Check if the input is XFile (from image_picker) or File (from dart:io)
        // Adjust based on what you actually pass. Assuming XFile as per plan.
        // But wait, the previous code used File(pickedImage.path).
        // I will assume XFile is passed as per plan, but I need to import dart:io for File if I use it.
        // Actually, putFile takes a File object.
        // So I need to import dart:io.
        // The file already imports cloud_firestore, get, utils/const. 
        // I need to add imports to the top of the file as well if they are missing.
        // But this tool only replaces lines 7-69.
        // I'll stick to the class content replacement here.
        // I will need to use File(pickedFile.path).
        
        // Expecting pickedFile to be XFile
        await ref.putFile(File(pickedFile.path));
        String url = await ref.getDownloadURL();
        
        // Cache the uploaded image bytes immediately
        // We can read from the file directly to avoid network call
        try {
            bankImageBytes.value = await File(pickedFile.path).readAsBytes();
        } catch(e) {
            print("Error caching uploaded image: $e");
             // Fallback to downloading if file read fails (unlikely)
            _cacheImageBytes(url);
        }
        
        return url;
      } catch (e) {
        print("Error uploading bank image: $e");
        rethrow;
      }
  }

  Future<void> updateDetails(String newBankName, String newAccountNumber,
      String newIban, String newCreditTo, {String? newBankImage}) async { // Added optional newBankImage
    Map<String, dynamic> data = {
      'bankName': newBankName,
      'accountNumber': newAccountNumber,
      'iban': newIban,
      'creditTo': newCreditTo,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (newBankImage != null) {
        data['bankImage'] = newBankImage;
    }

    await FirebaseFirestore.instance
        .collection(bank_details)
        .doc(_getDocId())
        .set(data, SetOptions(merge: true));

    // Update local state
    bankName.value = newBankName;
    accountNumber.value = newAccountNumber;
    iban.value = newIban;
    creditTo.value = newCreditTo;
    if (newBankImage != null) {
        bankImage.value = newBankImage;
        // Bytes are already cached in uploadBankImage if that was called
        // If updateDetails is called with a URL but not via upload (unlikely here but possible),
        // we might want to ensure consistency, but usually upload precedes update.
        // If we just set the URL here, and it was uploaded elsewhere, we good.
        // If manual URL entry (not implemented), we'd need to fetch.
        // For now, assuming uploadBankImage handles the cache for new images.
    }
    
    Get.snackbar('Success', 'Bank details updated successfully',
        backgroundColor: kSuccessColor, colorText: kWhite);
  }
}
