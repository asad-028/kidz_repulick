import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kids_republik/utils/const.dart';

import 'manager_accounts_home.dart';
import 'package:kids_republik/main.dart';

class AddCashBankTransfer extends StatelessWidget {
String bankName = "${table_ == '_tsn' ? "JS BANK LIMITED\n PAK TOWER BRANCH, KARACHI":"HABIB BANK LIMITED \n 5-C PLAZA F-10 MARKAZ, ISLAMABAD"}"; // Replace with actual data fetching
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Pay Fees with Bank Transfer',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),
        ),
        backgroundColor: kprimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                // height: mQ.height*0.3,
                color: Colors.white,
                child:
                Column(
                  children: [
                    SizedBox(height: mQ.height *0.015),
                    Text(
                      'How to Pay Fees through Bank Transfers',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: mQ.height *0.015),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: mQ.width*0.25,
                          child:Column(
                            children: [
                              _buildStepItem(
                                number: '1',
                                title: 'Login',
                                icon: Icon(Icons.login_outlined)),
                              Text('Login to your bank\'s website / mobile app',
                                style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),

                            ],
                          )),
                        Container(
                          color: grey100,
                          width: mQ.width*0.35,
                          child:Column(
                            children: [
                              _buildStepItem(
                                number: '2',
                                title: 'Add Beneficiary',
                                icon: Icon(Icons.person_add_outlined)),
                              Text('Add account number $accountNumber of $creditTo as beneficiary',
                                style: TextStyle(fontSize: 12.0, color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),

                            ],
                          )),
                        Container(
                          width: mQ.width*0.25,
                          child:Column(
                            children: [
                              _buildStepItem(
                                number: '3',
                                title: 'Send Money',
                                icon: Icon(Icons.attach_money_outlined)),
                              Text('Send amount payable to $creditTo account instantly',
                                style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                      ],
                    ),
                    SizedBox(height: mQ.height*0.01,),
                  ],
                ),
              ),
              SizedBox(height: mQ.height *0.015),

              // Payee Information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Bank Name:                      $bankName", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                ],
              ),
              SizedBox(height: mQ.height *0.015),
              Row(
                children: [
                  Text("Benefeciary Name:", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                  Text("               ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                  Text("$creditTo", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                ],
              ),
              SizedBox(height: mQ.height *0.015),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Account Number:             $accountNumber", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                  IconButton(
                    onPressed: () async {
                      // Replace with your actual account number retrieval
                      await Clipboard.setData(ClipboardData(text: accountNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green[50],
                          content: Text(
                            'Account Number Copied!',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.content_copy,size: 16,),
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.green[50],
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("IBAN Number:                  $IBANNumber", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
                  IconButton(
                    onPressed: () async {
                      // Replace with your actual IBAN retrieval
                      await Clipboard.setData(ClipboardData(text: IBANNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green[50],
                          content: Text(
                            'IBAN Number Copied!',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.content_copy,size: 16,),
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.green[50],
                    ),
                  ),
                ],
              ),
              SizedBox(height: mQ.height *0.015),

              Text('Important', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold,),),
              Text('Save the generated slip of transaction and Go to "Upload Slip" section.', style: TextStyle(fontSize: 12.0, color: Colors.grey, fontWeight: FontWeight.normal,),),
              SizedBox(height: mQ.height*0.01,),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({required String number, required String title, required Icon icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue[800],
          ),
        ),
            Text(
              title,
              style: TextStyle(fontSize: 12.0),
            ),
            Icon(icon.icon, size: 20.0, color: Colors.lightBlue[800]),
      ],
    );
  }
}
