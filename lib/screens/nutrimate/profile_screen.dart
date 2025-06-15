import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nutrition_app/screens/loading.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  File? _imageFile;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isEditMode = false;
  late AnimationController _editModeController;
  late Animation<double> _editModeAnimation;

  // User details controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();

  // User preferences
  String? _gender;
  String? _activityLevel;
  String? _dietaryGoal;
  String? _foodPreference;
  int _mealsPerDay = 3;
  List<String> _selectedConditions = [];
  List<String> _selectedCuisines = [];
  List<String> _selectedNutrients = [];
  List<String> _dislikedFoods = [];

  // Available options
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly',
    'Active',
    'Very',
  ];
  final List<String> _dietaryGoals = [
    'Weight Loss',
    'Energy Boost',
    'Diabetic Care',
    'Muscle Gain',
    'Balanced Diet',
  ];
  final List<String> _foodPreferences = [
    'Vegetarian',
    'Non Vegetarian',
    'Vegan',
    'Millet-Based',
    'Keto',
    'No Preference',
  ];
  final List<String> _conditions = [
    'Diabetes',
    'Hypertension',
    'Thyroid',
    'Healthy',
    'Heart Disease',
    'Kidney Disease',
    'PCOD/PCOS',
  ];
  final List<String> _cuisines = [
    'Indian',
    'North Indian',
    'South Indian',
    'Continental',
    'Chinese',
    'Mediterranean',
  ];
  final List<String> _nutrients = ['Iron', 'Fiber', 'Protein', 'Calcium'];

  // Address controllers
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _deliveryInstructionsController =
      TextEditingController();
  bool _isDefaultAddress = true;

  // Address related variables
  List<Map<String, dynamic>> _addresses = [];
  int _selectedAddressIndex = 0;
  bool _isAddingNewAddress = false;
  bool _isModifyingAddress = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _editModeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _editModeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _editModeController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadUserData();
    _loadAddresses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _editModeController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _deliveryInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        print('Loading data for user: $uid');

        // Load user profile data
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          print('User data loaded: $userData');

          setState(() {
            // Basic information
            _nameController.text = userData['name'] ?? '';
            _imageUrl = userData['imageUrl'];
            _ageController.text = userData['age']?.toString() ?? '';
            _heightController.text = userData['height']?.toString() ?? '';
            _weightController.text = userData['weight']?.toString() ?? '';
            _gender = userData['gender'];
            _activityLevel = userData['selectedActivityLevel'];
            _foodPreference = userData['food_preference'];
            _mealsPerDay = (userData['mealsPerDay'] ?? 3).toInt();
            _dietaryGoal = userData['dietary_goal'];

            print('Basic info set:');
            print('Age: ${_ageController.text}');
            print('Height: ${_heightController.text}');
            print('Weight: ${_weightController.text}');
            print('Gender: $_gender');
            print('Activity Level: $_activityLevel');
            print('Food Preference: $_foodPreference');
            print('Meals per day: $_mealsPerDay');
            print('Dietary Goal: $_dietaryGoal');

            // Arrays
            _selectedConditions = List<String>.from(
              userData['medicalConditions'] ?? [],
            );

            // Handle preferredCuisines
            final preferredCuisines = userData['preferredCuisines'];
            print('Raw preferredCuisines data: $preferredCuisines');

            if (preferredCuisines != null) {
              if (preferredCuisines is List) {
                _selectedCuisines = preferredCuisines
                    .map((cuisine) => cuisine.toString().toLowerCase())
                    .toList();
              } else if (preferredCuisines is String) {
                _selectedCuisines = preferredCuisines
                    .split(',')
                    .map((e) => e.trim().toLowerCase())
                    .where((e) => e.isNotEmpty)
                    .toList();
              }
            } else {
              _selectedCuisines = [];
            }
            print('Processed selected cuisines: $_selectedCuisines');

            // Update the available cuisines list to match the database values
            _cuisines.clear();
            _cuisines.addAll([
              'south indian',
              'north indian',
              'continental',
              'chinese',
              'mediterranean',
              'indian',
            ]);

            _selectedNutrients = List<String>.from(
              userData['nutrientsSelected'] ?? [],
            );
            _dislikedFoods = List<String>.from(userData['dislikedFoods'] ?? []);

            print('Arrays loaded:');
            print('Medical Conditions: $_selectedConditions');
            print('Preferred Cuisines: $_selectedCuisines');
            print('Selected Nutrients: $_selectedNutrients');
            print('Disliked Foods: $_dislikedFoods');
          });
        } else {
          print('No user document found');
        }
      }
    } catch (e, stackTrace) {
      print('Error loading user data: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile data. Please try again.'),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 200,
      maxHeight: 200,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Save user profile data
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text,
        'allergies': _allergiesController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Save recommendations data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recommendations')
          .doc(uid)
          .update({
        'age': int.tryParse(_ageController.text),
        'height': double.tryParse(_heightController.text),
        'weight': double.tryParse(_weightController.text),
        'gender': _gender,
        'activity': _activityLevel,
        'food_preference': _foodPreference,
        'meals_per_day': _mealsPerDay,
        'conditions': _selectedConditions,
        'cuisines': _selectedCuisines,
        'nutrients': _selectedNutrients,
        'dislikes': _dislikedFoods,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile. Please try again.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (_isEditMode) {
        _editModeController.forward();
      } else {
        _editModeController.reverse();
      }
    });
  }

  Widget _buildEditModeToggle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _toggleEditMode,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _isEditMode
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: _isEditMode
                        ? Colors.white
                        : isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Edit',
                    style: TextStyle(
                      color: _isEditMode
                          ? Colors.white
                          : isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: !_isEditMode
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility,
                    color: !_isEditMode
                        ? Colors.white
                        : isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'View',
                    style: TextStyle(
                      color: !_isEditMode
                          ? Colors.white
                          : isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedOpacity(
      opacity: _isEditMode ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: AnimatedSlide(
        offset: Offset(0, _isEditMode ? 0 : 1),
        duration: Duration(milliseconds: 300),
        child: Container(
          width: double.infinity,
          height: 50,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: _isEditMode ? _saveProfile : null,
            child: Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: isDarkMode
                      ? Theme.of(context).primaryColor.withOpacity(0.15)
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : _imageUrl != null
                          ? CachedNetworkImageProvider(_imageUrl!)
                              as ImageProvider
                          : null,
                  child: _imageFile == null && _imageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 70,
                          color: isDarkMode
                              ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.7)
                              : Theme.of(context).primaryColor,
                        )
                      : null,
                ),
              ),
              if (_isEditMode)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSectionTitle(String title, {bool isDarkMode = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Theme.of(context).cardColor.withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
        border: isDarkMode
            ? Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                width: 1,
              )
            : null,
      ),
      child: child,
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
    bool isDarkMode = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(
        color: isDarkMode ? Colors.white70 : null,
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: isDarkMode ? Colors.white38 : Colors.grey,
        fontSize: 16,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: isDarkMode ? Colors.white70 : null,
        size: 20,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white24 : Colors.grey,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white24 : Colors.grey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      filled: !_isEditMode,
      fillColor: !_isEditMode
          ? (isDarkMode ? Colors.grey[800] : Colors.grey[100])
          : null,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildPersonalInfoSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Information'),
          TextFormField(
            controller: _nameController,
            enabled: _isEditMode,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            decoration: _buildInputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icons.person,
              isDarkMode: isDarkMode,
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter your name' : null,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  enabled: _isEditMode,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icons.calendar_today,
                    isDarkMode: isDarkMode,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter your age';
                    final age = int.tryParse(value!);
                    if (age == null || age < 5 || age > 120) {
                      return 'Enter a valid age';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icons.people,
                    isDarkMode: isDarkMode,
                  ),
                  items: _genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender, style: TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: _isEditMode
                      ? (value) {
                          if (value != null) setState(() => _gender = value);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Body Metrics'),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  enabled: _isEditMode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Height (cm)',
                    prefixIcon: Icons.height,
                    isDarkMode: isDarkMode,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'Please enter your height';
                    final height = double.tryParse(value!);
                    if (height == null || height < 50 || height > 275) {
                      return 'Enter a valid height';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  enabled: _isEditMode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icons.monitor_weight,
                    isDarkMode: isDarkMode,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'Please enter your weight';
                    final weight = double.tryParse(value!);
                    if (weight == null || weight < 10 || weight > 350) {
                      return 'Enter a valid weight';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPreferencesSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Dietary Preferences'),
          DropdownButtonFormField<String>(
            value: _activityLevel,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            decoration: _buildInputDecoration(
              labelText: 'Activity Level',
              prefixIcon: Icons.fitness_center,
              isDarkMode: isDarkMode,
            ),
            items: _activityLevels.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              );
            }).toList(),
            onChanged: _isEditMode
                ? (value) {
                    if (value != null) setState(() => _activityLevel = value);
                  }
                : null,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _foodPreference,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            decoration: _buildInputDecoration(
              labelText: 'Food Preference',
              prefixIcon: Icons.restaurant,
              isDarkMode: isDarkMode,
            ),
            items: _foodPreferences.map((pref) {
              return DropdownMenuItem(
                value: pref,
                child: Text(
                  pref,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              );
            }).toList(),
            onChanged: _isEditMode
                ? (value) {
                    if (value != null) setState(() => _foodPreference = value);
                  }
                : null,
          ),
          SizedBox(height: 16),
          _buildSubSectionTitle(
            'Meals per Day: $_mealsPerDay',
            isDarkMode: isDarkMode,
          ),
          Slider(
            value: _mealsPerDay.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            label: _mealsPerDay.toString(),
            onChanged: _isEditMode
                ? (value) {
                    setState(() => _mealsPerDay = value.toInt());
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Health Information'),
          TextFormField(
            controller: _allergiesController,
            enabled: _isEditMode,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            decoration: _buildInputDecoration(
              labelText: 'Allergies (comma-separated)',
              prefixIcon: Icons.warning_amber,
              isDarkMode: isDarkMode,
            ),
          ),
          SizedBox(height: 16),
          _buildSubSectionTitle('Medical Conditions', isDarkMode: isDarkMode),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _conditions.map((condition) {
              final isSelected = _selectedConditions.contains(condition);
              return FilterChip(
                label: Text(
                  condition,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? (isDarkMode ? Colors.white : Colors.black87)
                        : (isDarkMode ? Colors.white70 : Colors.black87),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: _isEditMode
                    ? (selected) {
                        setState(() {
                          if (selected) {
                            _selectedConditions.add(condition);
                          } else {
                            _selectedConditions.remove(condition);
                          }
                        });
                      }
                    : null,
                selectedColor: isDarkMode
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor:
                    isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                backgroundColor:
                    isDarkMode ? Colors.grey[900] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: isSelected ? 2 : 0,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Food Preferences'),
          _buildSubSectionTitle('Preferred Cuisines', isDarkMode: isDarkMode),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cuisines.map((cuisine) {
              final isSelected = _selectedCuisines.contains(cuisine);
              return FilterChip(
                label: Text(
                  cuisine,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? (isDarkMode ? Colors.white : Colors.black87)
                        : (isDarkMode ? Colors.white70 : Colors.black87),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: _isEditMode
                    ? (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCuisines.add(cuisine);
                          } else {
                            _selectedCuisines.remove(cuisine);
                          }
                        });
                      }
                    : null,
                selectedColor: isDarkMode
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor:
                    isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                backgroundColor:
                    isDarkMode ? Colors.grey[900] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: isSelected ? 2 : 0,
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          _buildSubSectionTitle('Nutrient Focus', isDarkMode: isDarkMode),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _nutrients.map((nutrient) {
              final isSelected = _selectedNutrients.contains(nutrient);
              return FilterChip(
                label: Text(
                  nutrient,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? (isDarkMode ? Colors.white : Colors.black87)
                        : (isDarkMode ? Colors.white70 : Colors.black87),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: _isEditMode
                    ? (selected) {
                        setState(() {
                          if (selected) {
                            _selectedNutrients.add(nutrient);
                          } else {
                            _selectedNutrients.remove(nutrient);
                          }
                        });
                      }
                    : null,
                selectedColor: isDarkMode
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor:
                    isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                backgroundColor:
                    isDarkMode ? Colors.grey[900] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: isSelected ? 2 : 0,
              );
            }).toList(),
          ),
          if (_dislikedFoods.isNotEmpty) ...[
            SizedBox(height: 16),
            _buildSubSectionTitle('Disliked Foods', isDarkMode: isDarkMode),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dislikedFoods.map((food) {
                return Chip(
                  label: Text(
                    food,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  backgroundColor:
                      isDarkMode ? Colors.grey[900] : Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _loadAddresses() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final addresses = List<Map<String, dynamic>>.from(
            userData['addresses'] ?? [],
          );
          setState(() {
            _addresses = addresses;
            if (_addresses.isNotEmpty) {
              _selectedAddressIndex = _addresses.indexWhere(
                (addr) => addr['isDefault'] == true,
              );
              if (_selectedAddressIndex == -1) _selectedAddressIndex = 0;
              _loadAddressIntoControllers(_addresses[_selectedAddressIndex]);
            }
          });
        }
      }
    } catch (e) {
      print('Error loading addresses: $e');
    }
  }

  void _loadAddressIntoControllers(Map<String, dynamic> address) {
    _addressLine1Controller.text = address['line1'] ?? '';
    _addressLine2Controller.text = address['line2'] ?? '';
    _landmarkController.text = address['landmark'] ?? '';
    _pincodeController.text = address['pincode'] ?? '';
    _cityController.text = address['city'] ?? '';
    _stateController.text = address['state'] ?? '';
    _deliveryInstructionsController.text =
        address['deliveryInstructions'] ?? '';
    _isDefaultAddress = address['isDefault'] ?? false;
  }

  void _clearAddressControllers() {
    _addressLine1Controller.clear();
    _addressLine2Controller.clear();
    _landmarkController.clear();
    _pincodeController.clear();
    _cityController.clear();
    _stateController.clear();
    _deliveryInstructionsController.clear();
    _isDefaultAddress = false;
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final newAddress = {
      'line1': _addressLine1Controller.text,
      'line2': _addressLine2Controller.text,
      'landmark': _landmarkController.text,
      'pincode': _pincodeController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'deliveryInstructions': _deliveryInstructionsController.text,
      'isDefault': _isDefaultAddress,
    };

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      List<Map<String, dynamic>> updatedAddresses = List.from(_addresses);

      if (_isAddingNewAddress) {
        updatedAddresses.add(newAddress);
      } else if (_isModifyingAddress) {
        updatedAddresses[_selectedAddressIndex] = newAddress;
      }

      // If this address is set as default, update other addresses
      if (_isDefaultAddress) {
        updatedAddresses = updatedAddresses.map((addr) {
          if (addr != newAddress) {
            addr['isDefault'] = false;
          }
          return addr;
        }).toList();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'addresses': updatedAddresses,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _addresses = updatedAddresses;
        _isAddingNewAddress = false;
        _isModifyingAddress = false;
        _selectedAddressIndex = _addresses.indexWhere(
          (addr) => addr['isDefault'] == true,
        );
        if (_selectedAddressIndex == -1) _selectedAddressIndex = 0;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Address saved successfully!')));
    } catch (e) {
      print('Error saving address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving address. Please try again.')),
      );
    }
  }

  Widget _buildAddressSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Delivery Addresses'),
              if (!_isAddingNewAddress && !_isModifyingAddress)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isAddingNewAddress = true;
                      _clearAddressControllers();
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: isDarkMode
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Add New Address',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
          if (_addresses.isEmpty && !_isAddingNewAddress)
            Center(
              child: Column(
                children: [
                  Icon(Icons.location_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No addresses added yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isAddingNewAddress = true;
                        _clearAddressControllers();
                      });
                    },
                    icon: Icon(Icons.add_location),
                    label: Text('Add Your First Address'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else if (!_isAddingNewAddress && !_isModifyingAddress)
            Column(
              children: [
                ...List.generate(_addresses.length, (index) {
                  final address = _addresses[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                    elevation: isDarkMode ? 4 : 2,
                    shadowColor: isDarkMode ? Colors.black : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            isDarkMode ? Color(0xFF2C2C2C) : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAddressIndex = index;
                          _loadAddressIntoControllers(address);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedAddressIndex == index
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Address ${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                if (address['isDefault'] == true)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Default',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Theme.of(
                                                context,
                                              ).primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              '${address['line1']}, ${address['line2']}',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            if (address['landmark']?.isNotEmpty ?? false)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Near ${address['landmark']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${address['city']}, ${address['state']} - ${address['pincode']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isModifyingAddress = true;
                                      _selectedAddressIndex = index;
                                      _loadAddressIntoControllers(address);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  label: Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    backgroundColor: isDarkMode
                                        ? Color(0xFF2C2C2C)
                                        : Colors.grey[100],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: isDarkMode
                                            ? Color(0xFF3C3C3C)
                                            : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                TextButton.icon(
                                  onPressed: () async {
                                    try {
                                      final uid = FirebaseAuth
                                          .instance.currentUser?.uid;
                                      if (uid == null) return;

                                      List<Map<String, dynamic>>
                                          updatedAddresses =
                                          List.from(_addresses);
                                      updatedAddresses.removeAt(index);

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(uid)
                                          .update({
                                        'addresses': updatedAddresses,
                                      });

                                      setState(() {
                                        _addresses = updatedAddresses;
                                        if (_selectedAddressIndex >=
                                            _addresses.length) {
                                          _selectedAddressIndex =
                                              _addresses.length - 1;
                                        }
                                        if (_addresses.isNotEmpty) {
                                          _loadAddressIntoControllers(
                                            _addresses[_selectedAddressIndex],
                                          );
                                        }
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Address deleted successfully',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      print('Error deleting address: $e');
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error deleting address',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: isDarkMode
                                        ? Colors.red[300]
                                        : Colors.red[400],
                                  ),
                                  label: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.red[300]
                                          : Colors.red[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    backgroundColor: isDarkMode
                                        ? Color(0xFF2C1A1A)
                                        : Colors.red[50],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: isDarkMode
                                            ? Color(0xFF3C2A2A)
                                            : Colors.red[100]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAddingNewAddress ? 'Add New Address' : 'Edit Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressLine1Controller,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Address Line 1',
                    hintText: 'House/Flat number, Building name',
                    prefixIcon: Icons.home,
                    isDarkMode: isDarkMode,
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter your address'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressLine2Controller,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Address Line 2',
                    hintText: 'Street name, Area',
                    prefixIcon: Icons.location_city,
                    isDarkMode: isDarkMode,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _landmarkController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        decoration: _buildInputDecoration(
                          labelText: 'Landmark',
                          hintText: 'Nearby location',
                          prefixIcon: Icons.place,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        decoration: _buildInputDecoration(
                          labelText: 'Pincode',
                          prefixIcon: Icons.pin,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Please enter pincode';
                          if (value!.length != 6)
                            return 'Enter valid 6-digit pincode';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        decoration: _buildInputDecoration(
                          labelText: 'City',
                          prefixIcon: Icons.location_city,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter your city'
                            : null,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        decoration: _buildInputDecoration(
                          labelText: 'State',
                          prefixIcon: Icons.map,
                          isDarkMode: isDarkMode,
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter your state'
                            : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _deliveryInstructionsController,
                  maxLines: 2,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Delivery Instructions',
                    hintText: 'Any specific instructions for delivery',
                    prefixIcon: Icons.delivery_dining,
                    isDarkMode: isDarkMode,
                  ),
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text(
                    'Set as Default Address',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  value: _isDefaultAddress,
                  onChanged: (value) {
                    setState(() {
                      _isDefaultAddress = value;
                    });
                  },
                  activeColor: isDarkMode
                      ? Colors.lightGreen
                      : Theme.of(context).primaryColor,
                  activeTrackColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.5),
                  inactiveTrackColor: Colors.grey[300],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isAddingNewAddress = false;
                          _isModifyingAddress = false;
                          if (_addresses.isNotEmpty) {
                            _loadAddressIntoControllers(
                              _addresses[_selectedAddressIndex],
                            );
                          }
                        });
                      },
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saveAddress,
                      child: Text('Save Address'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Debug prints for current state
    print('Current state in build:');
    print('Activity Level: $_activityLevel');
    print('Food Preference: $_foodPreference');
    print('Meals per day: $_mealsPerDay');
    print('Selected Conditions: $_selectedConditions');
    print('Selected Cuisines: $_selectedCuisines');
    print('Selected Nutrients: $_selectedNutrients');
    print('Disliked Foods: $_dislikedFoods');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Theme.of(context).primaryColor.withOpacity(0.2),
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
          ),
        ),
        child: isLoading
            ? ModernLoadingScreen(message: 'Loading your profile...')
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        SizedBox(height: 24),
                        _buildEditModeToggle(),
                        SizedBox(height: 16),
                        _buildPersonalInfoSection(),
                        SizedBox(height: 16),
                        _buildBodyMetricsSection(),
                        SizedBox(height: 16),
                        _buildDietaryPreferencesSection(),
                        SizedBox(height: 16),
                        _buildHealthSection(),
                        SizedBox(height: 16),
                        _buildPreferencesSection(),
                        SizedBox(height: 16),
                        _buildAddressSection(),
                        SizedBox(height: 32),
                        _buildSaveButton(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
