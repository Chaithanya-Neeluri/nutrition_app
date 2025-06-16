import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocumentVerificationAdmin extends StatefulWidget {
  const DocumentVerificationAdmin({super.key});

  @override
  State<DocumentVerificationAdmin> createState() =>
      _DocumentVerificationAdminState();
}

class _DocumentVerificationAdminState extends State<DocumentVerificationAdmin> {
  String _selectedFilter = 'pending';
  bool _isLoading = false;

  // Required fields for verification
  final List<String> _requiredFields = [
    'name',
    'address',
    'phone',
    'cuisineType',
  ];

  // Required documents
  final List<String> _requiredDocuments = [
    'Business License',
    'Food Safety Certificate',
    'Tax Registration',
  ];

  Future<void> _updateVerificationStatus(String userId, String status,
      {String? rejectionReason}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updateData = {
        'verificationStatus': status,
        'verifiedAt': FieldValue.serverTimestamp(),
        'isVerified': status == 'approved',
      };

      if (rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved'
                  ? 'NutriChef approved successfully'
                  : 'Status updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showRejectionDialog(String userId) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejection Reason'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                _updateVerificationStatus(
                  userId,
                  'rejected',
                  rejectionReason: reasonController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  bool _validateRestaurantDetails(Map<String, dynamic> restaurantDetails) {
    return _requiredFields.every((field) =>
        restaurantDetails[field] != null &&
        restaurantDetails[field].toString().isNotEmpty);
  }

  bool _validateDocuments(Map<String, dynamic> documents) {
    return _requiredDocuments.every((docType) {
      final docData = documents[docType] as Map<String, dynamic>?;
      return docData != null &&
          docData['url'] != null &&
          docData['url'].toString().isNotEmpty &&
          docData['fileName'] != null &&
          docData['uploadedAt'] != null;
    });
  }

  Future<void> _handleDocumentAction(String url, String action) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get a fresh download URL from Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(url);
      final downloadUrl = await storageRef.getDownloadURL();

      // For preview, we'll use a WebView
      if (action == 'view') {
        if (!mounted) return;

        // Show preview dialog
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Document Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: WebViewWidget(
                      controller: WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..loadRequest(Uri.parse(downloadUrl)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final uri = Uri.parse(downloadUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error opening document: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Document'),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // For direct download
        final uri = Uri.parse(downloadUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('URL cannot be launched');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error $action document: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _handleDocumentAction(url, action),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildVerificationCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final documents = data['documents'] as Map<String, dynamic>? ?? {};
    final restaurantDetails =
        data['restaurantDetails'] as Map<String, dynamic>? ?? {};
    final verificationStatus =
        data['verificationStatus'] as String? ?? 'pending';

    // Validate required fields and documents
    final bool hasAllDetails = _validateRestaurantDetails(restaurantDetails);
    final bool hasAllDocuments = _validateDocuments(documents);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text(
          restaurantDetails['name'] ?? 'Unnamed Restaurant',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${verificationStatus.toUpperCase()}',
              style: TextStyle(
                color: verificationStatus == 'approved'
                    ? Colors.green
                    : verificationStatus == 'rejected'
                        ? Colors.red
                        : Colors.orange,
              ),
            ),
            if (verificationStatus == 'pending') ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    hasAllDetails ? Icons.check_circle : Icons.error,
                    color: hasAllDetails ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Details ${hasAllDetails ? 'Complete' : 'Incomplete'}',
                    style: TextStyle(
                      color: hasAllDetails ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    hasAllDocuments ? Icons.check_circle : Icons.error,
                    color: hasAllDocuments ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Documents ${hasAllDocuments ? 'Complete' : 'Incomplete'}',
                    style: TextStyle(
                      color: hasAllDocuments ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Details
                const Text(
                  'Restaurant Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._requiredFields.map((field) {
                  final value = restaurantDetails[field] ?? 'N/A';
                  final bool isValid =
                      value != 'N/A' && value.toString().isNotEmpty;
                  return _buildDetailRow(
                    field,
                    value,
                    isValid: isValid,
                  );
                }).toList(),
                const SizedBox(height: 16),

                // Documents
                const Text(
                  'Required Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._requiredDocuments.map((docType) {
                  final docData =
                      documents[docType] as Map<String, dynamic>? ?? {};
                  final bool hasDocument = docData['url'] != null &&
                      docData['url'].toString().isNotEmpty;
                  return _buildDocumentRow(
                    docType,
                    docData,
                    isValid: hasDocument,
                  );
                }).toList(),

                // Action Buttons
                if (verificationStatus == 'pending') ...[
                  const SizedBox(height: 16),
                  if (!hasAllDetails || !hasAllDocuments)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        '⚠️ Cannot approve: Missing required information',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton.icon(
                            onPressed: () => _showRejectionDialog(doc.id),
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton.icon(
                            onPressed: (hasAllDetails && hasAllDocuments)
                                ? () => _updateVerificationStatus(
                                    doc.id, 'approved')
                                : null,
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isValid = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${label}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isValid ? null : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String docType, Map<String, dynamic> docData,
      {bool isValid = true}) {
    final uploadedAt = docData['uploadedAt'] as dynamic;
    final formattedDate = _formatDateTime(uploadedAt);
    final url = docData['url'] as String?;
    final fileName = docData['fileName'] as String? ?? 'Document';
    final fileType = docData['fileType'] as String? ?? 'pdf';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  docType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isValid ? fileName : 'Not Uploaded',
                  style: TextStyle(
                    color: isValid ? null : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isValid) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Uploaded: $formattedDate',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Type: ${fileType.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isValid)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility),
                  tooltip: 'Preview Document',
                  onPressed: () {
                    if (url != null) {
                      _handleDocumentAction(url, 'view');
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Download Document',
                  onPressed: () {
                    if (url != null) {
                      _handleDocumentAction(url, 'download');
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';

    if (dateTime is Timestamp) {
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime.toDate());
    } else if (dateTime is DateTime) {
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    }

    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriChef Verifications'),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Filter Buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: const Text('Pending'),
                          selected: _selectedFilter == 'pending',
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = 'pending';
                            });
                          },
                          backgroundColor: Colors.orange.withOpacity(0.2),
                          selectedColor: Colors.orange,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: const Text('Approved'),
                          selected: _selectedFilter == 'approved',
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = 'approved';
                            });
                          },
                          backgroundColor: Colors.green.withOpacity(0.2),
                          selectedColor: Colors.green,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: const Text('Rejected'),
                          selected: _selectedFilter == 'rejected',
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = 'rejected';
                            });
                          },
                          backgroundColor: Colors.red.withOpacity(0.2),
                          selectedColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Verification List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'NutriChef')
                      .where('verificationStatus', isEqualTo: _selectedFilter)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child:
                            Text('No ${_selectedFilter} verifications found'),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        return _buildVerificationCard(docs[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
