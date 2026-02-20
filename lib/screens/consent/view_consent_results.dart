import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:toast/toast.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/image_slide_show.dart';

class ViewConsentResults extends StatefulWidget {
  String results;
  ViewConsentResults({required this.results, super.key});

  @override
  State<ViewConsentResults> createState() => _ViewConsentResultsState();
}

class _ViewConsentResultsState extends State<ViewConsentResults> {
  final collectionReference = FirebaseFirestore.instance.collection(BabyData);
  CollectionReference collectionReferenceConsent =
      FirebaseFirestore.instance.collection(Consent);
  CollectionReference collectionReferenceActivity =
      FirebaseFirestore.instance.collection(Activity);

  final Set<String> _expandedEntries = {};
  late Stream<QuerySnapshot> _currentStream;

  @override
  void initState() {
    super.initState();
    _currentStream = _getStream();
  }

  Stream<QuerySnapshot> _getStream() {
    return collectionReferenceActivity
        .where('category_', isEqualTo: 'Consent')
        .where('result_', isEqualTo: widget.results)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kprimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Consent Results: ${widget.results}',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Integrated SlideShow Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                  child: ImageSlideShowfunction(context),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Consent Registry',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getCurrentDateforattendance(),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade300),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildStatusIndicator(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Filters
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'FILTER BY STATUS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueGrey,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildFilterPill('Waiting', Colors.orange, Icons.schedule_rounded),
                      const SizedBox(width: 12),
                      _buildFilterPill('Yes', Colors.green, Icons.check_circle_rounded),
                      const SizedBox(width: 12),
                      _buildFilterPill('No', Colors.redAccent, Icons.cancel_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: StreamBuilder<QuerySnapshot>(
                key: ValueKey(widget.results),
                stream: _currentStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  List<Map<String, dynamic>> uniqueEntries = [];
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final childData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final docId = snapshot.data!.docs[index].id;
                      final entryKey = "${childData['date_']}_${childData['title_']}_${childData['description_']}";

                      bool isUniqueEntry = !uniqueEntries.any((entry) => entry['date'] == childData['date_'] && entry['title'] == childData['title_'] && entry['description'] == childData['description_']);

                      if (isUniqueEntry) {
                        uniqueEntries.add({
                          'date': childData['date_'],
                          'title': childData['title_'],
                          'description': childData['description_'],
                        });
                        bool isExpanded = _expandedEntries.contains(entryKey);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => setState(() => isExpanded ? _expandedEntries.remove(entryKey) : _expandedEntries.add(entryKey)),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildStatusBadge(),
                                          IconButton(
                                            onPressed: () => _handleDelete(docId),
                                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        childData['title_'] ?? 'No Title',
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B), letterSpacing: -0.2),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        childData['description_'] ?? '',
                                        style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600, height: 1.5),
                                      ),
                                      const Divider(height: 32),
                                      Row(
                                        children: [
                                          Icon(Icons.people_alt_rounded, size: 16, color: Colors.blueGrey.shade300),
                                          const SizedBox(width: 8),
                                          Text(
                                            'View Matching Students',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blueGrey.shade400),
                                          ),
                                          const Spacer(),
                                          AnimatedRotation(
                                            duration: const Duration(milliseconds: 200),
                                            turns: isExpanded ? 0.5 : 0,
                                            child: Icon(Icons.expand_more_rounded, color: Colors.blueGrey.shade300),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: _buildBabyCard(childData['child_']),
                                ),
                              ],
                            ],
                          ),
                        );
                      } else {
                        final parentKey = uniqueEntries.lastIndexWhere((entry) => entry['date'] == childData['date_'] && entry['title'] == childData['title_'] && entry['description'] == childData['description_']);
                        if (parentKey != -1 && _expandedEntries.contains("${childData['date_']}_${childData['title_']}_${childData['description_']}")) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 8),
                            child: _buildBabyCard(childData['child_']),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, Color color, IconData icon) {
    bool isSelected = widget.results == label;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: isSelected ? color : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isSelected ? color : color.withOpacity(0.1), width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            setState(() {
              widget.results = label;
              _currentStream = _getStream();
            });
          }
        },
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color color = widget.results == 'Yes'
        ? Colors.green
        : (widget.results == 'No' ? Colors.redAccent : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(widget.results.toUpperCase(),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.0)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color = widget.results == 'Yes'
        ? Colors.green
        : (widget.results == 'No' ? Colors.redAccent : Colors.orange);
    IconData icon = widget.results == 'Yes'
        ? Icons.check_circle_rounded
        : (widget.results == 'No' ? Icons.cancel_rounded : Icons.schedule_rounded);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(widget.results,
              style:
                  TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildBabyCard(String babyId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(BabyData)
          .doc(babyId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists)
          return const SizedBox.shrink();

        final babyData = snapshot.data!.data() as Map<String, dynamic>;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 5,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: kprimary.withOpacity(0.05), width: 1.5),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image:
                        CachedNetworkImageProvider(babyData['picture'] ?? ''),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      babyData['childFullName'] ?? 'No Name',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${babyData['fathersName']} • ${babyData['class_']}',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey.shade300,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: Colors.blueGrey.shade200),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      kprimary.withOpacity(0.5)))),
          const SizedBox(height: 20),
          Text('Loading results...',
              style: TextStyle(
                  color: Colors.blueGrey.shade300,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)
                ]),
            child: Icon(Icons.assignment_turned_in_outlined,
                size: 64, color: Colors.blueGrey.shade100),
          ),
          const SizedBox(height: 32),
          Text('Nothing to show',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text(
              'No students have the "${widget.results}" status for these consents yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey.shade400,
                  height: 1.5)),
        ],
      ),
    );
  }

  Future<void> _handleDelete(String docId) async {
    final confirmed = await confirm(
      context,
      title: const Text("Delete Record"),
      content: const Text(
          "Are you sure you want to permanently delete this consent result?"),
      textOK: const Text('Delete', style: TextStyle(color: Colors.red)),
      textCancel: const Text('Cancel'),
    );
    if (confirmed) deleteDocumentFromFirestore(docId);
  }

  void deleteDocumentFromFirestore(String documentId) async {
    try {
      await collectionReferenceActivity.doc(documentId).delete();
      ToastContext().init(context);
      Toast.show('Record deleted', backgroundColor: Colors.red, duration: 5);
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}
