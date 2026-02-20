import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/utils/parent_photos_slideshow2.dart';
import 'package:snackbar/snackbar.dart';

import '../../main.dart';

bool ApprovedOnly = false;

enum PhotoDateFilter { all, today, threeDays, week, month }

class GalleryScreenStaff extends StatefulWidget {
  final baby;
  final reportdate_;
  final biweeklystatus_;
  final subject;
  final category;
  final Color subjectcolor_;
  final fathersEmail_;

  GalleryScreenStaff({
    super.key,
    this.baby,
    this.reportdate_,
    this.subject,
    required this.subjectcolor_,
    this.category,
    this.fathersEmail_,
    this.biweeklystatus_,
  });
  String activitybabyid_ = '';

  @override
  State<GalleryScreenStaff> createState() => _GalleryScreenStaffState();
}

class _GalleryScreenStaffState extends State<GalleryScreenStaff> {
  final collectionReference = FirebaseFirestore.instance.collection(Activity);
  final collectionReferenceReports =
      FirebaseFirestore.instance.collection(Reports);
  bool deleteionLoading = false;
  final ScrollController scrollController = ScrollController();

  PhotoDateFilter _selectedFilter = PhotoDateFilter.all;
  bool _selectionMode = false;
  final Set<String> _selectedPhotoIds = {};

  late Stream<QuerySnapshot> _currentStream;

  @override
  void initState() {
    super.initState();
    _currentStream = _getStream();
  }

