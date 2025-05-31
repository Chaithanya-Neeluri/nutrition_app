import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveAdvancedUserDetails({
  required String activityLevel,
  required List<String> medicalConditions,
  required int mealsPerDay,
  required List<String> preferredCuisines,
  required List<String> dislikedFoods,
  required List<String> nutrientsSelected,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userDoc.set({
      'selectedActivityLevel': activityLevel,
      'medicalConditions': medicalConditions,
      'mealsPerDay': mealsPerDay,
      'preferredCuisines': preferredCuisines,
      'dislikedFoods': dislikedFoods,
      'nutrientsSelected': nutrientsSelected,
    }, SetOptions(merge: true)); // merge to avoid overwriting other user fields

    print("Advanced user details saved successfully.");
  } catch (e) {
    print("Error saving advanced user details: $e");
    rethrow;
  }
}
