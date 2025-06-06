// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MealPlannerApp());
}

class MealPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// models/meal_plan.dart
class MealPlan {
  final String status;
  final int tdee;
  final int mealsPerDay;
  final List<String> mealTypes;
  final Map<String, DayPlan> plan;

  MealPlan({
    required this.status,
    required this.tdee,
    required this.mealsPerDay,
    required this.mealTypes,
    required this.plan,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    Map<String, DayPlan> planMap = {};
    json['plan'].forEach((day, meals) {
      planMap[day] = DayPlan.fromJson(meals);
    });

    return MealPlan(
      status: json['status'],
      tdee: json['tdee'],
      mealsPerDay: json['meals_per_day'],
      mealTypes: List<String>.from(json['meal_types']),
      plan: planMap,
    );
  }
}

class DayPlan {
  final Meal breakfast;
  final Meal lunch;
  final Meal snacks;
  final Meal dinner;

  DayPlan({
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
  });

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      breakfast: Meal.fromJson(json['breakfast']),
      lunch: Meal.fromJson(json['lunch']),
      snacks: Meal.fromJson(json['snacks']),
      dinner: Meal.fromJson(json['dinner']),
    );
  }

  List<Meal> get meals => [breakfast, lunch, snacks, dinner];
}

class Meal {
  final String recipeCode;
  final String recipeName;
  final double calories;
  final double protein;
  final double carbohydrate;
  final double fat;
  final double fibre;
  final double calcium;
  final double iron;
  final double? score;

  Meal({
    required this.recipeCode,
    required this.recipeName,
    required this.calories,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
    required this.fibre,
    required this.calcium,
    required this.iron,
    this.score,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      recipeCode: json['recipe_code'] ?? 'default',
      recipeName: json['recipe_name'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbohydrate: json['carbohydrate'].toDouble(),
      fat: json['fat'].toDouble(),
      fibre: json['fibre'].toDouble(),
      calcium: json['calcium'].toDouble(),
      iron: json['iron'].toDouble(),
      score: json['score']?.toDouble(),
    );
  }
}

// services/firestore_service.dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save meal recommendation
  Future<void> saveMealRecommendation(Map<String, dynamic> data, Map<String, dynamic> userData) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('recommendations')
        .add({
      'recommendation': data,
      'based_on': userData,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Get latest meal plan
  Stream<MealPlan?> getMealPlan() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('recommendations')
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final data = snapshot.docs.first.data()['recommendation'];
      return MealPlan.fromJson(data);
    });
  }

  // Save daily meal completion
  Future<void> markMealCompleted(String day, String mealType) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('meal_logs')
        .doc(today)
        .set({
      '${day}_$mealType': true,
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get streak data
  Stream<int> getStreak() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('meal_logs')
        .orderBy('last_updated', descending: true)
        .snapshots()
        .map((snapshot) {
      // Calculate streak based on consecutive days
      int streak = 0;
      // Implementation for streak calculation
      return streak;
    });
  }
}

// screens/home_screen.dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();

  final List<Widget> _screens = [
    DashboardScreen(),
    MealPlanScreen(),
    StreaksScreen(),
    OrdersScreen(),
    ExerciseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Streaks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercise',
          ),
        ],
      ),
    );
  }
}

// screens/dashboard_screen.dart
class DashboardScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: StreamBuilder<MealPlan?>(
        stream: _firestoreService.getMealPlan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final mealPlan = snapshot.data;
          if (mealPlan == null) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingCard(context, mealPlan),
                SizedBox(height: 20),
                _buildQuickStats(mealPlan),
                SizedBox(height: 20),
                _buildTodaysMeals(context, mealPlan),
                SizedBox(height: 20),
                _buildQuickActions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context, MealPlan mealPlan) {
    final today = DateTime.now().weekday;
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayPlan = mealPlan.plan[dayNames[today - 1]];
    
    double totalCalories = 0;
    if (todayPlan != null) {
      totalCalories = todayPlan.meals.fold(0, (sum, meal) => sum + meal.calories);
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_getTimeOfDay()}!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'TDEE: ${mealPlan.tdee} cal',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Today\'s Plan: ${totalCalories.toInt()} cal',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 15),
          StreamBuilder<int>(
            stream: _firestoreService.getStreak(),
            builder: (context, streakSnapshot) {
              final streak = streakSnapshot.data ?? 0;
              return Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    '$streak Day Streak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(MealPlan mealPlan) {
    final today = DateTime.now().weekday;
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayPlan = mealPlan.plan[dayNames[today - 1]];
    
    if (todayPlan == null) return SizedBox.shrink();

    double totalProtein = todayPlan.meals.fold(0, (sum, meal) => sum + meal.protein);
    double totalCarbs = todayPlan.meals.fold(0, (sum, meal) => sum + meal.carbohydrate);
    double totalFat = todayPlan.meals.fold(0, (sum, meal) => sum + meal.fat);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Macros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Protein', totalProtein, Colors.red),
              _buildMacroItem('Carbs', totalCarbs, Colors.blue),
              _buildMacroItem('Fat', totalFat, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              '${value.toInt()}g',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysMeals(BuildContext context, MealPlan mealPlan) {
    final today = DateTime.now().weekday;
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayPlan = mealPlan.plan[dayNames[today - 1]];
    
    if (todayPlan == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Meals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealPlanScreen(),
                  ),
                ),
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildMealCard('Breakfast', todayPlan.breakfast, Icons.free_breakfast),
          _buildMealCard('Lunch', todayPlan.lunch, Icons.lunch_dining),
          _buildMealCard('Snacks', todayPlan.snacks, Icons.cookie),
          _buildMealCard('Dinner', todayPlan.dinner, Icons.dinner_dining),
        ],
      ),
    );
  }

  Widget _buildMealCard(String mealType, Meal meal, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  meal.recipeName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${meal.calories.toInt()} cal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                'Orders',
                Icons.shopping_cart,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersScreen()),
                ),
              ),
              _buildActionButton(
                'Exercise',
                Icons.fitness_center,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExerciseScreen()),
                ),
              ),
              _buildActionButton(
                'Analytics',
                Icons.bar_chart,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnalyticsScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No meal plan found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Generate your personalized meal plan to get started',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  void _showNotifications(BuildContext context) {
    // Implementation for notifications
  }

  void _openSettings(BuildContext context) {
    // Implementation for settings
  }
}

// Placeholder screens for other features
class MealPlanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Plan')),
      body: Center(child: Text('Meal Plan Screen')),
    );
  }
}

class StreaksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Streaks & Habits')),
      body: Center(child: Text('Streaks Screen')),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: Center(child: Text('Orders Screen')),
    );
  }
}

class ExerciseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise')),
      body: Center(child: Text('Exercise Screen')),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics')),
      body: Center(child: Text('Analytics Screen')),
    );
  }
}