  @override
  void didUpdateWidget(covariant GalleryScreenStaff oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.baby != oldWidget.baby ||
        widget.reportdate_ != oldWidget.reportdate_ ||
        widget.fathersEmail_ != oldWidget.fathersEmail_) {
      _currentStream = _getStream();
    }
  }

  Stream<QuerySnapshot> _getStream() {
    Query query;
    if (role_ == "Teacher") {
      query = collectionReference
          .where('id', isEqualTo: widget.baby)
          .where('date_', isEqualTo: widget.reportdate_)
          .where('photostatus_', isEqualTo: 'New');
    } else if ((role_ == "Principal" || role_ == "Director") && ApprovedOnly) {
      query = collectionReference
          .where('id', isEqualTo: widget.baby)
          .where('photostatus_', isEqualTo: 'Approved');
    } else {
      query = collectionReference
          .where('id', isEqualTo: widget.baby)
          .where('date_', isEqualTo: widget.reportdate_)
          .where('photostatus_', isEqualTo: 'Forwarded');
    }
    return query.orderBy('date_', descending: true).snapshots();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Column(
      children: [
        ParentPhotoSlideshow2(
          fatherEmail: widget.fathersEmail_,
          babyId: widget.baby,
          activitydate_: widget.reportdate_,
        ),
        // SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Text(
            'Swipe left to delete photo. Swipe right to forward/ approve.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ),
        (role_ == 'Principal' || role_ == 'Director')
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          if (!ApprovedOnly) {
                            setState(() {
                              ApprovedOnly = true;
                              _currentStream = _getStream();
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              ApprovedOnly ? Colors.blue[50] : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Approved Only',
                          style: TextStyle(
                            fontSize: 12,
                            color: ApprovedOnly
                                ? Colors.blue[800]
                                : Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          if (ApprovedOnly) {
                            setState(() {
                              ApprovedOnly = false;
                              _currentStream = _getStream();
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: !ApprovedOnly
                              ? Colors.blue[50]
                              : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Forwarded',
                          style: TextStyle(
                            fontSize: 12,
                            color: !ApprovedOnly
                                ? Colors.blue[800]
                                : Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', PhotoDateFilter.all),
                const SizedBox(width: 10),
                _buildFilterChip('Today', PhotoDateFilter.today),
                const SizedBox(width: 10),
                _buildFilterChip('3 Days', PhotoDateFilter.threeDays),
                const SizedBox(width: 10),
                _buildFilterChip('Week', PhotoDateFilter.week),
                const SizedBox(width: 10),
                _buildFilterChip('Month', PhotoDateFilter.month),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: StreamBuilder<QuerySnapshot>(
                stream: _currentStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text(
                    '${widget.subject} - record will be displayed here');
              } //EmptyBackground(title: 'Wait for activities to be updated',); }

              final allDocs = snapshot.data!.docs;
              final filteredDocs = _filterDocsByDate(allDocs);

              if (filteredDocs.isEmpty) {
                return SizedBox(
                  width: double.infinity,
                  height: mQ.height * 0.2,
                  child: Center(
                    child: Text(
                      'No photos for selected filter',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
              }

              // Data is available, build the list
              return SizedBox(
                width: double.infinity,
                height: mQ.height * 0.58,
                child: Column(
                  children: [
                    _buildSelectionHeader(filteredDocs),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredDocs.length,
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final activityData =
                              doc.data() as Map<String, dynamic>;
                          final docId = doc.id;
                          final status = activityData["photostatus_"];

                          final cardColor = status == "Approved"
                              ? Colors.green.shade50.withOpacity(0.5)
                              : status == "Forwarded"
                                  ? Colors.blue.shade50.withOpacity(0.5)
                                  : Colors.white;

                          final accentColor = status == "Approved"
                              ? Colors.green.shade600
                              : status == "Forwarded"
                                  ? Colors.blue.shade600
                                  : Colors.blue.shade600;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Dismissible(
                              key: Key(docId),
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.shade500,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: const Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 28),
                              ),
                              secondaryBackground: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade500,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.white, size: 28),
                              ),
                              direction: _selectionMode
                                  ? DismissDirection.none
                                  : DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  // Forward / Approve should not visually remove the item,
                                  // only update its status.
                                  final confirmed = await confirm(context,
                                      content: const Text(
                                          'Forward or Approve this activity?'));
                                  if (confirmed) {
                                    await updatephotostatus(docId, '');
                                  }
                                  return false;
                                } else if (direction ==
                                    DismissDirection.endToStart) {
                                  final confirmed = await confirm(context,
                                      content: const Text(
                                          'Are you sure you want to delete this photo?'));
                                  if (!confirmed) return false;

                                  await _deleteImageInternal(
                                      docId,
                                      activityData['image_'],
                                      activityData['photostatus_']);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Photo deleted')),
                                  );
                                  // Allow Dismissible to animate the removal
                                  return true;
                                }
                                return false;
                              },
                              child: GestureDetector(
                                onTap: () {
                                  if (_selectionMode) {
                                    _toggleSelection(docId);
                                  } else if (role_ == 'Teacher' ||
                                      role_ == 'Principal' ||
                                      role_ == 'Director') {
                                    showEditingDialog(
                                        mQ,
                                        docId,
                                        activityData['Activity'],
                                        activityData['description'],
                                        activityData['Subject'],
                                        activityData['image_'],
                                        activityData);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: status == "New"
                                          ? Colors.blueGrey.shade50
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Header
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        color: accentColor.withOpacity(0.1),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${activityData['Subject']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: accentColor,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${activityData['date_']} at ${activityData['time_']}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blueGrey.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Image
                                      Stack(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: activityData['image_'],
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              height: 200,
                                              color: Colors.blueGrey.shade50,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              height: 200,
                                              color: Colors.blueGrey.shade50,
                                              child: const Icon(
                                                  Icons.error_outline,
                                                  color: Colors.blueGrey),
                                            ),
                                          ),
                                          if (_selectionMode)
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Checkbox(
                                                  value: _selectedPhotoIds
                                                      .contains(docId),
                                                  onChanged: (_) =>
                                                      _toggleSelection(docId),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                ),
                                              ),
                                            ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Material(
                                              color: Colors.black26,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: InkWell(
                                                onTap: () => deleteImages(
                                                    docId,
                                                    activityData['image_'],
                                                    status),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                      Icons
                                                          .delete_sweep_rounded,
                                                      color: Colors.white,
                                                      size: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Footer info
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${activityData['Activity']}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                ),
                                                StatusIndicator(status: status),
                                              ],
                                            ),
                                            if ((activityData['description'] ??
                                                    '')
                                                .toString()
                                                .trim()
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                '${activityData['description']}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Colors.blueGrey.shade600,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, PhotoDateFilter filter) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        if (_selectedFilter != filter) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
      selectedColor: Colors.blue.shade100,
      backgroundColor: Colors.blueGrey.shade50,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade800 : Colors.blueGrey.shade700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade300 : Colors.transparent,
          width: 1,
        ),
      ),
      elevation: 0,
      pressElevation: 0,
    );
  }

  List<QueryDocumentSnapshot> _filterDocsByDate(
      List<QueryDocumentSnapshot> docs) {
    // If "All" is selected, just return as-is without extra work
    if (_selectedFilter == PhotoDateFilter.all) {
      return docs;
    }

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final dateStr = data['date_']?.toString();
      final DateTime? photoDate = _parseActivityDate(dateStr);
      if (photoDate == null) return true;
      return _isWithinSelectedRange(photoDate);
    }).toList();
  }

  DateTime? _parseActivityDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      return DateFormat('d-M-yyyy').parse(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }
  }

  bool _isWithinSelectedRange(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff < 0) return false;

    switch (_selectedFilter) {
      case PhotoDateFilter.all:
        return true;
      case PhotoDateFilter.today:
        return diff == 0;
      case PhotoDateFilter.threeDays:
        return diff <= 3;
      case PhotoDateFilter.week:
        return diff <= 7;
      case PhotoDateFilter.month:
        return diff <= 30;
    }
  }

  Widget _buildSelectionHeader(List<QueryDocumentSnapshot> currentDocs) {
    final hasSelection = _selectedPhotoIds.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      decoration: BoxDecoration(
        color: _selectionMode ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _selectionMode
              ? TextButton.icon(
                  onPressed: () {
                    final currentOffset =
                        scrollController.hasClients ? scrollController.offset : 0.0;
                    setState(() {
                      _selectionMode = false;
                      _selectedPhotoIds.clear();
                    });
                    if (scrollController.hasClients) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (scrollController.hasClients &&
                            scrollController.position.maxScrollExtent >=
                                currentOffset) {
                          scrollController.jumpTo(currentOffset);
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: Colors.blue),
                  label: const Text(
                    'Cancel Selection',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                )
              : TextButton.icon(
                  onPressed: () {
                    final currentOffset =
                        scrollController.hasClients ? scrollController.offset : 0.0;
                    setState(() {
                      _selectionMode = true;
                    });
                    if (scrollController.hasClients) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (scrollController.hasClients &&
                            scrollController.position.maxScrollExtent >=
                                currentOffset) {
                          scrollController.jumpTo(currentOffset);
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.rule_rounded,
                      size: 20, color: Colors.blueGrey),
                  label: const Text(
                    'Select Activities',
                    style: TextStyle(
                        color: Colors.blueGrey, fontWeight: FontWeight.w600),
                  ),
                ),
          const Spacer(),
          if (_selectionMode) ...[
            Text(
              hasSelection
                  ? '${_selectedPhotoIds.length} selected'
                  : 'Pick items',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800),
            ),
            if (hasSelection)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_forever_rounded,
                    color: Colors.red, size: 22),
                onPressed: () => _deleteSelectedImages(currentDocs),
              ),
          ],
        ],
      ),
    );
  }

  void _toggleSelection(String docId) {
    setState(() {
      if (_selectedPhotoIds.contains(docId)) {
        _selectedPhotoIds.remove(docId);
      } else {
        _selectedPhotoIds.add(docId);
      }
    });
  }

  Future<void> _deleteSelectedImages(
      List<QueryDocumentSnapshot> currentDocs) async {
    if (_selectedPhotoIds.isEmpty) return;

    final confirmed = await confirm(context,
        content: Text(
            'Are you sure you want to delete ${_selectedPhotoIds.length} selected photos?'));
    if (!confirmed) return;

    for (final doc in currentDocs) {
      if (_selectedPhotoIds.contains(doc.id)) {
        final data = doc.data() as Map<String, dynamic>;
        await _deleteImageInternal(
            doc.id, data['image_'], data['photostatus_']);
      }
    }

    setState(() {
      _selectionMode = false;
      _selectedPhotoIds.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected photos deleted')),
    );
  }

  updatephotostatus(index, status) async {
    if (role_ == 'Teacher') {
      await collectionReference
          .doc(index)
          .update({"photostatus_": 'Forwarded'});
      await collectionReferenceReports.doc(widget.baby).update({
        "Photos_New": FieldValue.increment(-1),
        "Photos_Forwarded": FieldValue.increment(1),
      });
      snack('Photo Forwarded');
    } else if (!ApprovedOnly && (role_ == 'Principal')) {
      await collectionReference.doc(index).update({"photostatus_": "Approved"});
      await collectionReferenceReports.doc(widget.baby).update({
        "Photos_Approved": FieldValue.increment(1),
        "Photos_Forwarded": FieldValue.increment(-1),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo approved')),
      );
    }
    ;
    if (ApprovedOnly) {
      snack('Already approved: Photo is already approved');
      setState(() {});
    }
  }

  showEditingDialog(mQ, documentId, activity_, description, subject, image,
      Map<String, dynamic> activityData) {
    bool _isEnable = false;
    TextEditingController description_text_controller =
        TextEditingController(text: description);
    TextEditingController subject_text_controller =
        TextEditingController(text: subject);
    TextEditingController activity_text_controller =
        TextEditingController(text: activity_);
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Material(
                child: CupertinoAlertDialog(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: subject_text_controller,
                      enabled: _isEnable,
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                        alignment: AlignmentDirectional.topEnd,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon:
                            Icon(Icons.cancel, size: 12, color: Colors.black)),
                  ),
                ],
              ),
              content: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: image,
                    height: mQ.height * 0.28,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  TextField(
                    controller: activity_text_controller,
                    enabled: _isEnable,
                  ),
                  TextField(
                    controller: description_text_controller,
                    maxLines: 3,
                    enabled: _isEnable,
                  ),
                  (_isEnable)
                      ? IconButton(
                          onPressed: () {
                            collectionReference.doc(documentId).update({
                              "Subject": subject_text_controller.text,
                              "Activity": activity_text_controller.text,
                              "description": description_text_controller.text,
                            });
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.save,
                            color: Colors.orange,
                          ))
                      : Container(),
                ],
              ),
              actions: [
                deleteionLoading
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: CircularProgressIndicator(),
                      ))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            IconButton(
                                icon: Icon(Icons.edit),
                                iconSize: 18,
                                color: Colors.blue[600],
                                onPressed: () {
                                  setState(() {
                                    _isEnable = true;
                                  });
                                }),
                            (role_ == 'Teacher')
                                ? TextButton(
                                    onPressed: () async {
                                      await collectionReference
                                          .doc(documentId)
                                          .update(
                                              {"photostatus_": 'Forwarded'});

                                      await collectionReferenceReports
                                          .doc(widget.baby)
                                          .update({
                                        "Photos_New": FieldValue.increment(-1),
                                        "Photos_Forwarded":
                                            FieldValue.increment(1),
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Forward',
                                        style: TextStyle(fontSize: 8)))
                                : Container(),
                            (role_ == 'Principal' || role_ == 'Director')
                                ? TextButton(
                                    onPressed: () async {
                                      await collectionReference
                                          .doc(documentId)
                                          .update({"photostatus_": "Approved"});
                                      await collectionReferenceReports
                                          .doc(widget.baby)
                                          .update({
                                        "Photos_Approved":
                                            FieldValue.increment(1),
                                        "Photos_Forwarded":
                                            FieldValue.increment(-1),
                                      });

                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Approve',
                                        style: TextStyle(fontSize: 8)))
                                : Container(),
                          ]),
              ],
            ));
          });
        });
  }

  void deleteImages(
      String activityId, String imageAddress, photostatus_) async {
    final confirmed = await confirm(context,
        content: const Text('Are you sure you want to delete this photo?'));
    if (!confirmed) return;

    await _deleteImageInternal(activityId, imageAddress, photostatus_);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo deleted')),
    );
  }

  Future<void> _deleteImageInternal(
      String activityId, String imageAddress, photostatus_) async {
    try {
      final storageReference =
          FirebaseStorage.instance.refFromURL(imageAddress).fullPath;
      await FirebaseFirestore.instance
          .collection(Activity)
          .doc(activityId)
          .delete();
      ApprovedOnly
          ? null
          : await collectionReferenceReports.doc(widget.baby).update({
              "Photos_${photostatus_}": FieldValue.increment(-1),
            });
      role_ == 'Teacher'
          ? await collectionReferenceReports.doc(widget.baby).update({
              "Daily_${photostatus_}": FieldValue.increment(-1),
            })
          : null;
      await FirebaseStorage.instance.ref(storageReference).delete();

      // Handle successful deletion
      print('Image and document deleted successfully');
    } catch (e) {
      // Handle error
      print('Error deleting image or document: $e');
    }
  }
}

class StatusIndicator extends StatelessWidget {
  final String? status;

  const StatusIndicator({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'Approved':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Approved';
        icon = Icons.done_all_rounded;
        break;
      case 'Forwarded':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'Forwarded';
        icon = Icons.forward_rounded;
        break;
      default:
        bgColor = Colors.blueGrey.shade50;
        textColor = Colors.blueGrey.shade700;
        label = 'Draft';
        icon = Icons.edit_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
