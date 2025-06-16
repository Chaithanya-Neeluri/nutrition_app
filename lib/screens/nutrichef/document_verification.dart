import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../loading.dart';
import '../../widgets/auth_checker.dart';

class DocumentVerification extends StatefulWidget {
  const DocumentVerification({super.key});

  @override
  State<DocumentVerification> createState() => _DocumentVerificationState();
}

class _DocumentVerificationState extends State<DocumentVerification> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _verificationStatus = 'pending';
  Map<String, dynamic> _uploadedDocs = {};
  final List<String> _requiredDocuments = [
    'Business License',
    'Food Safety Certificate',
    'Tax Registration',
    'Insurance Certificate',
  ];

  // Restaurant details
  final _restaurantNameController = TextEditingController();
  final _restaurantAddressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _cuisineTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _verificationStatus = doc.data()?['verificationStatus'] ?? 'pending';
          _uploadedDocs = doc.data()?['documents'] ?? {};
          if (doc.data()?['restaurantDetails'] != null) {
            final details = doc.data()?['restaurantDetails'];
            _restaurantNameController.text = details['name'] ?? '';
            _restaurantAddressController.text = details['address'] ?? '';
            _phoneNumberController.text = details['phone'] ?? '';
            _cuisineTypeController.text = details['cuisineType'] ?? '';
          }
        });
      }
    }
  }

  Future<void> _pickDocument(String docType) async {
    try {
      // First try to pick the file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true, // This ensures we get the file data
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled the picker
      }

      setState(() {
        _isLoading = true;
      });

      final file = result.files.first;
      final fileName =
          '${FirebaseAuth.instance.currentUser!.uid}_${docType}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.name)}';

      // Upload to Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref().child('documents/$fileName');

      try {
        // Upload the file
        final uploadTask = await storageRef.putData(
          file.bytes!,
          SettableMetadata(
            contentType: 'application/${file.extension}',
          ),
        );

        // Get the download URL
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // Update the state
        setState(() {
          _uploadedDocs[docType] = {
            'url': downloadUrl,
            'uploadedAt': DateTime.now(),
            'status': 'pending',
            'fileName': fileName,
            'fileType': file.extension,
          };
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$docType uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (uploadError) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading to storage: $uploadError'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  bool _validateAllDocuments() {
    return _requiredDocuments.every((docType) =>
        _uploadedDocs.containsKey(docType) &&
        _uploadedDocs[docType]['url'] != null &&
        _uploadedDocs[docType]['url'].toString().isNotEmpty);
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_validateAllDocuments()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'restaurantDetails': {
          'name': _restaurantNameController.text,
          'address': _restaurantAddressController.text,
          'phone': _phoneNumberController.text,
          'cuisineType': _cuisineTypeController.text,
          'submittedAt': FieldValue.serverTimestamp(),
        },
        'documents': _uploadedDocs,
        'verificationStatus': 'pending',
        'isSubmitted': true,
        'isVerified': false,
      });

      setState(() {
        _verificationStatus = 'pending';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Pop the screen after successful submission
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting verification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AuthChecker()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildVerificationStatus() {
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (_verificationStatus) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusMessage = 'Your account has been verified!';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusMessage =
            'Your verification was rejected. Please check the reason and resubmit.';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusMessage = 'Your documents are under review.';
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Text(
                  statusMessage,
                  style: TextStyle(color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Documents',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        ..._requiredDocuments.map((docType) {
          final doc = _uploadedDocs[docType];
          final bool isUploaded = doc != null &&
              doc['url'] != null &&
              doc['url'].toString().isNotEmpty;

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(docType),
              subtitle: isUploaded
                  ? Text('Uploaded on ${_formatDateTime(doc['uploadedAt'])}')
                  : Text('Not uploaded'),
              trailing: isUploaded
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _uploadedDocs.remove(docType);
                            });
                          },
                        ),
                      ],
                    )
                  : IconButton(
                      icon: Icon(Icons.upload_file),
                      onPressed: () => _pickDocument(docType),
                    ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Verification'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? ModernLoadingScreen(
              message: "Uploading your document...",
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVerificationStatus(),
                  SizedBox(height: 24),
                  Text(
                    'Restaurant Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _restaurantNameController,
                          decoration: InputDecoration(
                            labelText: 'Restaurant Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _restaurantAddressController,
                          decoration: InputDecoration(
                            labelText: 'Restaurant Address',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _cuisineTypeController,
                          decoration: InputDecoration(
                            labelText: 'Cuisine Type',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  _buildDocumentUploadSection(),
                  SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitVerification,
                      child: Text('Submit Verification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
