import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/activities/create_activity_multiple_childs.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/image_slide_show.dart';
import '../kids/widgets/empty_background.dart';

class SelectChildsForActivity extends StatefulWidget {
  final activityclass_;
  final selectedsubject_;
  SelectChildsForActivity(
      {this.activityclass_, super.key, required this.selectedsubject_});
  // String activitybabyid_ = '';

  @override
  State<SelectChildsForActivity> createState() =>
      _SelectChildsForActivityState();
}

class _SelectChildsForActivityState extends State<SelectChildsForActivity> {
  final collectionReference = FirebaseFirestore.instance.collection(BabyData);
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> selectedBabies = [];
  String _searchQuery = '';
  List<String> _currentFilteredBabyIds = []; // To hold IDs for 'Select All'

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kWhite),
        title: Text(
          'Class ${widget.activityclass_}',
          style: const TextStyle(
              fontSize: 18, color: kWhite, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kprimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: kprimary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Select Students for ${widget.selectedsubject_}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: Icon(Icons.search, color: kprimary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selection Options
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Checked In Students',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_currentFilteredBabyIds.isNotEmpty &&
                          selectedBabies.length ==
                              _currentFilteredBabyIds.length) {
                        // If all filtered are selected, deselect all
                        selectedBabies.clear();
                      } else {
                        // Select all filtered students
                        selectedBabies
                            .clear(); // Clear existing to avoid duplicates
                        for (String babyId in _currentFilteredBabyIds) {
                          selectedBabies.add({'babyId': babyId});
                        }
                      }
                    });
                  },
                  icon: Icon(
                    _currentFilteredBabyIds.isNotEmpty &&
                            selectedBabies.length ==
                                _currentFilteredBabyIds.length
                        ? Icons.deselect
                        : Icons.done_all,
                    size: 18,
                  ),
                  label: Text(
                    _currentFilteredBabyIds.isNotEmpty &&
                            selectedBabies.length ==
                                _currentFilteredBabyIds.length
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                  style: TextButton.styleFrom(foregroundColor: kprimary),
                ),
              ],
            ),
          ),

          // Students Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: collectionReference
                  .where('class_', isEqualTo: widget.activityclass_)
                  .where('checkin', isEqualTo: 'Checked In')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  _currentFilteredBabyIds = []; // Clear IDs if no data
                  return const EmptyBackground(
                    title:
                        'Currently, no students are checked in for this class.',
                  );
                }

                final allDocs = snapshot.data!.docs;
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                      (data['childFullName'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                // Update the list of current filtered baby IDs for 'Select All'
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!listEquals(_currentFilteredBabyIds,
                      filteredDocs.map((doc) => doc.id).toList())) {
                    setState(() {
                      _currentFilteredBabyIds =
                          filteredDocs.map((doc) => doc.id).toList();
                    });
                  }
                });

                if (filteredDocs.isEmpty) {
                  return const Center(
                      child: Text('No students match your search.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final childData = doc.data() as Map<String, dynamic>;
                    final babyId = doc.id;
                    final isSelected =
                        selectedBabies.any((baby) => baby['babyId'] == babyId);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedBabies.removeWhere(
                                (baby) => baby['babyId'] == babyId);
                          } else {
                            selectedBabies.add({'babyId': babyId});
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? kprimary : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: (childData['picture'] != null &&
                                            childData['picture'].isNotEmpty)
                                        ? CachedNetworkImage(
                                            imageUrl: childData['picture'],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                    color: Colors.grey[200]),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.person),
                                          )
                                        : const Icon(Icons.person),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(
                                    childData['childFullName'] ?? '',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  childData['fathersName'] ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: kprimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: selectedBabies.isEmpty
                ? null
                : () {
                    Get.to(CreateActivityForMultipleChildsScreen(
                      selectedBabies: selectedBabies,
                      selectedsubject_: widget.selectedsubject_,
                    ));
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text(
              selectedBabies.isEmpty
                  ? 'Select Students to Proceed'
                  : 'Proceed with ${selectedBabies.length} Students',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to compare lists (for WidgetsBinding.instance.addPostFrameCallback)
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
