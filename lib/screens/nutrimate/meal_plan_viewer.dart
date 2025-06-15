import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../loading.dart';

class MealPlanViewer extends StatefulWidget {
  MealPlanViewer({super.key});
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  State<MealPlanViewer> createState() => _MealPlanViewerState();
}

class _MealPlanViewerState extends State<MealPlanViewer>
    with TickerProviderStateMixin {
  Map<String, dynamic>? plan;
  bool isLoading = true;
  String? errorMessage;
  List<String> days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  String selectedDay = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<String> mealTypes = [];

  // Define meal order for sorting
  final Map<String, int> mealOrder = {
    'pre_breakfast': 0,
    'breakfast': 1,
    'lunch': 2,
    'snacks': 3,
    'dinner': 4,
    'post_dinner': 5,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await fetchPlan();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load meal plan. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPlan() async {
    try {
      print('Fetching plan for user: ${widget.uid}');

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('recommendations')
          .get();

      print('Number of documents: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        print('Document ID: ${doc.id}');
        final data = doc.data();
        print('Document data: $data');

        if (data.containsKey('recommendation')) {
          print('Recommendation data: ${data['recommendation']}');

          if (data['recommendation'].containsKey('plan')) {
            print('Plan data found');
            final planData = data['recommendation']['plan'];

            // Get meal types from the first day's data
            if (planData.isNotEmpty) {
              final firstDay = planData.keys.first;
              mealTypes = planData[firstDay].keys.toList();
              // Sort meal types based on meal order
              mealTypes.sort(
                (a, b) => (mealOrder[a] ?? 999).compareTo(mealOrder[b] ?? 999),
              );
            }

            setState(() {
              plan = planData;
              print('Plan loaded: $plan');
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
    } catch (e) {
      print('Error fetching plan: $e');
      rethrow;
    }
  }

  Widget _buildNutritionInfo(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
        border: isDarkMode
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDarkMode
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).primaryColor,
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String mealType, Map<String, dynamic> mealData) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: isDarkMode ? 0 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isDarkMode
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
          border: isDarkMode
              ? Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  width: 1,
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mealType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.15)
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: isDarkMode
                          ? Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Text(
                      '${mealData['calories'].toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        color: isDarkMode
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                mealData['recipe_name'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildNutritionInfo(
                    'Protein',
                    '${mealData['protein'].toStringAsFixed(1)}g',
                    Icons.fitness_center,
                    isDarkMode,
                  ),
                  _buildNutritionInfo(
                    'Carbs',
                    '${mealData['carbohydrate'].toStringAsFixed(1)}g',
                    Icons.grain,
                    isDarkMode,
                  ),
                  _buildNutritionInfo(
                    'Fat',
                    '${mealData['fat'].toStringAsFixed(1)}g',
                    Icons.water_drop,
                    isDarkMode,
                  ),
                  _buildNutritionInfo(
                    'Fiber',
                    '${mealData['fibre']}g',
                    Icons.eco,
                    isDarkMode,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? ModernLoadingScreen(message: 'Loading your meal plan...')
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : plan == null || plan!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.no_meals, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No meal plan available',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please complete your profile to get recommendations',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _initializeData,
                            child: Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 48, bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.lightGreen.withAlpha(120),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Your Meal Plan',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 16),
                              Container(
                                height: 50,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: days.length,
                                  itemBuilder: (context, index) {
                                    final day = days[index];
                                    final isSelected = selectedDay == day;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedDay = day;
                                          _animationController.reset();
                                          _animationController.forward();
                                        });
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            day[0].toUpperCase() +
                                                day.substring(1),
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Colors.white,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
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
                        ),
                        Expanded(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ListView(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              children: [
                                ...mealTypes.map((mealType) {
                                  final mealData = plan![selectedDay][mealType];
                                  return _buildMealCard(mealType, mealData);
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
