import 'package:flutter/material.dart';
class NutriChefRecommendationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text("Based on user preferences:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        ListTile(
          leading: Icon(Icons.local_dining),
          title: Text("Add more High Protein Dishes"),
        ),
        ListTile(
          leading: Icon(Icons.thumb_up),
          title: Text("Popular among users: Paneer Bowl"),
        ),
        ListTile(
          leading: Icon(Icons.star),
          title: Text("Your Best Rated Dish: Millet Khichdi"),
        ),
      ],
    );
  }
}
