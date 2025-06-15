import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../loading.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? recommendationData;
  String? nextMealName;
  Map<String, dynamic>? nextMealData;
  double? tdee;
  int streakDays = 0;
  List<Map<String, dynamic>> completedMeals = [];
  List<Map<String, dynamic>> upcomingMeals = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<String> mealTypes = [];

  // Nutritional targets (example values - adjust as needed)
  final Map<String, double> nutritionalTargets = {
    'calories': 2000.0,
    'protein': 50.0,
    'carbohydrate': 250.0,
    'fat': 70.0,
    'fibre': 30.0,
    'calcium': 1000.0,
    'iron': 18.0,
  };

  // Colors for different nutrients
  final Map<String, Color> nutrientColors = {
    'calories': Colors.orange,
    'protein': Colors.blue,
    'carbohydrate': Colors.green,
    'fat': Colors.red,
    'fibre': Colors.purple,
    'calcium': Colors.teal,
    'iron': Colors.amber,
  };

  // Define meal order and their typical times
  final Map<String, int> mealOrder = {
    'pre_breakfast': 0,
    'breakfast': 1,
    'lunch': 2,
    'dinner': 3,
    'snacks': 4,
    'post_dinner': 5,
  };

  // Define typical meal times (in 24-hour format)
  final Map<String, int> mealTimes = {
    'pre_breakfast': 6, // 6 AM
    'breakfast': 8, // 8 AM
    'lunch': 13, // 1 PM
    'dinner': 19, // 7 PM
    'snacks': 15, // 3 PM
    'post_dinner': 21, // 9 PM
  };

  void _organizeMeals(Map<String, dynamic> mealsToday) {
    final now = DateTime.now();
    final currentHour = now.hour;

    completedMeals = [];
    upcomingMeals = [];

    // Sort meal types based on meal order
    final sortedMealTypes = mealsToday.keys.toList()
      ..sort(
        (a, b) => (mealOrder[a] ?? 999).compareTo(mealOrder[b] ?? 999),
      );

    for (final mealType in sortedMealTypes) {
      final mealData = mealsToday[mealType];
      final mealTime = mealTimes[mealType] ?? 12;
      final meal = {'type': mealType, 'data': mealData, 'time': mealTime};

      if (mealTime < currentHour) {
        completedMeals.add(meal);
      } else {
        upcomingMeals.add(meal);
      }
    }

    // Sort completed meals by time (most recent first)
    completedMeals.sort((a, b) => b['time'].compareTo(a['time']));

    // Sort upcoming meals by time
    upcomingMeals.sort((a, b) => a['time'].compareTo(b['time']));
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    fetchDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchDashboardData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      print('Fetching dashboard data for user: $uid');

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recommendations')
          .get();

      print('Number of documents: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        print('Document ID: ${doc.id}');
        final data = doc.data();
        print('Document data: $data');

        if (data.containsKey('recommendation')) {
          final recommendation = data['recommendation'];
          print('Recommendation data: $recommendation');

          if (recommendation.containsKey('plan')) {
            final plan = recommendation['plan'];
            final today =
                DateFormat('EEEE').format(DateTime.now()).toLowerCase();
            final mealsToday = plan[today];

            // Get meal types from today's data
            mealTypes = mealsToday.keys.toList()
              ..sort(
                (a, b) => (mealOrder[a] ?? 999).compareTo(mealOrder[b] ?? 999),
              );

            print('Today\'s meals: $mealsToday');

            // Organize meals into completed and upcoming
            _organizeMeals(mealsToday);

            // Determine next meal
            String? mealToShow =
                upcomingMeals.isNotEmpty ? upcomingMeals.first['type'] : null;

            setState(() {
              recommendationData = recommendation;
              tdee = (recommendation['tdee'] is int)
                  ? (recommendation['tdee'] as int).toDouble()
                  : recommendation['tdee'] as double?;
              nextMealName = mealToShow;
              nextMealData = mealToShow != null ? mealsToday[mealToShow] : null;
              streakDays = recommendation['streak'] ?? 0;
            });
          } else {
            print('Plan key not found in recommendation');
          }
        } else {
          print('Recommendation key not found');
        }
      } else {
        print('No documents found in recommendations collection');
      }
    } catch (e, stackTrace) {
      print('Error fetching dashboard data: $e');
      print('Stack trace: $stackTrace');
      // You might want to show an error message to the user here
    }
  }

  Widget _buildMealCard(String title, List<Map<String, dynamic>> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 8),
        ...meals.map((meal) {
          final mealType = meal['type'] as String? ?? '';
          final mealData = meal['data'] as Map<String, dynamic>? ?? {};
          final mealTime = meal['time'] as int? ?? 0;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: ListTile(
              leading: Icon(
                _getMealIcon(mealType),
                color: _getMealColor(mealType),
              ),
              title: Text(
                "${mealType.capitalize()}: ${mealData['recipe_name'] ?? 'No recipe name'}",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                "${_formatCalories(mealData['calories'])} kcal",
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Text(
                "${mealTime.toString().padLeft(2, '0')}:00",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatCalories(dynamic calories) {
    if (calories == null) return '0.0';
    if (calories is int) return calories.toDouble().toStringAsFixed(1);
    if (calories is double) return calories.toStringAsFixed(1);
    return '0.0';
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'pre_breakfast':
        return Icons.wb_sunny_outlined;
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snacks':
        return Icons.cake;
      case 'post_dinner':
        return Icons.nightlight;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'pre_breakfast':
        return Colors.amber;
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snacks':
        return Colors.purple;
      case 'post_dinner':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _showNutritionInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nutrition Information',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Daily Targets'),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: nutritionalTargets.entries.map((entry) {
                            final color =
                                nutrientColors[entry.key] ?? Colors.grey;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.key.capitalize(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${entry.value.toStringAsFixed(1)}',
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 24),
                      _buildSectionHeader('Meal Distribution'),
                      SizedBox(height: 12),
                      ...mealTimes.entries.map((entry) {
                        final mealType = entry.key;
                        final mealData = recommendationData?['plan']?[
                            DateFormat('EEEE')
                                .format(DateTime.now())
                                .toLowerCase()]?[mealType];
                        if (mealData == null) return SizedBox.shrink();

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _getMealIcon(mealType),
                                      color: _getMealColor(mealType),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      mealType.capitalize(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: _getMealColor(mealType),
                                      ),
                                    ),
                                    Spacer(),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getMealColor(
                                          mealType,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child: Text(
                                        '${mealData['calories']?.toStringAsFixed(1) ?? '0'} kcal',
                                        style: TextStyle(
                                          color: _getMealColor(mealType),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  mealData['recipe_name'] ?? 'No recipe name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildNutritionChip(
                                      'Protein',
                                      '${mealData['protein']?.toStringAsFixed(1) ?? '0'}g',
                                      Colors.blue,
                                    ),
                                    _buildNutritionChip(
                                      'Carbs',
                                      '${mealData['carbohydrate']?.toStringAsFixed(1) ?? '0'}g',
                                      Colors.green,
                                    ),
                                    _buildNutritionChip(
                                      'Fat',
                                      '${mealData['fat']?.toStringAsFixed(1) ?? '0'}g',
                                      Colors.red,
                                    ),
                                    _buildNutritionChip(
                                      'Fiber',
                                      '${mealData['fibre']?.toStringAsFixed(1) ?? '0'}g',
                                      Colors.purple,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildNutritionChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionGraphs() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Nutrition',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: _showNutritionInfoDialog,
                ),
              ],
            ),
            SizedBox(height: 24),
            // Main metrics in a grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildCircularProgress(
                  'Calories',
                  nextMealData?['calories'] ?? 0,
                  nutritionalTargets['calories'] ?? 2000,
                  nutrientColors['calories'] ?? Colors.orange,
                ),
                _buildCircularProgress(
                  'Protein',
                  nextMealData?['protein'] ?? 0,
                  nutritionalTargets['protein'] ?? 50,
                  nutrientColors['protein'] ?? Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Other Nutrients',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            _buildBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(
    String label,
    dynamic value,
    double target,
    Color color,
  ) {
    final doubleValue =
        value is int ? value.toDouble() : (value as double? ?? 0.0);
    final percentage = (doubleValue / target).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              children: [
                Center(
                  child: CircularProgressIndicator(
                    value: percentage,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 8,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        '${doubleValue.toStringAsFixed(1)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            'of ${target.toStringAsFixed(1)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final nutrients = [
      {
        'name': 'Carbs',
        'value': nextMealData?['carbohydrate'] ?? 0,
        'target': nutritionalTargets['carbohydrate'] ?? 250,
      },
      {
        'name': 'Fat',
        'value': nextMealData?['fat'] ?? 0,
        'target': nutritionalTargets['fat'] ?? 70,
      },
      {
        'name': 'Fiber',
        'value': nextMealData?['fibre'] ?? 0,
        'target': nutritionalTargets['fibre'] ?? 30,
      },
      {
        'name': 'Calcium',
        'value': nextMealData?['calcium'] ?? 0,
        'target': nutritionalTargets['calcium'] ?? 1000,
      },
      {
        'name': 'Iron',
        'value': nextMealData?['iron'] ?? 0,
        'target': nutritionalTargets['iron'] ?? 18,
      },
    ];

    return Column(
      children: nutrients.map((nutrient) {
        final value = nutrient['value'] is int
            ? (nutrient['value'] as int).toDouble()
            : (nutrient['value'] as double? ?? 0.0);
        final target = nutrient['target'] is int
            ? (nutrient['target'] as int).toDouble()
            : (nutrient['target'] as double? ?? 0.0);
        final percentage = (value / target).clamp(0.0, 1.0);
        final color =
            nutrientColors[nutrient['name'].toString().toLowerCase()] ??
                Colors.grey;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        nutrient['name'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${value.toStringAsFixed(1)}/${target.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Dashboard'),
          backgroundColor: Colors.lightGreen.withAlpha(120),
          elevation: 0),
      body: recommendationData == null
          ? ModernLoadingScreen(message: 'Loading your dashboard...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                      title: Text(
                        'Total Daily Energy Expenditure',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${tdee?.toStringAsFixed(2) ?? '0.00'} kcal',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildNutritionGraphs(),
                  SizedBox(height: 16),
                  if (completedMeals.isNotEmpty) ...[
                    _buildMealCard("Completed Meals", completedMeals),
                    SizedBox(height: 16),
                  ],
                  if (upcomingMeals.isNotEmpty) ...[
                    _buildMealCard("Upcoming Meals", upcomingMeals),
                    SizedBox(height: 16),
                  ],
                  if (completedMeals.isEmpty && upcomingMeals.isEmpty)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(Icons.no_meals, color: Colors.grey),
                        title: Text(
                          "No meals scheduled",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          "Complete your profile to get recommendations",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.bolt, color: Colors.blue),
                      title: Text(
                        "Current Streak",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        "$streakDays days",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
