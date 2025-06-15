import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrition_app/screens/loading.dart';
import 'package:nutrition_app/screens/nutrimate/main_app.dart';
import 'package:nutrition_app/services/fetch_recommendations';
import 'package:nutrition_app/utilities/addAdvancedUserData.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrition_app/widgets/gender_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:nutrition_app/screens/advanced_user_details.dart';
import 'package:nutrition_app/widgets/continue_button.dart';
import 'package:nutrition_app/provider/advanced_user_details_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cloudinary_service.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  UserDetailsScreen({super.key});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  final TextEditingController _allergiesController = TextEditingController();
  final List<String> _dietaryGoals = [
    'Weight Loss',
    'Energy Boost',
    'Diabetic Care',
    'Muscle Gain',
    'Balanced Diet',
  ];

  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  bool _isPickingImage = false;
  String _name = 'John Doe';
  bool _nameEnable = false;
  File? _pickedImage;
  final List<String> _preferences = [
    'Vegetarian',
    'Non Vegetarian',
    'Vegan',
    'Millet-Based',
    'Keto',
    'No Preference',
  ];

  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedPreference;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final userUid = await FirebaseAuth.instance;
    final response = await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid.currentUser!.uid)
        .get();

    if (response.exists) {
      setState(() {
        _name = response.data()?['name'];
      });
    } else {
      //
    }
  }

  bool validateInputs(BuildContext context, AdvancedUserDetails state) {
    if (state.activityLevel == null ||
        state.activityLevel!.isEmpty ||
        state.conditions == null ||
        state.conditions.isEmpty ||
        state.cuisines == null ||
        state.cuisines.isEmpty ||
        state.nutrients == null ||
        state.nutrients.isEmpty) {
      _showSnackBar(
          context, 'Great start! Tap next to enter the remaining details');
      return false;
    }

    return true;
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _submitDetails(BuildContext context, AdvancedUserDetails state) async {
    final _isValid = _formKey.currentState!.validate();

    if (!_isValid) {
      return;
    }
    if (_pickedImage == null) {
      _showSnackBar(context, 'Please pick an image');
      return;
    } else {
      if (_selectedGender == null || _selectedGender!.trim().isEmpty) {
        _showSnackBar(context, 'Please select Gender');
        return;
      }
      if (!validateInputs(context, state)) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ModernLoadingScreen(
          message: 'Tuning your profile for a perfectly balanced lifestyle...',
        ),
      );

      try {
        final userUid = FirebaseAuth.instance.currentUser!.uid;

// 1. Update Firestore with basic user details
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userUid)
            .update({
          'name': (nameController.text.trim().isEmpty)
              ? _name
              : nameController.text,
          'age': ageController.text,
          'gender': _selectedGender,
          'height': heightController.text,
          'weight': weightController.text,
          'dietary_goal': _selectedGoal,
          'imageUrl': imageUrl,
          'food_preference': _selectedPreference,
          'isSubmitted': true,
          if (_allergiesController.text.isNotEmpty)
            'allergies': _allergiesController.text,
        });

// 2. Save additional advanced user details
        await saveAdvancedUserDetails(
          activityLevel: state.activityLevel ?? "",
          medicalConditions: state.conditions,
          mealsPerDay: state.mealsPerDay,
          preferredCuisines: state.cuisines,
          dislikedFoods: state.dislikedFoods,
          nutrientsSelected: state.nutrients,
        );

// 3. Combine user data and send to AI model
        final userData = {
          'age': int.tryParse(ageController.text) ?? 0,
          'gender': _selectedGender,
          'height': double.tryParse(heightController.text) ?? 0,
          'weight': double.tryParse(weightController.text) ?? 0,
          'activity': state.activityLevel, // e.g., "Active", "Sedentary", etc.
          'conditions': state
              .conditions, // List<String> like ["Diabetes", "Hypertension"]
          'cuisines':
              state.cuisines, // List<String> like ["Indian", "South Indian"]
          'dislikes': state.dislikedFoods, // List<String>
          'allergies': _allergiesController.text.isEmpty
              ? []
              : _allergiesController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList(),
          'food_preference': _selectedPreference,
          'nutrients': state.nutrients, // List<String>
          'meals_per_day': state.mealsPerDay,
        };

// 4. Send data to your deployed model and save result
        await fetchRecommendationsFromModel(uid: userUid, userData: userData);
        ref.read(advancedUserDetailsProvider.notifier).reset();
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainNavigation()),
        );
      } catch (error) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.toString() ?? 'Error in submitting Data')));
      }
    }
  }

  bool _isUploading = false;
  String? imageUrl;
  String? _uploadedImageUrl;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Your existing _pickImage method - keep as is
  void _pickImage() async {
    final _imagePicker = ImagePicker();
    setState(() {
      _isPickingImage = true;
    });

    final _XFileImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 200,
      maxHeight: 200,
    );

    if (_XFileImage != null) {
      _pickedImage = File(_XFileImage.path);
    }
    setState(() {
      _isPickingImage = false;
    });
  }

  // New method to upload picked image to Cloudinary
  Future<void> _uploadImage() async {
    if (_pickedImage == null) {
      _showMessage('Please pick an image first', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      imageUrl = await _cloudinaryService.uploadImage(
          _pickedImage!, FirebaseAuth.instance.currentUser!.uid);

      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
        });
        _showMessage('Image uploaded successfully!', isError: false);

        // You can save this URL to your database or use it as needed
        print('Image URL: $imageUrl');
      } else {
        _showMessage('Upload failed. Please try again.', isError: true);
      }
    } catch (e) {
      _showMessage('Upload error: $e', isError: true);
    }

    setState(() {
      _isUploading = false;
    });
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Method to pick and upload in one go
  Future<void> _pickAndUploadImage() async {
    final _imagePicker = ImagePicker();
    setState(() {
      _isPickingImage = true;
    });

    final _XFileImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 200,
      maxHeight: 200,
    );

    setState(() {
      _isPickingImage = false;
    });

    if (_XFileImage != null) {
      _pickedImage = File(_XFileImage.path);

      // Automatically upload after picking
      await _uploadImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final state = ref.watch(advancedUserDetailsProvider);
    return Scaffold(
      appBar: AppBar(
          title: Text('Let\'s Get to Know You!'),
          elevation: 10,
          backgroundColor: isDarkMode ? null : const Color(0xFFFFF8E1),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.exit_to_app),
            ),
          ]),
      body: Container(
        margin: EdgeInsets.only(top: 20, left: 20, right: 10),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : AssetImage('assets/foods/user.png') as ImageProvider,
                  radius: 50,
                ),
                if (_pickedImage != null)
                  Positioned(
                      right: 7,
                      bottom: 7,
                      child: IconButton(
                          onPressed: _pickAndUploadImage,
                          icon: Icon(Icons.edit, color: Colors.lightGreen[200]),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54.withAlpha(140),
                          )))
              ],
            ),
            if (_pickedImage == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _pickAndUploadImage,
                    icon: Icon(Icons.image),
                    label: Text('Upload an Image'),
                  )
                ],
              ),
            _pickedImage != null ? SizedBox(height: 50) : SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                label: Text(_nameEnable ? 'Enter name' : _name),
                                prefixIcon: Icon(Icons.person,
                                    color: Colors.lightGreen[400]),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              enabled: _nameEnable,
                              validator: (value) {
                                if (_nameEnable) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please enter a valid name.';
                                  }
                                }
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _nameEnable = !_nameEnable;
                              });
                            },
                            icon:
                                Icon(Icons.edit, color: Colors.lightGreen[400]),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: ageController,
                              keyboardType: TextInputType.numberWithOptions(),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.accessibility_new,
                                    color: Colors.lightGreen[400]),
                                labelText: 'Age',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter age.';
                                }
                                final age = double.tryParse(value);
                                if (age == null || age < 5 || age > 120) {
                                  return 'Enter a valid age.';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: GenderSelector(
                              onGenderSelected: (selected) {
                                _selectedGender = selected;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: heightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Height (cm)',
                                prefixIcon: Icon(Icons.height,
                                    color: Colors.lightGreen[400]),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your height';
                                }
                                final height = double.tryParse(value);
                                if (height == null ||
                                    height < 50 ||
                                    height > 275) {
                                  return 'Enter a valid height';
                                }
                                return null;
                              },
                            ),
                          ),

                          SizedBox(width: 8),

                          // Weight Input
                          Expanded(
                            child: TextFormField(
                              controller: weightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Weight (kg)',
                                prefixIcon: Icon(Icons.monitor_weight,
                                    color: Colors.lightGreen[400]),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your weight';
                                }
                                final weight = double.tryParse(value);
                                if (weight == null ||
                                    weight < 10 ||
                                    weight > 350) {
                                  return 'Enter a valid weight';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        child: DropdownButtonFormField2<String>(
                          value: _selectedGoal,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Dietary Goal',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            prefixIcon: Icon(Icons.track_changes,
                                color: Colors.lightGreen),
                          ),
                          items: _dietaryGoals
                              .map((goal) => DropdownMenuItem<String>(
                                    value: goal,
                                    child: Text(
                                      goal,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGoal = value;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Please select a dietary goal'
                              : null,
                          dropdownStyleData: DropdownStyleData(
                            elevation: 4,
                            maxHeight: 200,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.lightGreenAccent[90],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            offset: const Offset(
                                0, -4), // moves the dropdown up/down
                            width: MediaQuery.of(context).size.width *
                                0.85, // sets dropdown width
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        child: DropdownButtonFormField2<String>(
                          value: _selectedPreference,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Food Preference',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            prefixIcon: Icon(Icons.restaurant_menu,
                                color: Colors.lightGreen),
                          ),
                          items: _preferences
                              .map((pref) => DropdownMenuItem<String>(
                                    value: pref,
                                    child: Text(
                                      pref,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPreference = value;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Please select a food preference'
                              : null,
                          dropdownStyleData: DropdownStyleData(
                            elevation: 4,
                            maxHeight: 200,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.lightGreenAccent[90],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            offset: const Offset(0, -4),
                            width: MediaQuery.of(context).size.width * 0.85,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _allergiesController,
                        decoration: InputDecoration(
                          labelText: 'Allergies (if any)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          prefixIcon: Icon(Icons.warning_amber,
                              color: Colors.redAccent),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.arrow_forward),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                          ),
                          iconAlignment: IconAlignment.end,
                          label: Text('Next',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.lightGreen
                                      : const Color.fromARGB(255, 1, 49, 2),
                                  fontSize: 16)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AdvancedUserDetailsScreen()),
                            );
                          },
                        )
                      ]),
                      Container(
                        margin: EdgeInsets.only(right: 10, bottom: 20, top: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: ContinueButton(
                                onPressed: () {
                                  _submitDetails(context, state);
                                },
                                label: 'Submit Details...',
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
