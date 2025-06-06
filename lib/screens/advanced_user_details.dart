import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrition_app/provider/advanced_user_details_provider.dart';

class AdvancedUserDetailsScreen extends ConsumerWidget {
  final List<String> activityLevels = ["Sedentary", "Lightly", "Active", "Very"];
  final List<String> conditions = ["Diabetes", "Hypertension", "Thyroid", "Healthy"," Heart Disease","Kidney Disease","PCOD/PCOS"];
  final List<String> cuisines = ["indian", "north indian", "south indian", "continental","chinese","mediterranean"];
  final TextEditingController dislikeController = TextEditingController();
  final List<String> nutrients = ["Iron", "Fiber", "Protein", "Calcium"];

bool validateInputs(BuildContext context, AdvancedUserDetails state) {
  if (state.activityLevel == null || state.activityLevel!.isEmpty) {
    _showSnackBar(context, 'Please select your Activity Level');
    return false;
  }

  if (state.conditions == null||state.conditions.isEmpty) {
    _showSnackBar(context, 'Please select at least one Medical Condition');
    return false;
  }

  if (state.cuisines == null||state.cuisines.isEmpty) {
    _showSnackBar(context, 'Please select at least one Preferred Cuisine');
    return false;
  }
  if(state.nutrients == null||state.nutrients.isEmpty){
    _showSnackBar(context, 'Please select at least one Nutrient Focus');
    return false;
  }

  return true;
}

  Widget _buildSectionTitle(String title,bool isDarkMode) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:isDarkMode?  const Color(0xFFFFF8E1): Colors.black87),
    ),
  );

void _submit(BuildContext context, AdvancedUserDetails state) {
  if (!validateInputs(context, state)) return;

  // If validation passes, do whatever next (pop or send data)
  Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(advancedUserDetailsProvider);
    final notifier = ref.read(advancedUserDetailsProvider.notifier);

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
   
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Advanced Details"),
        backgroundColor:isDarkMode?null :Colors.transparent,
        elevation: 10,
      ),
      body: Container(
        height:double.infinity,  
      
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Activity Level",isDarkMode),
                  Wrap(
                    spacing: 8,
                    children: activityLevels.map((level) => ChoiceChip(
                      label: Text(level),
                      selected: state.activityLevel == level,
                      onSelected: (_) => notifier.setActivityLevel(level),
                    )).toList(),
                  ),

                  _buildSectionTitle("Medical Conditions",isDarkMode),
                  Wrap(
                    spacing: 8,
                    children: conditions.map((condition) => FilterChip(
                      label: Text(condition),
                      selected: state.conditions.contains(condition),
                      onSelected: (_) => notifier.toggleCondition(condition),
                    )).toList(),
                  ),

                  _buildSectionTitle("Meals per Day",isDarkMode),
                  Slider(
                    value: state.mealsPerDay.toDouble(),
                    min: 1,
                    max: 6,
                    divisions: 5,
                    
                  
                    label: state.mealsPerDay.toString(),
                    onChanged: (value) => notifier.setMealsPerDay(value.toInt()),
                  ),

                  _buildSectionTitle("Preferred Cuisines",isDarkMode),
                  Wrap(
                    spacing: 8,
                    children: cuisines.map((cuisine) => FilterChip(
                      label: Text(cuisine),
                      selected: state.cuisines.contains(cuisine),
                      onSelected: (_) => notifier.toggleCuisine(cuisine),
                    )).toList(),
                  ),

                  _buildSectionTitle("Disliked Foods",isDarkMode),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dislikeController,
                          decoration: InputDecoration(hintText: "Type and press Add",hintStyle: TextStyle(
                            color:isDarkMode?Colors.lightGreen:null,
                          )),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () {
                          if (dislikeController.text.isNotEmpty) {
                            notifier.addDislikedFood(dislikeController.text);
                            dislikeController.clear();
                          }
                        },
                      )
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: state.dislikedFoods.map((food) => Chip(
                      label: Text(food),
                      onDeleted: () => notifier.removeDislikedFood(food),
                    )).toList(),
                  ),

                  _buildSectionTitle("Nutrient Focus",isDarkMode),
                  Wrap(
                    spacing: 8,
                    children: nutrients.map((nutrient) => ChoiceChip(
                      label: Text(nutrient),
                      selected: state.nutrients.contains(nutrient),
                      onSelected: (_) => notifier.toggleNutrient(nutrient),
                    )).toList(),
                  ),

                  SizedBox(height: 50),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _submit(context, state),
                      icon: Icon(Icons.check,color: isDarkMode?Colors.black: const Color(0xFFFFF8E1),),
                      label: Text("Ok",style:TextStyle(
                        color:isDarkMode?Colors.black: const Color(0xFFFFF8E1),
                        fontWeight: FontWeight.bold,
                        fontSize:16,
                      )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Colors.lightGreen,
                        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
