import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdvancedUserDetails {
  final String? activityLevel;
  final List<String> conditions;
  final int mealsPerDay;
  final List<String> cuisines;
  final List<String> dislikedFoods;
  final List<String> nutrients;

  AdvancedUserDetails({
    this.activityLevel,
    this.conditions = const [],
    this.mealsPerDay = 3,
    this.cuisines = const [],
    this.dislikedFoods = const [],
    this.nutrients = const [],
  });

  AdvancedUserDetails copyWith({
    String? activityLevel,
    List<String>? conditions,
    int? mealsPerDay,
    List<String>? cuisines,
    List<String>? dislikedFoods,
    List<String>? nutrients,
  }) {
    return AdvancedUserDetails(
      activityLevel: activityLevel ?? this.activityLevel,
      conditions: conditions ?? this.conditions,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      cuisines: cuisines ?? this.cuisines,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      nutrients: nutrients ?? this.nutrients,
    );
  }
}

class AdvancedUserDetailsNotifier extends StateNotifier<AdvancedUserDetails> {
  AdvancedUserDetailsNotifier() : super(AdvancedUserDetails());

  void setActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
  }

  void toggleCondition(String condition) {
    final updated = [...state.conditions];
    updated.contains(condition)
        ? updated.remove(condition)
        : updated.add(condition);
    state = state.copyWith(conditions: updated);
  }

  void setMealsPerDay(int count) {
    state = state.copyWith(mealsPerDay: count);
  }

  void toggleCuisine(String cuisine) {
    final updated = [...state.cuisines];
    updated.contains(cuisine) ? updated.remove(cuisine) : updated.add(cuisine);
    state = state.copyWith(cuisines: updated);
  }

  void addDislikedFood(String food) {
    final updated = [...state.dislikedFoods, food];
    state = state.copyWith(dislikedFoods: updated);
  }

  void removeDislikedFood(String food) {
    final updated = [...state.dislikedFoods]..remove(food);
    state = state.copyWith(dislikedFoods: updated);
  }

  void toggleNutrient(String nutrient) {
    final updated = [...state.nutrients];
    updated.contains(nutrient)
        ? updated.remove(nutrient)
        : updated.add(nutrient);
    state = state.copyWith(nutrients: updated);
  }
}

final advancedUserDetailsProvider = StateNotifierProvider<AdvancedUserDetailsNotifier, AdvancedUserDetails>(
  (ref) => AdvancedUserDetailsNotifier(),
);
