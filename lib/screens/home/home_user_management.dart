import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/auth/signup.dart';
import 'package:kids_republik/screens/kids/widgets/empty_background.dart';
import 'package:kids_republik/utils/const.dart';

import '../../controllers/auth_controllers/signup_controller.dart';
import '../../utils/image_slide_show.dart';

final roles_ = <String>['Principal', 'Manager', 'Parent', 'Teacher'];
var condition;

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  SignUpController signUpController = Get.put(SignUpController());
  final collectionRefrence = FirebaseFirestore.instance.collection(users);
  bool deleteionLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  // UpdateClassController updateCropController = Get.put(UpdateClassController());
  String _selectedFilter = 'Staff';

  @override
  void initState() {
    super.initState();
    _selectedFilter = (role_ == 'Director') ? 'All' : 'Staff';
    _updateCondition(_selectedFilter);
  }

  void _updateCondition(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (role_ == 'Director' && filter == 'All') {
        condition = collectionRefrence.snapshots();
      } else if (filter == 'New Users') {
        condition = collectionRefrence.where('role', isEqualTo: '').snapshots();
      } else if (filter == 'Blocked') {
        condition = collectionRefrence
            .where('status', isNotEqualTo: 'Activate')
            .snapshots();
      } else if (filter == 'Staff') {
        condition = collectionRefrence.where('role',
            whereIn: ['Principal', 'Manager', 'Teacher']).snapshots();
      } else if (filter == 'Parents') {
        condition =
            collectionRefrence.where('role', isEqualTo: 'Parent').snapshots();
      } else {
        // Default or error state
        condition =
            collectionRefrence.where('role', isEqualTo: 'none').snapshots();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Lighter, cleaner background
      appBar: AppBar(
        iconTheme: IconThemeData(color: kBlackColor), // Dark icons for contrast
        elevation: 0, // Remove heavy shadow for modern flat look
        title: Text(
          'User Management',
          style: TextStyle(
              color: kBlackColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kprimary, // Transparent/White app bar
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(SignUpScreen());
          },
          backgroundColor: kprimary,
          child: Icon(
            Icons.add,
            size: 28,
            color: kWhite,
          )),

      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ImageSlideShowfunction(context), // Re-enable if needed, but might clutter "modern" clean look. Keeping it as per original logic but maybe with padding.
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ImageSlideShowfunction(context),
              ),

              if (role_ == 'Director' || role_ == 'Principal')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      // Changed to ListView for better scroll control
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (role_ == 'Director')
                          _buildFilterChip('All', Icons.group),
                        _buildFilterChip(
                            'New Users', Icons.person_add_outlined),
                        _buildFilterChip(
                            'Staff', Icons.assignment_ind_outlined),
                        _buildFilterChip(
                            'Parents', Icons.family_restroom_outlined),
                        _buildFilterChip('Blocked', Icons.block_outlined),
                      ],
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Accounts",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: condition,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: CircularProgressIndicator(color: kprimary),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return EmptyBackground(
                        title: 'No users found',
                      );
                    }

                    // Data is available, build the list
                    return ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16), // Increased spacing
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final userData = doc.data() as Map<String, dynamic>;
                        return _buildUserTile(context, userData, doc.id, mQ);
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: mQ.height * 0.1,
              ),
            ],
          )),
    );
  }

  void addInvitationCode(BuildContext context) {
    String invitationCode =
        signUpController.invitationCodeController.text.trim();

    if (invitationCode.isNotEmpty) {
      // Get a reference to the collection
      CollectionReference invitationCodesCollection =
          FirebaseFirestore.instance.collection(invitation_codes);

      // Check if the invitation code already exists
      invitationCodesCollection.doc(invitationCode).get().then((docSnapshot) {
        if (docSnapshot.exists) {
          // Show an error message for duplicate entry
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invitation code already exists',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: kRedColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Add the invitation code to the collection
          invitationCodesCollection.doc(invitationCode).set({
            'invitation_code': invitationCode,
            // You can add more fields if needed
          }).then((value) {
            // Clear the text field after adding the invitation code
            signUpController.invitationCodeController.clear();

            // Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invitation code added successfully',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: kprimary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }).catchError((error) {
            // Show an error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to add invitation code: $error',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: kRedColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        }
      });
    } else {
      // Show a message for empty input case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid invitation code',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: kRedColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildFilterChip(String label, IconData icon) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0), // Increased spacing
      child: InkWell(
        onTap: () {
          _updateCondition(label);
        },
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? kprimary : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border:
                Border.all(color: isSelected ? kprimary : Colors.grey.shade300),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: kprimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4))
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, Map<String, dynamic> userData,
      String docId, Size mQ) {
    bool isActive = userData['status'] == 'Activate';

    return Container(
      padding: const EdgeInsets.all(16), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // More rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08), // Softer shadow
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(userData['userImage'], mQ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            userData['full_name'] ?? 'N/A',
                            style: kTitle.copyWith(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (role_ == 'Director')
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.more_horiz,
                                size: 24,
                                color: Colors.grey[400]), // Modern ellipses
                            tooltip: 'Assign Role',
                            onSelected: (String selectedItem) async {
                              if (await confirm(
                                context,
                                title: const Text("Assign Role"),
                                content: Text(
                                    "Account: ${userData['full_name']}\nNew Role: $selectedItem"),
                                textOK: Text('Confirm',
                                    style: TextStyle(color: kprimary)),
                                textCancel: const Text('Cancel',
                                    style: TextStyle(color: Colors.grey)),
                              )) {
                                collectionRefrence
                                    .doc(docId)
                                    .update({"role": selectedItem});
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return roles_.map((String item) {
                                return PopupMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.work_outline, size: 14, color: kGrey),
                          const SizedBox(width: 6),
                          Text(
                            userData['role']?.toString().isEmpty ?? true
                                ? 'No Role Assigned'
                                : userData['role'],
                            style: kSubTitle.copyWith(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // const Divider(height: 20, thickness: 0.5), // Removed divider for cleaner look
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email_outlined,
                            size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            userData['email'] ?? 'No email',
                            style: kSubTitle.copyWith(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (userData['contact_number'] != null &&
                        userData['contact_number'].toString().isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text(
                            userData['contact_number'],
                            style: kSubTitle.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    if (userData['invitation_code'] != null &&
                        userData['invitation_code'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.vpn_key_outlined,
                                size: 16, color: kprimary),
                            const SizedBox(width: 8),
                            Text(
                              "Code: ${userData['invitation_code']}",
                              style: kSubTitle.copyWith(
                                  fontSize: 13,
                                  color: kprimary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildStatusIndicator(isActive),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      if (await confirm(
                        context,
                        title: Text(isActive ? "Block User" : "Activate User"),
                        content: Text(
                            "Are you sure you want to ${isActive ? 'block' : 'activate'} ${userData['full_name']}?"),
                        textOK: Text('Confirm',
                            style: TextStyle(
                                color: isActive ? kRedColor : kprimary)),
                        textCancel: const Text('Cancel'),
                      )) {
                        collectionRefrence.doc(docId).update(
                            {"status": isActive ? "Block" : "Activate"});
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        isActive
                            ? Icons.block_flipped
                            : Icons.check_circle_outline,
                        size: 24,
                        color: isActive ? kRedColor : kGreenColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, Size mQ) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: (imageUrl == null || imageUrl == 'Null')
            ? Image.asset('assets/staff.jpg', fit: BoxFit.cover)
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CupertinoActivityIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: isActive ? kSuccessLightColor : kWarningLightColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive
                  ? kSuccessColor.withOpacity(0.2)
                  : kWarningColor.withOpacity(0.2))),
      child: Text(
        isActive ? 'Active' : 'Blocked',
        style: TextStyle(
            color: isActive ? kSuccessColor : kWarningColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
    );
  }
}
